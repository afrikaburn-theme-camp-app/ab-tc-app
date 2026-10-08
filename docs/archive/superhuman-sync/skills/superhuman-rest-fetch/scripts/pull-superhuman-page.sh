#!/usr/bin/env bash
set -euo pipefail

# Fetch a Superhuman/Coda page, normalize away known cosmetic export noise,
# and diff it against the corresponding local file. Read-only against the
# local filesystem — this never writes to the local .md file. Deciding what
# to do with a real content diff (where to insert new content, how to
# reconcile a structural change) needs human judgment; this script's job
# stops at "here is the normalized remote content and here is how it
# differs from local," not "here is what I changed for you."
#
# Requires: curl, jq. Uses perl for one normalization pass if present
# (falls back to skipping that pass, with a warning, if perl is missing).

usage() {
  cat <<'EOF'
Usage:
  pull-superhuman-page.sh (--path <local/rel/path.md> | --page-id <id> | --url <url>) [options]

Target selection (exactly one required):
  --path <path>        Local file path, relative to --root. Resolved to a pageId the
                        same way scripts/check-superhuman-sync.sh does: manifest
                        pageId -> "Local Sync :: <path>" naming -> filename-to-title
                        fallback. Also used as the diff target.
  --page-id <id>        Explicit page id (e.g. canvas-xxxx). Requires --doc-id. No
                        local diff is performed (nothing to diff against).
  --url <url>           Full Superhuman/Coda page URL. docId/pageId are derived from
                        it. No local diff is performed.

Options:
  --doc-id <id>          Superhuman doc ID. Optional if --url is given (derived), or if
                        --path is given and the manifest has a top-level "docId".
  --token <token>        API token (or set SUPERHUMAN_TOKEN)
  --base-url <url>       API base URL (default: https://coda.io/apis/v1)
  --manifest <path>      Manifest file (default: .superhuman-sync-manifest.json)
  --root <path>          Local root folder (default: .)
  --out <path>           Write normalized remote markdown here (default: a mktemp file)
  --no-diff              Skip diffing against local even if --path resolves to a file
  --strict-latest        Add header X-Coda-Doc-Version: latest to read calls
  -h, --help             Show help

Exit codes:
  0  fetched successfully and (if diffed) normalized remote content matches local
  1  fetched successfully but normalized remote content differs from local (this is
     information, not failure — review the diff)
  2  a real error: bad args, page resolution failure, export/poll timeout, non-2xx
     API response, or --path given but the local file doesn't exist and --no-diff
     wasn't passed
EOF
}

PATH_ARG=""
PAGE_ID_ARG=""
URL_ARG=""
DOC_ID=""
TOKEN="${SUPERHUMAN_TOKEN:-}"
BASE_URL="https://coda.io/apis/v1"
MANIFEST_PATH=".superhuman-sync-manifest.json"
ROOT="."
OUT_PATH=""
NO_DIFF=false
STRICT_LATEST=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) PATH_ARG="${2:-}"; shift 2 ;;
    --page-id) PAGE_ID_ARG="${2:-}"; shift 2 ;;
    --url) URL_ARG="${2:-}"; shift 2 ;;
    --doc-id) DOC_ID="${2:-}"; shift 2 ;;
    --token) TOKEN="${2:-}"; shift 2 ;;
    --base-url) BASE_URL="${2:-}"; shift 2 ;;
    --manifest) MANIFEST_PATH="${2:-}"; shift 2 ;;
    --root) ROOT="${2:-}"; shift 2 ;;
    --out) OUT_PATH="${2:-}"; shift 2 ;;
    --no-diff) NO_DIFF=true; shift ;;
    --strict-latest) STRICT_LATEST=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

TARGET_COUNT=0
[[ -n "$PATH_ARG" ]] && TARGET_COUNT=$((TARGET_COUNT + 1))
[[ -n "$PAGE_ID_ARG" ]] && TARGET_COUNT=$((TARGET_COUNT + 1))
[[ -n "$URL_ARG" ]] && TARGET_COUNT=$((TARGET_COUNT + 1))
if [[ "$TARGET_COUNT" -ne 1 ]]; then
  echo "Error: exactly one of --path, --page-id, --url is required" >&2
  usage
  exit 2
fi
if [[ -z "$TOKEN" ]]; then
  echo "Error: token missing. Use --token or SUPERHUMAN_TOKEN." >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required" >&2
  exit 2
fi

ROOT_ABS="$(cd "$ROOT" && pwd)"
MANIFEST_ABS="$ROOT_ABS/$MANIFEST_PATH"

AUTH_HEADER=("Authorization: Bearer $TOKEN")
LATEST_HEADER=()
if $STRICT_LATEST; then
  LATEST_HEADER=("X-Coda-Doc-Version: latest")
fi
CURL_READ_OPTS=(--connect-timeout 10 --max-time 30 --retry 2 --retry-delay 1)

log() { printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2; }

api_get() {
  curl -sS "${CURL_READ_OPTS[@]}" \
    -H "${AUTH_HEADER[0]}" \
    ${LATEST_HEADER:+-H "${LATEST_HEADER[0]}"} \
    "$1"
}

api_post() {
  curl -sS -X POST "${CURL_READ_OPTS[@]}" \
    -H "${AUTH_HEADER[0]}" \
    -H "Content-Type: application/json" \
    ${LATEST_HEADER:+-H "${LATEST_HEADER[0]}"} \
    -d "$2" \
    "$1"
}

fetch_all_pages() {
  # Paginated GET /docs/{docId}/pages -> JSON array of all pages.
  local pages_url="$BASE_URL/docs/$DOC_ID/pages?limit=100"
  local all='[]'
  while [[ -n "$pages_url" ]]; do
    local resp items next_link next_token
    resp="$(api_get "$pages_url")"
    items="$(echo "$resp" | jq '.items // []')"
    all="$(jq -c --argjson a "$all" --argjson b "$items" '$a + $b' <<< '{}')"
    next_link="$(echo "$resp" | jq -r '.nextPageLink // empty')"
    next_token="$(echo "$resp" | jq -r '.nextPageToken // empty')"
    if [[ -n "$next_link" ]]; then
      pages_url="$next_link"
    elif [[ -n "$next_token" ]]; then
      pages_url="$BASE_URL/docs/$DOC_ID/pages?pageToken=$next_token"
    else
      pages_url=""
    fi
  done
  echo "$all"
}

# --- Resolve PAGE_ID (and, for --path, LOCAL_ABS) ---
LOCAL_ABS=""

if [[ -n "$PAGE_ID_ARG" ]]; then
  if [[ -z "$DOC_ID" ]]; then
    echo "Error: --doc-id is required with --page-id" >&2
    exit 2
  fi
  PAGE_ID="$PAGE_ID_ARG"

elif [[ -n "$URL_ARG" ]]; then
  DOC_ID="$(echo "$URL_ARG" | sed -n 's#.*_d\([^/]*\).*#\1#p')"
  SHORT_PAGE_ID="$(echo "$URL_ARG" | sed -n 's#.*_su\([^#/?]*\).*#\1#p')"
  if [[ -z "$DOC_ID" || -z "$SHORT_PAGE_ID" ]]; then
    echo "Error: could not parse doc/page IDs from URL" >&2
    exit 2
  fi
  log "Resolving page id from URL (docId=$DOC_ID, shortPageId=$SHORT_PAGE_ID)..."
  ALL_PAGES="$(fetch_all_pages)"
  PAGE_ID="$(echo "$ALL_PAGES" | jq -r --arg sid "$SHORT_PAGE_ID" '
    [.[] | select(.browserLink | test("_su" + $sid + "$"))][0].id // empty
  ')"
  if [[ -z "$PAGE_ID" ]]; then
    echo "Error: could not resolve a page id from short page id: $SHORT_PAGE_ID" >&2
    exit 2
  fi

else
  # --path: manifest pageId -> "Local Sync :: <path>" naming -> filename-to-title fallback.
  # Same 3-tier strategy as get_remote_for_path() in scripts/check-superhuman-sync.sh,
  # reimplemented standalone rather than sourced (skill scripts are self-contained).
  LOCAL_ABS="$ROOT_ABS/$PATH_ARG"

  if [[ -f "$MANIFEST_ABS" ]]; then
    MANIFEST_JSON="$(cat "$MANIFEST_ABS")"
  else
    MANIFEST_JSON='{"version":1,"entries":{}}'
  fi

  if [[ -z "$DOC_ID" ]]; then
    DOC_ID="$(echo "$MANIFEST_JSON" | jq -r '.docId // empty')"
  fi
  if [[ -z "$DOC_ID" ]]; then
    echo "Error: --doc-id is required (no top-level docId in manifest either)" >&2
    exit 2
  fi

  log "Fetching page list to resolve $PATH_ARG..."
  ALL_PAGES="$(fetch_all_pages)"
  ALL_PAGE_MIN="$(jq -c 'map({id,name,updatedAt:(.updatedAt // ""),browserLink})' <<< "$ALL_PAGES")"

  PAGE_ID=""
  manifest_page_id="$(echo "$MANIFEST_JSON" | jq -r --arg p "$PATH_ARG" '.entries[$p].pageId // empty')"
  if [[ -n "$manifest_page_id" ]]; then
    PAGE_ID="$(echo "$ALL_PAGE_MIN" | jq -r --arg id "$manifest_page_id" '[.[] | select(.id == $id)][0].id // empty')"
  fi
  if [[ -z "$PAGE_ID" ]]; then
    PAGE_ID="$(echo "$ALL_PAGE_MIN" | jq -r --arg p "$PATH_ARG" '
      [.[] | select(.name | contains("Local Sync :: " + $p))][0].id // empty
    ')"
  fi
  if [[ -z "$PAGE_ID" ]]; then
    base="$(basename "$PATH_ARG")"
    stem="${base%.md}"
    title="$(echo "$stem" | sed -E 's/[-_]+/ /g;s/[[:space:]]+/ /g;s/^ //;s/ $//' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) tolower(substr($i,2)) } print}')"
    PAGE_ID="$(echo "$ALL_PAGE_MIN" | jq -r --arg n "$title" '[.[] | select(.name == $n)][0].id // empty')"
  fi
  if [[ -z "$PAGE_ID" ]]; then
    echo "Error: could not resolve a remote page for path: $PATH_ARG" >&2
    exit 2
  fi
fi

log "Resolved page id: $PAGE_ID (doc: $DOC_ID)"

# --- Export, poll, download ---
export_resp="$(api_post "$BASE_URL/docs/$DOC_ID/pages/$PAGE_ID/export" '{"outputFormat":"markdown"}')"
export_href="$(echo "$export_resp" | jq -r '.href // empty')"
if [[ -z "$export_href" ]]; then
  echo "Error: export request failed: $export_resp" >&2
  exit 2
fi

log "Polling export status..."
DOWNLOAD_LINK=""
# Extended past the original (0 1 2 4 8): a push-side mutationStatus poll
# with the same short window produced a false timeout in practice for a
# write that had actually already succeeded (~20s to report complete). Export
# generation is usually faster than a content write, but using the same
# wider window here too rather than assuming exports are always fast enough.
delays=(0 1 2 4 8 16 30)
attempt=0
for delay in "${delays[@]}"; do
  attempt=$((attempt + 1))
  if [[ "$delay" -gt 0 ]]; then sleep "$delay"; fi
  status_resp="$(api_get "$export_href")"
  export_status="$(echo "$status_resp" | jq -r '.status // ""')"
  DOWNLOAD_LINK="$(echo "$status_resp" | jq -r '.downloadLink // empty')"
  log "  attempt $attempt/${#delays[@]}: status=$export_status"
  if [[ "$export_status" == "complete" || "$export_status" == "completed" ]] && [[ -n "$DOWNLOAD_LINK" ]]; then
    break
  fi
  DOWNLOAD_LINK=""
done
if [[ -z "$DOWNLOAD_LINK" ]]; then
  echo "Error: export did not complete after ${#delays[@]} poll attempts — this can happen if the S3 signed URL is unreachable; see the rest-fetch skill's Known Errors section" >&2
  exit 2
fi

RAW_TMP="$(mktemp)"
trap 'rm -f "$RAW_TMP"' EXIT
log "Downloading export..."
curl -sS "${CURL_READ_OPTS[@]}" -o "$RAW_TMP" "$DOWNLOAD_LINK"

# Detect gzip by magic bytes rather than assuming, so this stays correct if
# Coda ever changes it.
MAGIC="$(od -An -tx1 -N2 "$RAW_TMP" | tr -d ' \n')"
if [[ "$MAGIC" == "1f8b" ]]; then
  RAW_CONTENT="$(gunzip -c "$RAW_TMP")"
else
  RAW_CONTENT="$(cat "$RAW_TMP")"
fi

# --- Normalize: three safe, mechanical passes only. Heading-level shifts are
# deliberately NOT touched here — confirmed this session that they are not a
# consistent transform (one page's top heading differed by level from local
# while every other heading in the same doc matched exactly), so a diff must
# surface them for a human to judge, never silently suppress them. ---

# Pass 1: strip the injected "Column N" technical header row and swap the
# delimiter row down so it sits directly under the real header row (matches
# what local files in this repo actually look like). Handles multiple tables
# in one page. If the expected 3-line shape isn't there, strip just the
# Column-N row and warn instead of guessing.
#
# Operates on $RAW_CONTENT (already gunzip'd above if needed, via the magic-
# byte check) rather than re-reading $RAW_TMP, so there is exactly one place
# that decides whether the bytes are gzip — no risk of running text tools
# against raw gzip binary.
DECOMPRESSED_TMP="$(mktemp)"
printf '%s' "$RAW_CONTENT" > "$DECOMPRESSED_TMP"

AWK_STDERR="$(mktemp)"
STAGE1="$(mktemp)"
awk '
  function is_column_row(line) {
    t = line
    gsub(/Column [0-9]+/, "", t)
    gsub(/[| \t]/, "", t)
    return (t == "" && line ~ /Column [0-9]+/)
  }
  function is_delim_row(line) {
    t = line
    gsub(/:?-+:?/, "", t)
    gsub(/[| \t]/, "", t)
    return (t == "" && line ~ /^\|/ && line ~ /-/)
  }
  { lines[NR] = $0 }
  END {
    n = NR; i = 1; swapped = 0; warned = 0
    while (i <= n) {
      if (is_column_row(lines[i])) {
        if (i + 2 <= n && is_delim_row(lines[i+1])) {
          print lines[i+2]
          print lines[i+1]
          i += 3
          swapped++
          continue
        } else {
          print "WARN: Column-N row without the expected delimiter+header shape after it (input line " i ") — stripped the row only; check this table by hand" > "/dev/stderr"
          warned++
          i += 1
          continue
        }
      }
      print lines[i]
      i += 1
    }
    print "TABLES_SWAPPED=" swapped > "/dev/stderr"
    print "TABLES_WARNED=" warned > "/dev/stderr"
  }
' "$DECOMPRESSED_TMP" > "$STAGE1" 2> "$AWK_STDERR" || true
rm -f "$DECOMPRESSED_TMP"
TABLES_SWAPPED="$( { grep -o 'TABLES_SWAPPED=[0-9]*' "$AWK_STDERR" || true; } | cut -d= -f2)"
TABLES_WARNED="$( { grep -o 'TABLES_WARNED=[0-9]*' "$AWK_STDERR" || true; } | cut -d= -f2)"
TABLES_SWAPPED="${TABLES_SWAPPED:-0}"
TABLES_WARNED="${TABLES_WARNED:-0}"
grep '^WARN:' "$AWK_STDERR" >&2 || true
rm -f "$AWK_STDERR"

# Pass 2: revert smart quotes to straight — literal byte substitution.
# (grep is wrapped with `|| true` *before* the pipe: under `set -o pipefail`,
# grep finding zero matches — a normal, common case for pages with no curly
# quotes — would otherwise make the whole pipeline's exit status non-zero
# and abort the script under `set -e`. Forcing grep's own exit to 0 first
# avoids that without risking double-counted output from a `|| echo 0`
# fallback racing the pipe's already-produced stdout.)
QUOTES_BEFORE="$( { grep -o $'[‘’“”]' "$STAGE1" || true; } | wc -l | tr -d ' ')"
STAGE2="$(mktemp)"
LC_ALL=C sed "s/’/'/g; s/‘/'/g; s/“/\"/g; s/”/\"/g" "$STAGE1" > "$STAGE2"
rm -f "$STAGE1"

# Pass 3: unwrap identity autolinks ([x](x) -> x) only when link text equals
# href — needs an equality test sed can't do, so use perl if available.
STAGE3="$(mktemp)"
AUTOLINKS_UNWRAPPED=0
if command -v perl >/dev/null 2>&1; then
  PERL_STDERR="$(mktemp)"
  perl -pe '
    BEGIN { $c = 0 }
    s/\[([^\]]+)\]\(([^)]+)\)/ $1 eq $2 ? do { $c++; $1 } : "[$1]($2)" /ge;
    END { print STDERR "AUTOLINKS_UNWRAPPED=$c\n" }
  ' "$STAGE2" > "$STAGE3" 2> "$PERL_STDERR"
  AUTOLINKS_UNWRAPPED="$( { grep -o 'AUTOLINKS_UNWRAPPED=[0-9]*' "$PERL_STDERR" || true; } | cut -d= -f2)"
  AUTOLINKS_UNWRAPPED="${AUTOLINKS_UNWRAPPED:-0}"
  rm -f "$PERL_STDERR"
else
  echo "WARN: perl not found — skipping identity-autolink normalization pass" >&2
  cp "$STAGE2" "$STAGE3"
fi
rm -f "$STAGE2"

NORMALIZED_CONTENT="$(cat "$STAGE3")"
rm -f "$STAGE3"

log "Normalized: $TABLES_SWAPPED table(s) swapped, $TABLES_WARNED unexpected-shape warning(s), $QUOTES_BEFORE smart-quote(s) reverted, $AUTOLINKS_UNWRAPPED identity-autolink(s) unwrapped"

# --- Write output ---
if [[ -n "$OUT_PATH" ]]; then
  FINAL_OUT="$OUT_PATH"
else
  FINAL_OUT="$(mktemp -t superhuman-pull)"
fi
printf '%s\n' "$NORMALIZED_CONTENT" > "$FINAL_OUT"
echo "Normalized remote content written to: $FINAL_OUT"

# --- Diff against local, if applicable ---
if [[ -z "$LOCAL_ABS" ]]; then
  echo "No local path given (--page-id/--url) — nothing to diff. Exiting 0."
  exit 0
fi
if $NO_DIFF; then
  echo "--no-diff passed — skipping local diff. Exiting 0."
  exit 0
fi
if [[ ! -f "$LOCAL_ABS" ]]; then
  echo "Error: --no-diff not passed but local file does not exist: $LOCAL_ABS" >&2
  exit 2
fi

if diff -u -L "$PATH_ARG" -L "remote:$PAGE_ID (normalized)" "$LOCAL_ABS" "$FINAL_OUT"; then
  echo "No differences — local matches normalized remote content."
  exit 0
else
  echo
  echo "Differences found (see diff above). This is information, not failure —"
  echo "review before deciding what, if anything, to change locally."
  exit 1
fi
