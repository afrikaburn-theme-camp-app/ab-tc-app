# Superhuman REST Fetch Skill

## Purpose
Fetch Superhuman Docs content **using REST API only** (no MCP), from either a full document/page URL or known IDs.

This is the **dominant sync direction** (Superhuman → local). Prefer pull + reconcile over push for product-intent changes.

## Scope
- Read document metadata
- List pages
- Fetch page content
- Handle pagination
- Extract target page from a browser URL

## Requirements
- A valid API token
- `curl`
- Optional: `jq` (recommended)

Set token once per session:

```bash
export SUPERHUMAN_TOKEN="<YOUR_TOKEN>"
```

Auth header used in all requests:

```bash
-H "Authorization: Bearer $SUPERHUMAN_TOKEN"
```

## API Base

Both base URLs are accepted by the Superhuman Docs API:

```text
https://coda.io/apis/v1
https://docs.superhuman.com/apis/v1
```

Use `https://coda.io/apis/v1` if the `docs.superhuman.com` alias causes network hangs or timeouts.

## URL to ID Mapping
Given a URL like:

```text
https://docs.superhuman.com/d/AB-Theme-Camp-Development_dQ_I7n93cZT/2026-07-28-Theme-Camp-App-Kick-off_suXP6YAs#_lucmxjeC
```

Derive:
- `docId`: from `_d...` suffix in URL path segment => `Q_I7n93cZT`
- `shortPageId`: from `_su...` suffix => `XP6YAs`
- Full REST page ID is typically prefixed as `canvas-...`, discovered via page listing (reliable) instead of guessing

## Fast Incremental Sync (use this first, every time)

Exporting every page (POST export → poll → download) is the expensive path — each
page costs 3+ requests plus poll round-trips. Almost always, most pages haven't
changed since the last sync. Use cheap metadata to find out which ones did
*before* touching the export endpoint at all.

### 1) One call: check the whole doc

```bash
curl -sS -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://coda.io/apis/v1/docs/$DOC_ID" | jq -r '.updatedAt'
```

Compare this to the manifest's top-level `updatedAt`. If it's unchanged,
**stop — nothing in the doc has changed.** No further calls needed.

### 2) One call: list all pages with their `updatedAt`

```bash
curl -sS -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages?limit=100" \
  | jq -r '.items[] | [.id, .name, .updatedAt] | @tsv'
```

Diff each page's `updatedAt` against the corresponding manifest entry's
`remoteUpdatedAt`:
- Unchanged → skip entirely, no export call for this page.
- Changed → add to the (usually short) list of pages to actually export.
- Page id present remotely but missing from the manifest → new/renamed page,
  needs a fresh export and a new manifest entry.
- Manifest entry with no matching remote page id → page deleted or renamed
  remotely; flag for review rather than silently dropping the local file.

This turns "detect nothing changed" into 2 requests total, instead of
3–5 requests × every page in the doc, every single time.

### 3) Only for pages flagged as changed: export

Use the export flow (step 5 below) for just that subset. For a typical sync
where 1–2 pages changed out of 20+, this is the difference between ~60+
requests and ~5.

**Recommended: use the pull helper script** instead of doing steps 3–5 by
hand. `skills/superhuman-rest-fetch/scripts/pull-superhuman-page.sh`
automates export → poll → download → gunzip → normalize → diff-against-local
in one call:

```bash
skills/superhuman-rest-fetch/scripts/pull-superhuman-page.sh \
  --path links.md --doc-id Q_I7n93cZT
```

It's read-only against the local filesystem — it prints a diff and writes
the normalized remote content to a temp file (or `--out <path>`), but never
overwrites your local `.md` file. Deciding what to do with a real diff
(where to insert new content, how to reconcile a structural change) needs
human judgment; the script's job stops at showing you the diff. Exit code
`0` means normalized remote matches local exactly; `1` means it differs
(review the diff); `2` is a real error. See `--help` for `--page-id`/`--url`
targeting and other options.

The rest of this section (steps 4–5, and Full Workflow step 5 below)
describes what the script does under the hood — useful for troubleshooting,
or if you need to do this by hand.

### 4) Normalize before diffing or writing

Coda's markdown export emits a redundant technical header row above the
visible table header, followed by the delimiter row, followed by the real
header row — in the wrong order for a normal markdown table (the delimiter
row must come directly under the *real* header, not above it):

```text
| Column 1 | Column 2 | Column 3 |   <- injected technical row
| --- | --- | --- |                  <- delimiter row (misplaced)
| Name | Role | Notes |              <- the real header
```

Strip the leading `Column N` row **and swap the delimiter row down** so it
sits directly under the real header row, matching how local files in this
repo are actually structured:

```text
| Name | Role | Notes |
| --- | --- | --- |
```

Skipping this normalization (or stripping without swapping) makes every
table page look different from the local file even when nothing actually
moved. The pull helper script does this automatically, for every table on
the page, not just the first.

### 5) Poll without a fixed pre-sleep

Exports are frequently `complete` on the very first status check. Check
immediately; only back off (e.g. 1s, then 2s) if not yet complete, instead of
sleeping a fixed interval before every poll attempt.

## Known Coda Export Transforms

Confirmed by direct A/B diffing against known-unchanged local files. Safe to
auto-normalize (the pull helper script does all three) because they're
consistent, mechanical rendering artifacts of the export pipeline, never
something a human actually typed:

- **Smart quotes**: straight `'`/`"` become curly `'`/`"`/`"`/`"` on export.
- **Identity autolinks**: a bare URL becomes `[url](url)` — text and href
  identical. Only unwrap when they match; a link with different display
  text (e.g. `[My Repo](https://github.com/...)`) is real content, not
  export noise, and must be left alone.
- **Column-N + delimiter swap**: see step 4 above.

**Not safe to auto-normalize — must stay visible in the diff:**
- **Heading-level shifts.** One page was observed with `## Title` in the
  export vs. `# Title` locally, while every *other* heading in that same
  document matched exactly at the same level. This is not a consistent
  transform, so a script cannot tell "export artifact" from "someone changed
  a heading level" — it must be left for a human to judge.
- **The page's own title and any "Parent page:" breadcrumb line.** Coda
  renders a page's `name` and document hierarchy separately from its canvas
  content — they are never present in an export. If your local file opens
  with a `# Title` heading and a "Parent page:"/"Parent document:" line (a
  repo convention, not something Coda stores in the page body), expect the
  diff against a fresh pull to always show those two lines as "local only" —
  that's expected and not a sign of drift, not something to strip from the
  local file.

## Full Workflow (first-time setup, troubleshooting, or no manifest yet)

### 1) Verify token and list docs

```bash
curl -sS \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://coda.io/apis/v1/docs"
```

### 2) Get target document metadata

```bash
DOC_ID="Q_I7n93cZT"
curl -sS \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://coda.io/apis/v1/docs/$DOC_ID"
```

### 3) List pages in the document

```bash
curl -sS \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages"
```

Find the page whose `browserLink` contains `_suXP6YAs` or whose `name` matches your target.
Use its `id` (example: `canvas-h0ExXP6YAs`) as `PAGE_ID`.

### 4) Fetch page metadata

```bash
PAGE_ID="canvas-h0ExXP6YAs"
curl -sS \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages/$PAGE_ID"
```

### 5) Fetch page content (main endpoint)

```bash
curl -sS \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages/$PAGE_ID/content?limit=50&contentFormat=plainText"
```

Response shape:
- `items[]`: ordered content lines/blocks
- `href`: next-page URL with `pageToken` (use when present)

Important: the `/content` endpoint currently supports only `plainText` for `contentFormat`. It is good for verification but does not return the original markdown.

For full markdown export use the async export endpoint:

```bash
curl -sS -X POST \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"outputFormat":"markdown"}' \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages/$PAGE_ID/export"
```

Then poll the returned `href` until `status` is `complete`, then fetch `downloadLink`. Do not add the `Authorization` header to the `downloadLink` request; the URL is pre-signed.

**The `downloadLink` response body is gzip-compressed.** Pipe it through `gunzip -c`, or check for the `1f 8b` magic bytes first if you're not sure — treating it as plain markdown without decompressing first gives you binary garbage, not an error, which is easy to misread as a broken export. (`file <downloaded-file>` will confirm it as "gzip compressed data" if you hit this.)

Caveat: the S3 signed `downloadLink` can be unreachable in some environments, causing a hang if you don't have a timeout on the request.

## Pagination Pattern
If response includes `href`, call it until no additional `href` is returned. If you need the freshest data, add the `X-Coda-Doc-Version: latest` header.

Manual approach:

```bash
NEXT="https://coda.io/apis/v1/docs/$DOC_ID/pages/$PAGE_ID/content?contentFormat=plainText"
while [ -n "$NEXT" ]; do
  RESP=$(curl -sS -H "Authorization: Bearer $SUPERHUMAN_TOKEN" "$NEXT")
  echo "$RESP" | jq -r '.items[]?.itemContent?.content // empty'
  NEXT=$(echo "$RESP" | jq -r '.nextPageLink // empty')
done
```

## Copy/Paste Fetch Script (URL Input)
This script accepts a full Superhuman page URL and fetches resolved page content.

```bash
#!/usr/bin/env bash
set -euo pipefail

URL="$1"
TOKEN="${SUPERHUMAN_TOKEN:?Set SUPERHUMAN_TOKEN first}"
BASE="https://coda.io/apis/v1"

# Extract doc short id from ..._d<docId>
DOC_ID=$(echo "$URL" | sed -n 's#.*_d\([^/]*\).*#\1#p')
# Extract page short id from ..._su<shortPageId>
SHORT_PAGE_ID=$(echo "$URL" | sed -n 's#.*_su\([^#/?]*\).*#\1#p')

if [ -z "$DOC_ID" ] || [ -z "$SHORT_PAGE_ID" ]; then
  echo "Could not parse doc/page IDs from URL" >&2
  exit 1
fi

PAGES_JSON=$(curl -sS -H "Authorization: Bearer $TOKEN" "$BASE/docs/$DOC_ID/pages")

# Resolve actual page id by matching browserLink suffix
PAGE_ID=$(echo "$PAGES_JSON" | jq -r --arg sid "$SHORT_PAGE_ID" '
  .items[] | select(.browserLink | test("_su" + $sid + "$")) | .id
' | head -n1)

if [ -z "$PAGE_ID" ] || [ "$PAGE_ID" = "null" ]; then
  echo "Could not resolve full page id from short page id: $SHORT_PAGE_ID" >&2
  exit 1
fi

NEXT="$BASE/docs/$DOC_ID/pages/$PAGE_ID/content?contentFormat=plainText"
while [ -n "$NEXT" ]; do
  RESP=$(curl -sS -H "Authorization: Bearer $TOKEN" "$NEXT")
  echo "$RESP" | jq -r '.items[]?.itemContent?.content // empty'
  NEXT=$(echo "$RESP" | jq -r '.nextPageLink // empty')
done
```

Usage:

```bash
chmod +x fetch_superhuman_page.sh
./fetch_superhuman_page.sh "https://docs.superhuman.com/d/..."
```

## Known-Good Endpoints
- `GET /apis/v1/docs`
- `GET /apis/v1/docs/{docId}`
- `GET /apis/v1/docs/{docId}/pages`
- `GET /apis/v1/docs/{docId}/pages/{pageId}`
- `GET /apis/v1/docs/{docId}/pages/{pageId}/content`
- `POST /apis/v1/docs/{docId}/pages/{pageId}/export`
- `GET /apis/v1/docs/{docId}/pages/{pageId}/export/{exportId}`
- `GET /apis/v1/mutationStatus/{requestId}`

## Common Errors
- `401 Unauthorized`: token missing/invalid
- `404 Could not find page`: wrong `pageId`; list pages first and use exact `id`
- HTML `Page not found`: wrong base URL; use `/apis/v1/...` not website page routes
- `403 Forbidden` from S3 download URL: you added the `Authorization` header to the pre-signed `downloadLink`; fetch it without auth headers
- Empty content after a write: the mutation is still processing; wait and/or poll `/mutationStatus/{requestId}`
- `429 Too Many Requests`: you exceeded the rate limit for reads or writes; add delays and retry

## Security Notes
- Never commit API tokens
- Prefer environment variables over inline token literals
- Rotate token if exposed in terminal history/logs

## Quick Checklist

For a recurring sync against a known manifest:
1. Set `SUPERHUMAN_TOKEN`
2. `GET /docs/{docId}` — compare `updatedAt` to manifest top-level `updatedAt`; stop if unchanged
3. `GET /docs/{docId}/pages?limit=100` — compare per-page `updatedAt` to manifest `remoteUpdatedAt`
4. For pages flagged as changed, run `pull-superhuman-page.sh --path <path> --doc-id <id>` (exports, normalizes, and diffs against local in one call — see Known Coda Export Transforms above for what it normalizes and what it deliberately leaves for you to judge)
5. Update the manifest — `scripts/check-superhuman-sync.sh --write-manifest`, scoped with `--only <path>` if you're refreshing just the page(s) you reviewed rather than everything

For a one-off fetch from a URL:
1. Set `SUPERHUMAN_TOKEN`
2. Resolve `DOC_ID` and `SHORT_PAGE_ID` from URL
3. List pages to resolve canonical `PAGE_ID`
4. Fetch `/content`
5. Follow `nextPageLink` for pagination
