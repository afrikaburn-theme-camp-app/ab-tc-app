#!/usr/bin/env bash
set -euo pipefail

# Push one or more local files' content to their existing Superhuman page,
# poll the mutation to completion, verify it actually landed, and refresh
# the manifest baseline for exactly the file(s) pushed (via
# check-superhuman-sync.sh --only, never a whole-manifest refresh).
#
# Defaults to a DRY RUN — it does the manifest lookup and a remote-drift
# check (read-only) and prints exactly what it would do, but performs no
# write calls. Pass --yes to actually mutate Superhuman Docs.
#
# Creating brand-new pages is out of scope for this script — every path
# must already have a manifest entry. See the SKILL.md's manual `POST
# /pages` flow for creating a new page.
#
# Requires: curl, jq.

usage() {
  cat <<'EOF'
Usage:
  push-superhuman-page.sh <path> [<path2> ...] [options]

  --doc-id <id>          Superhuman doc ID (default: manifest top-level "docId")
  --token <token>         API token (or set SUPERHUMAN_TOKEN)
  --base-url <url>       API base URL (default: https://coda.io/apis/v1)
  --manifest <path>      Manifest file (default: .superhuman-sync-manifest.json)
  --root <path>          Local root folder (default: .)
  --yes                  Actually perform the push (default: dry run, no writes)
  --force                Override the remote-drift guard. Only meaningful with --yes.
  --sleep <seconds>      Delay between multiple files' PUTs (default: 2.5)
  --max-retries <n>      Retries for a transient 5xx/non-JSON response (default: 3)
  --check-script <path>  Path to check-superhuman-sync.sh, used for the manifest
                         refresh step (default: resolved relative to this script)
  --strict-latest        Add header X-Coda-Doc-Version: latest to read calls
  -h, --help             Show help

Remote-drift guard:
  Before pushing, each path's manifest-recorded remoteUpdatedAt is compared
  against the page's current live updatedAt. A mismatch means the remote page
  changed since the last accepted baseline — pushing now would silently
  overwrite that unreviewed change. Pull and review it first, or pass --force
  to push anyway. If ANY path in the batch is blocked (and not --force'd),
  the WHOLE batch is aborted before anything is pushed.

Exit codes:
  0  all paths pushed (or, in dry run, all previews) succeeded
  1  usage/argument error
  2  pre-flight failure: a path has no manifest entry, its page could not be
     found remotely, or it's remote-drift BLOCKED without --force — nothing
     was pushed
  3  one or more paths failed during the actual push (retry exhausted, poll
     timeout, or verify failed) after pre-flight passed; other paths in the
     batch may still have succeeded — see per-path output
EOF
}

PATHS=()
DOC_ID=""
TOKEN="${SUPERHUMAN_TOKEN:-}"
BASE_URL="https://coda.io/apis/v1"
MANIFEST_PATH=".superhuman-sync-manifest.json"
ROOT="."
DO_PUSH=false
FORCE=false
SLEEP_SECONDS=2.5
MAX_RETRIES=3
CHECK_SCRIPT=""
STRICT_LATEST=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --doc-id) DOC_ID="${2:-}"; shift 2 ;;
    --token) TOKEN="${2:-}"; shift 2 ;;
    --base-url) BASE_URL="${2:-}"; shift 2 ;;
    --manifest) MANIFEST_PATH="${2:-}"; shift 2 ;;
    --root) ROOT="${2:-}"; shift 2 ;;
    --yes) DO_PUSH=true; shift ;;
    --force) FORCE=true; shift ;;
    --sleep) SLEEP_SECONDS="${2:-}"; shift 2 ;;
    --max-retries) MAX_RETRIES="${2:-}"; shift 2 ;;
    --check-script) CHECK_SCRIPT="${2:-}"; shift 2 ;;
    --strict-latest) STRICT_LATEST=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
    *) PATHS+=("$1"); shift ;;
  esac
done

if [[ ${#PATHS[@]} -eq 0 ]]; then
  echo "Error: at least one path is required" >&2
  usage
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
if [[ -z "$CHECK_SCRIPT" ]]; then
  CHECK_SCRIPT="$(cd "$SCRIPT_DIR/../../.." && pwd)/scripts/check-superhuman-sync.sh"
fi
if [[ ! -x "$CHECK_SCRIPT" ]]; then
  echo "Error: check-script not found or not executable: $CHECK_SCRIPT" >&2
  exit 1
fi

ROOT_ABS="$(cd "$ROOT" && pwd)"
MANIFEST_ABS="$ROOT_ABS/$MANIFEST_PATH"

if [[ -f "$MANIFEST_ABS" ]]; then
  MANIFEST_JSON="$(cat "$MANIFEST_ABS")"
else
  echo "Error: manifest not found: $MANIFEST_ABS" >&2
  exit 1
fi
if [[ -z "$DOC_ID" ]]; then
  DOC_ID="$(echo "$MANIFEST_JSON" | jq -r '.docId // empty')"
fi
if [[ -z "$DOC_ID" ]]; then
  echo "Error: --doc-id is required (no top-level docId in manifest either)" >&2
  exit 1
fi

AUTH_HEADER=("Authorization: Bearer $TOKEN")
LATEST_HEADER=()
if $STRICT_LATEST; then
  LATEST_HEADER=("X-Coda-Doc-Version: latest")
fi
CURL_READ_OPTS=(--connect-timeout 10 --max-time 30 --retry 2 --retry-delay 1)
CURL_WRITE_OPTS=(--connect-timeout 10 --max-time 30)

log() { printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2; }

api_get() {
  curl -sS "${CURL_READ_OPTS[@]}" \
    -H "${AUTH_HEADER[0]}" \
    ${LATEST_HEADER:+-H "${LATEST_HEADER[0]}"} \
    "$1"
}

fetch_all_pages() {
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

# --- Pre-flight: resolve every path before mutating anything ---
log "Fetching page list for pre-flight (${#PATHS[@]} path(s))..."
ALL_PAGES="$(fetch_all_pages)"
ALL_PAGE_MIN="$(jq -c 'map({id,name,updatedAt:(.updatedAt // "")})' <<< "$ALL_PAGES")"

# Parallel arrays, indexed the same as PATHS.
PAGE_IDS=()
PAGE_NAMES=()
BASELINE_UPDATED=()
CURRENT_UPDATED=()
PREFLIGHT_STATUS=()   # OK | DRIFT_OVERRIDDEN | BLOCKED | MISSING_ENTRY | PAGE_NOT_FOUND
ANY_ABORT=false

for path in "${PATHS[@]}"; do
  entry="$(echo "$MANIFEST_JSON" | jq -c --arg p "$path" '.entries[$p] // null')"
  if [[ "$entry" == "null" ]]; then
    PAGE_IDS+=(""); PAGE_NAMES+=(""); BASELINE_UPDATED+=(""); CURRENT_UPDATED+=("")
    PREFLIGHT_STATUS+=("MISSING_ENTRY")
    ANY_ABORT=true
    continue
  fi
  page_id="$(echo "$entry" | jq -r '.pageId // empty')"
  page_name="$(echo "$entry" | jq -r '.pageName // empty')"
  baseline_updated="$(echo "$entry" | jq -r '.remoteUpdatedAt // empty')"

  current_updated="$(echo "$ALL_PAGE_MIN" | jq -r --arg id "$page_id" '[.[] | select(.id == $id)][0].updatedAt // empty')"
  PAGE_IDS+=("$page_id"); PAGE_NAMES+=("$page_name"); BASELINE_UPDATED+=("$baseline_updated")
  CURRENT_UPDATED+=("$current_updated")

  if [[ -z "$current_updated" ]]; then
    PREFLIGHT_STATUS+=("PAGE_NOT_FOUND")
    ANY_ABORT=true
  elif [[ "$current_updated" != "$baseline_updated" ]]; then
    if $FORCE; then
      PREFLIGHT_STATUS+=("DRIFT_OVERRIDDEN")
    else
      PREFLIGHT_STATUS+=("BLOCKED")
      ANY_ABORT=true
    fi
  else
    PREFLIGHT_STATUS+=("OK")
  fi
done

echo "Pre-flight:"
for i in "${!PATHS[@]}"; do
  case "${PREFLIGHT_STATUS[$i]}" in
    MISSING_ENTRY)
      echo "  ${PATHS[$i]}: MISSING_ENTRY — no manifest entry. Creating new pages is out of scope for this script; see the SKILL.md's manual POST /pages flow."
      ;;
    PAGE_NOT_FOUND)
      echo "  ${PATHS[$i]}: PAGE_NOT_FOUND — pageId ${PAGE_IDS[$i]} from the manifest no longer exists remotely. Needs manual investigation (renamed/deleted page?)."
      ;;
    BLOCKED)
      echo "  ${PATHS[$i]}: BLOCKED — remote changed since baseline (manifest=${BASELINE_UPDATED[$i]}, current=${CURRENT_UPDATED[$i]}). Pull and review first, or re-run with --force."
      ;;
    DRIFT_OVERRIDDEN)
      echo "  ${PATHS[$i]}: DRIFT DETECTED, OVERRIDDEN BY --force (manifest=${BASELINE_UPDATED[$i]}, current=${CURRENT_UPDATED[$i]}) — will push anyway and clobber that remote change."
      ;;
    OK)
      echo "  ${PATHS[$i]}: OK — target ${PAGE_IDS[$i]} (\"${PAGE_NAMES[$i]}\"), remote unchanged since last baseline"
      ;;
  esac
done

if $ANY_ABORT; then
  echo
  echo "Aborting: nothing pushed. Fix the issue(s) above and re-run." >&2
  exit 2
fi

if ! $DO_PUSH; then
  echo
  echo "[DRY RUN] No changes made. Would push:"
  for i in "${!PATHS[@]}"; do
    local_abs="$ROOT_ABS/${PATHS[$i]}"
    size="$(wc -c < "$local_abs" 2>/dev/null | tr -d ' ' || echo '?')"
    lines="$(wc -l < "$local_abs" 2>/dev/null | tr -d ' ' || echo '?')"
    echo "  ${PATHS[$i]} -> PUT /docs/$DOC_ID/pages/${PAGE_IDS[$i]} ($lines lines, $size bytes)"
    echo "    then: poll mutationStatus, verify updatedAt advanced, refresh manifest via --only ${PATHS[$i]}"
  done
  echo
  echo "Re-run with --yes to execute."
  exit 0
fi

# --- Wet run ---
put_with_retry() {
  local page_id="$1" payload="$2"
  local attempt=1 http_code body_tmp
  body_tmp="$(mktemp)"
  while (( attempt <= MAX_RETRIES )); do
    http_code="$(curl -sS "${CURL_WRITE_OPTS[@]}" -o "$body_tmp" -w '%{http_code}' -X PUT \
      -H "${AUTH_HEADER[0]}" -H "Content-Type: application/json" \
      ${LATEST_HEADER:+-H "${LATEST_HEADER[0]}"} \
      -d "$payload" \
      "$BASE_URL/docs/$DOC_ID/pages/$page_id")" || http_code=""
    if [[ "$http_code" == 2* ]]; then
      cat "$body_tmp"
      rm -f "$body_tmp"
      return 0
    fi
    # Retry on: empty code (curl-level failure), any 5xx, or a non-JSON body
    # (catches a transient HTML error page even if it ever comes back with a
    # non-5xx status).
    if [[ -z "$http_code" || "$http_code" == 5* ]] || ! jq -e . "$body_tmp" >/dev/null 2>&1; then
      log "  PUT attempt $attempt/$MAX_RETRIES got HTTP '${http_code:-<none>}' (transient) — retrying in $((attempt * 2))s"
      sleep $(( attempt * 2 ))
      attempt=$(( attempt + 1 ))
      continue
    fi
    # 4xx with a JSON body — a real error, retrying won't help.
    echo "PUT failed with HTTP $http_code:" >&2
    cat "$body_tmp" >&2
    rm -f "$body_tmp"
    return 1
  done
  echo "PUT failed after $MAX_RETRIES attempts (last HTTP '${http_code:-<none>}'):" >&2
  cat "$body_tmp" >&2
  rm -f "$body_tmp"
  return 1
}

poll_mutation_status() {
  local request_id="$1"
  # Observed in practice: a mutation can take ~20s to report completed=true,
  # comfortably past a 15s/5-attempt window (0 1 2 4 8) — that window
  # produced a false "poll timeout" for a push that had actually already
  # succeeded. Extended with more headroom rather than guessing a tighter
  # bound; a real hang still fails loud, just after longer.
  local delays=(0 1 2 4 8 16 30)
  local attempt=0
  for delay in "${delays[@]}"; do
    attempt=$((attempt + 1))
    if [[ "$delay" -gt 0 ]]; then sleep "$delay"; fi
    local resp completed
    # Guarded with `|| echo '{}'`: a transient network failure here should
    # make this one poll attempt look "not yet completed" and let the
    # backoff loop retry/eventually time out gracefully, not crash the
    # whole batch via set -e.
    resp="$(api_get "$BASE_URL/mutationStatus/$request_id" || echo '{}')"
    completed="$(echo "$resp" | jq -r '.completed // false')"
    log "  mutation poll $attempt/${#delays[@]}: completed=$completed"
    if [[ "$completed" == "true" ]]; then
      return 0
    fi
  done
  return 1
}

FAILED_ANY=false
TOTAL=${#PATHS[@]}

for i in "${!PATHS[@]}"; do
  path="${PATHS[$i]}"
  page_id="${PAGE_IDS[$i]}"
  page_name="${PAGE_NAMES[$i]}"
  before_updated="${CURRENT_UPDATED[$i]}"
  local_abs="$ROOT_ABS/$path"

  echo
  echo "Pushing $path -> $page_id (\"$page_name\")..."

  if [[ ! -f "$local_abs" ]]; then
    echo "  FAILED: local file does not exist: $local_abs" >&2
    FAILED_ANY=true
    continue
  fi

  content="$(cat "$local_abs")"
  payload="$(jq -n --arg name "$page_name" --arg content "$content" \
    '{name: $name, contentUpdate: {insertionMode: "replace", canvasContent: {format: "markdown", content: $content}}}')"

  if ! put_resp="$(put_with_retry "$page_id" "$payload")"; then
    echo "  FAILED: PUT did not succeed — skipping manifest refresh for this path" >&2
    FAILED_ANY=true
    continue
  fi

  request_id="$(echo "$put_resp" | jq -r '.requestId // empty')"
  if [[ -z "$request_id" ]]; then
    echo "  FAILED: PUT succeeded but no requestId in response: $put_resp" >&2
    FAILED_ANY=true
    continue
  fi

  log "  PUT accepted (requestId=$request_id), polling mutation status..."
  if ! poll_mutation_status "$request_id"; then
    echo "  FAILED: mutation did not complete in time — skipping manifest refresh for this path" >&2
    FAILED_ANY=true
    continue
  fi

  # Guarded the same way as poll_mutation_status: a transient network
  # failure here should read as "verify failed for this path" (handled
  # below, path marked FAILED, batch continues), not crash the whole batch.
  after_resp="$(api_get "$BASE_URL/docs/$DOC_ID/pages/$page_id" || echo '{}')"
  after_updated="$(echo "$after_resp" | jq -r '.updatedAt // empty')"
  if [[ -z "$after_updated" || "$after_updated" == "$before_updated" ]]; then
    echo "  FAILED: verify — updatedAt did not advance (before=$before_updated, after=${after_updated:-<empty>}). Push may not have taken effect — skipping manifest refresh." >&2
    FAILED_ANY=true
    continue
  fi

  log "  Verified: updatedAt advanced ($before_updated -> $after_updated). Refreshing manifest baseline..."
  if ! "$CHECK_SCRIPT" --doc-id "$DOC_ID" --root "$ROOT_ABS" --manifest "$MANIFEST_PATH" \
      --token "$TOKEN" --base-url "$BASE_URL" --only "$path" --write-manifest --quiet >/dev/null; then
    echo "  WARNING: push succeeded but manifest refresh failed — re-run check-superhuman-sync.sh --only $path --write-manifest by hand" >&2
    FAILED_ANY=true
    continue
  fi

  echo "  OK: updated ($before_updated -> $after_updated), manifest refreshed"

  if [[ "$i" -lt $((TOTAL - 1)) ]]; then
    log "Sleeping ${SLEEP_SECONDS}s before next push (rate limit)..."
    sleep "$SLEEP_SECONDS"
  fi
done

if $FAILED_ANY; then
  echo
  echo "One or more paths failed — see above." >&2
  exit 3
fi

echo
echo "All paths pushed and verified."
exit 0
