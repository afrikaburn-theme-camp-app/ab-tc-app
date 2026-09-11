#!/usr/bin/env bash
set -euo pipefail

# Check local Markdown files against Superhuman pages created with naming:
#   "<optional prefix> Local Sync :: <relative/path.md>"
#
# Outputs per-file status:
# - unchanged
# - remote-changed
# - local-only
# - remote-only
# - untracked
#
# This is a metadata-only check. A single pages-listing call returns every
# page's `updatedAt`; each local file's status comes from comparing that
# against the manifest's recorded `remoteUpdatedAt`. No export/download call
# is made here — a "remote-changed" result tells you a page needs pulling,
# not what changed in it. Use the superhuman-rest-fetch skill to pull and
# review the actual content.
#
# This script only tracks the remote side. Whether a local file has drifted
# since it was last pulled or pushed is git's job, not this script's —
# `git status` / `git diff` on a tracked file answers that directly, so
# there is no separate local-hash bookkeeping to maintain here.
#
# Requires: curl, jq

usage() {
  cat <<'EOF'
Usage:
  scripts/check-superhuman-sync.sh --doc-id <DOC_ID> [options]

Options:
  --doc-id <id>              Superhuman doc ID (required)
  --token <token>            API token (or set SUPERHUMAN_TOKEN)
  --base-url <url>           API base URL (default: https://docs.superhuman.com/apis/v1)
  --manifest <path>          Manifest file (default: .superhuman-sync-manifest.json)
  --root <path>              Local root folder (default: .)
  --write-manifest           Write current page ids/timestamps into manifest
  --strict-latest            Add header X-Coda-Doc-Version: latest to read calls
  --include <glob>           Include glob for local files (default: **/*.md)
  --exclude <glob>           Exclude glob; can be repeated
  --only <path>              Only classify (and --write-manifest) this path; can be
                              repeated. Everything else is skipped entirely. Use this
                              right after a partial push so the baseline refresh only
                              touches the file(s) you actually pushed, instead of also
                              accepting unrelated unreviewed remote drift on files you
                              didn't review.
  --quiet                    Suppress per-file progress lines
  -h, --help                 Show help

Defaults:
  Excludes AGENTS.md, README.md, skills/**, scripts/**

How it works:
  One page-listing call fetches every page's `updatedAt`. Each local file is
  matched to a remote page and its `updatedAt` is compared against the
  manifest's recorded `remoteUpdatedAt` — no export or download is needed to
  answer "has this changed since I last checked".

  --only does not override --exclude: a path already dropped by the default
  excludes (AGENTS.md, README.md, skills/**, scripts/**) never reaches the classify
  step, so --only can't "rescue" it.
EOF
}

DOC_ID=""
TOKEN="${SUPERHUMAN_TOKEN:-}"
BASE_URL="https://docs.superhuman.com/apis/v1"
MANIFEST_PATH=".superhuman-sync-manifest.json"
ROOT="."
WRITE_MANIFEST=false
STRICT_LATEST=false
INCLUDE_GLOB="**/*.md"
EXCLUDES=("AGENTS.md" "README.md" "skills/**" "scripts/**")
ONLY=()
QUIET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --doc-id)
      DOC_ID="${2:-}"
      shift 2
      ;;
    --token)
      TOKEN="${2:-}"
      shift 2
      ;;
    --base-url)
      BASE_URL="${2:-}"
      shift 2
      ;;
    --manifest)
      MANIFEST_PATH="${2:-}"
      shift 2
      ;;
    --root)
      ROOT="${2:-}"
      shift 2
      ;;
    --write-manifest)
      WRITE_MANIFEST=true
      shift
      ;;
    --strict-latest)
      STRICT_LATEST=true
      shift
      ;;
    --include)
      INCLUDE_GLOB="${2:-}"
      shift 2
      ;;
    --exclude)
      EXCLUDES+=("${2:-}")
      shift 2
      ;;
    --only)
      ONLY+=("${2:-}")
      shift 2
      ;;
    --quiet)
      QUIET=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$DOC_ID" ]]; then
  echo "Error: --doc-id is required" >&2
  exit 1
fi
if [[ -z "$TOKEN" ]]; then
  echo "Error: token missing. Use --token or SUPERHUMAN_TOKEN." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required" >&2
  exit 1
fi

ROOT_ABS="$(cd "$ROOT" && pwd)"
MANIFEST_ABS="$ROOT_ABS/$MANIFEST_PATH"

AUTH_HEADER=("Authorization: Bearer $TOKEN")
LATEST_HEADER=()
if $STRICT_LATEST; then
  LATEST_HEADER=("X-Coda-Doc-Version: latest")
fi

# Shared curl timeouts so a network stall fails loud instead of hanging
# forever. --connect-timeout bounds the TCP/TLS handshake; --max-time bounds
# the whole request; --retry adds resilience against transient blips.
CURL_READ_OPTS=(--connect-timeout 10 --max-time 30 --retry 2 --retry-delay 1)

ts() { date -u +%H:%M:%S; }

log() {
  # Timestamped progress line to stderr so stdout stays available for
  # anything that wants clean output; suppressed entirely by --quiet.
  $QUIET && return 0
  printf '[%s] %s\n' "$(ts)" "$1" >&2
}

api_get() {
  local url="$1"
  curl -sS "${CURL_READ_OPTS[@]}" \
    -H "${AUTH_HEADER[0]}" \
    ${LATEST_HEADER:+-H "${LATEST_HEADER[0]}"} \
    "$url"
}

list_local_files() {
  (
    cd "$ROOT_ABS"
    find . -type f -name "*.md" | sed 's#^\./##'
  ) | while IFS= read -r f; do
    local skip=false
    for pat in "${EXCLUDES[@]}"; do
      if [[ "$f" == $pat ]]; then
        skip=true
        break
      fi
    done
    if ! $skip; then
      echo "$f"
    fi
  done
}

SCRIPT_START_TS=$(date +%s)
log "Starting sync check for doc $DOC_ID (base: $BASE_URL)"

# 1) Get all pages. This is the only network call this script makes: it
# returns every page's `updatedAt` up front, which is all that's needed to
# classify drift against the manifest.
log "Fetching page list (single paginated call)..."
PAGES_URL="$BASE_URL/docs/$DOC_ID/pages?limit=100"
ALL_PAGES='[]'
PAGE_FETCH_COUNT=0
while [[ -n "$PAGES_URL" ]]; do
  PAGE_FETCH_COUNT=$((PAGE_FETCH_COUNT + 1))
  PAGE_JSON="$(api_get "$PAGES_URL")"
  ITEMS="$(echo "$PAGE_JSON" | jq '.items // []')"
  ALL_PAGES="$(jq -c --argjson a "$ALL_PAGES" --argjson b "$ITEMS" '$a + $b' <<< '{}')"
  NEXT_LINK="$(echo "$PAGE_JSON" | jq -r '.nextPageLink // empty')"
  NEXT_TOKEN="$(echo "$PAGE_JSON" | jq -r '.nextPageToken // empty')"
  if [[ -n "$NEXT_LINK" ]]; then
    PAGES_URL="$NEXT_LINK"
  elif [[ -n "$NEXT_TOKEN" ]]; then
    PAGES_URL="$BASE_URL/docs/$DOC_ID/pages?pageToken=$NEXT_TOKEN"
  else
    PAGES_URL=""
  fi
done
log "Page list fetched: $(echo "$ALL_PAGES" | jq 'length') page(s) across $PAGE_FETCH_COUNT request(s)"

# Map remote sync pages: path -> {id,name,updatedAt}
REMOTE_SYNC_JSON="$(jq -c '
  map(select(.name | contains("Local Sync :: ")))
  | map({
      id,
      name,
      updatedAt: (.updatedAt // ""),
      path: (.name | capture("Local Sync :: (?<p>.*)$").p)
    })
' <<< "$ALL_PAGES")"

# Minimal page metadata for generic matching.
ALL_PAGE_MIN_JSON="$(jq -c 'map({id,name,updatedAt:(.updatedAt // "")})' <<< "$ALL_PAGES")"

# Load existing manifest if present.
if [[ -f "$MANIFEST_ABS" ]]; then
  MANIFEST_JSON="$(cat "$MANIFEST_ABS")"
else
  MANIFEST_JSON='{"version":1,"entries":{}}'
fi

# Build local list (bash 3 compatible)
LOCAL_FILES=()
while IFS= read -r f; do
  LOCAL_FILES+=("$f")
done < <(list_local_files | sort)

# Build remote path set (bash 3 compatible)
REMOTE_PATHS=()
while IFS= read -r p; do
  REMOTE_PATHS+=("$p")
done < <(echo "$REMOTE_SYNC_JSON" | jq -r '.[].path' | sort -u)

REPORT_LINES=()
STATUS_COUNTS='{}'
NEW_ENTRIES='{}'

get_remote_for_path() {
  local p="$1"
  # 1) Prefer explicit manifest mapping by pageId if available.
  local manifest_page_id
  manifest_page_id="$(echo "$MANIFEST_JSON" | jq -r --arg p "$p" '.entries[$p].pageId // empty')"
  if [[ -n "$manifest_page_id" ]]; then
    local by_id
    by_id="$(echo "$ALL_PAGE_MIN_JSON" | jq -c --arg id "$manifest_page_id" '[.[] | select(.id == $id)][0]')"
    if [[ "$by_id" != "null" ]]; then
      echo "$by_id"
      return
    fi
  fi

  # 2) Match Local Sync naming convention.
  local by_sync_name
  by_sync_name="$(echo "$REMOTE_SYNC_JSON" | jq -c --arg p "$p" '[.[] | select(.path == $p)][0]')"
  if [[ "$by_sync_name" != "null" ]]; then
    echo "$by_sync_name"
    return
  fi

  # 3) Fallback: derive page title from filename, e.g. task-assignment.md -> Task Assignment.
  local base stem title by_title
  base="$(basename "$p")"
  stem="${base%.md}"
  title="$(echo "$stem" | sed -E 's/[-_]+/ /g;s/[[:space:]]+/ /g;s/^ //;s/ $//' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) tolower(substr($i,2)) } print}')"
  by_title="$(echo "$ALL_PAGE_MIN_JSON" | jq -c --arg n "$title" '[.[] | select(.name == $n)][0]')"
  echo "$by_title"
}

get_manifest_entry() {
  local p="$1"
  echo "$MANIFEST_JSON" | jq -c --arg p "$p" '.entries[$p] // null'
}

# Classify a single local file against the remote page list and the
# manifest. No network call happens here — everything needed is already in
# ALL_PAGE_MIN_JSON / REMOTE_SYNC_JSON / MANIFEST_JSON.
classify_file() {
  local path="$1"
  local remote page_id page_name remote_updated_at
  local manifest_entry prev_remote_updated status report entry

  remote="$(get_remote_for_path "$path")"

  if [[ "$remote" == "null" ]]; then
    status="local-only"
    report="$status | $path | no matching remote page"
    log "[$path] -> $status"
    REPORT_LINES+=("$report")
    STATUS_COUNTS="$(jq -c --arg k "$status" '.[$k] = ((.[$k] // 0) + 1)' <<< "$STATUS_COUNTS")"
    return
  fi

  page_id="$(echo "$remote" | jq -r '.id')"
  page_name="$(echo "$remote" | jq -r '.name')"
  remote_updated_at="$(echo "$remote" | jq -r '.updatedAt // ""')"

  manifest_entry="$(get_manifest_entry "$path")"
  prev_remote_updated="$(echo "$manifest_entry" | jq -r '.remoteUpdatedAt // ""')"

  if [[ "$manifest_entry" == "null" || -z "$prev_remote_updated" ]]; then
    status="untracked"
  elif [[ "$remote_updated_at" == "$prev_remote_updated" ]]; then
    status="unchanged"
  else
    status="remote-changed"
  fi

  report="$status | $path | page=$page_id | name=$page_name"
  log "[$path] -> $status"
  REPORT_LINES+=("$report")
  STATUS_COUNTS="$(jq -c --arg k "$status" '.[$k] = ((.[$k] // 0) + 1)' <<< "$STATUS_COUNTS")"

  if $WRITE_MANIFEST; then
    entry="$(jq -nc \
      --arg pageId "$page_id" \
      --arg pageName "$page_name" \
      --arg remoteUpdatedAt "$remote_updated_at" \
      --arg lastCheckedAt "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '{pageId:$pageId,pageName:$pageName,remoteUpdatedAt:$remoteUpdatedAt,lastCheckedAt:$lastCheckedAt}')"
    NEW_ENTRIES="$(jq -c --arg p "$path" --argjson e "$entry" '.[$p]=$e' <<< "$NEW_ENTRIES")"
  fi
}

log "Classifying ${#LOCAL_FILES[@]} local file(s) against $(echo "$ALL_PAGES" | jq 'length') remote page(s)..."
for f in "${LOCAL_FILES[@]}"; do
  if [[ ${#ONLY[@]} -gt 0 ]]; then
    match=false
    for o in "${ONLY[@]}"; do
      # Unquoted $o: same glob-capable match idiom already used for EXCLUDES,
      # so a literal path is an exact match and a glob pattern also works.
      if [[ "$f" == $o ]]; then
        match=true
        break
      fi
    done
    $match || continue
  fi
  classify_file "$f"
done

TOTAL_ELAPSED=$(( $(date +%s) - SCRIPT_START_TS ))
log "Done in ${TOTAL_ELAPSED}s"

# 2) Remote-only checks (pages that map to local paths that do not exist)
for rpath in "${REMOTE_PATHS[@]-}"; do
  if [[ -z "$rpath" ]]; then
    continue
  fi
  if [[ ! -f "$ROOT_ABS/$rpath" ]]; then
    report="remote-only | $rpath | missing local file"
    REPORT_LINES+=("$report")
    STATUS_COUNTS="$(jq -c --arg k "remote-only" '.[$k] = ((.[$k] // 0) + 1)' <<< "$STATUS_COUNTS")"
  fi
done

# Print report
printf '%s\n' "Sync Report for doc $DOC_ID"
printf '%s\n' "Root: $ROOT_ABS"
printf '%s\n' "Manifest: $MANIFEST_PATH"
printf '%s\n\n' "---"

for line in "${REPORT_LINES[@]}"; do
  printf '%s\n' "$line"
done

printf '\nSummary:\n'
echo "$STATUS_COUNTS" | jq -r 'to_entries | sort_by(.key)[] | "- \(.key): \(.value)"'
printf 'Total time: %ss\n' "$TOTAL_ELAPSED"
printf '\nNote: this only reports remote drift. For local drift, use `git status` / `git diff`.\n'

if $WRITE_MANIFEST; then
  UPDATED_MANIFEST="$(jq --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --argjson entries "$NEW_ENTRIES" '
    .version = 1
    | .updatedAt = $now
    | .entries = ((.entries // {}) + $entries)
  ' <<< "$MANIFEST_JSON")"
  printf '%s\n' "$UPDATED_MANIFEST" > "$MANIFEST_ABS"
  printf '\nWrote manifest: %s\n' "$MANIFEST_ABS"
fi
