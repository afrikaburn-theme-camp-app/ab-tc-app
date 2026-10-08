# Superhuman Sync Push Skill

## Purpose
Push **selected** local documentation into Superhuman Docs via the REST API,
using the repo's sync conventions and baseline manifest for page mapping.

**This is the minority sync direction.** The default is Superhuman → local
(audit + pull). Use push only for light editing, formatting, cleanup, or
notetaking — e.g. new meeting notes or group-discussion capture that adds
information Superhuman does not have yet, or that should update a decision.
Do not use this skill to force large App Spec rewrites from git onto Superhuman
without working-group consensus on Superhuman first.

## Scope
- Create new Superhuman pages for new local files that meet the push criteria above
- Update existing Superhuman pages when a deliberate light local change should land remotely
- Preserve the local sync manifest as the record of the last accepted baseline
- Work with the existing local naming convention and page mapping used by the sync audit tool

## What This Skill Does Not Do
- It does not use MCP.
- It does not replace the pull-dominant workflow; prefer `superhuman-sync-audit` + `superhuman-rest-fetch`.
- It does not modify unrelated cloud pages.
- It does not sync `AGENTS.md` or anything under `skills/` to Superhuman.
- It does not bypass review: a push should only happen after a local audit has established what changed, and only for content that is appropriate to push.
- It does not guarantee immediate visibility: mutations are asynchronous and may take a few seconds to appear.

## Requirements
- `curl`
- `jq`
- Bash on macOS or Linux
- A valid Superhuman API token in `SUPERHUMAN_TOKEN`
- A current local manifest from `./scripts/check-superhuman-sync.sh --write-manifest` or equivalent

Set the token once per session:

```bash
export SUPERHUMAN_TOKEN="<YOUR_TOKEN>"
```

**⚠️ In an agent/subshell environment, this does not persist across separate command invocations.** Many tool-calling harnesses (including Claude Code's Bash tool) start a fresh shell per call — `export` in one call is gone by the next, and every following script/curl call fails with **401 Unauthorized** even though the token itself is valid. This looks like an auth or permissions problem but isn't. Fix: `export SUPERHUMAN_TOKEN=...` in the *same* command as every script or curl call that uses it (e.g. `export SUPERHUMAN_TOKEN="..." && ./scripts/check-superhuman-sync.sh ...`), or pass `--token` explicitly each time instead of relying on the environment.

## API Base

Use either base URL:

```text
https://coda.io/apis/v1
https://docs.superhuman.com/apis/v1
```

Note the two scripts default to different ones — `check-superhuman-sync.sh` defaults to `docs.superhuman.com`, `push-superhuman-page.sh` defaults to `coda.io`. Both work, but when writing a manual `curl` call, match whichever base URL the script output for that call is using rather than assuming.

Prefer `https://coda.io/apis/v1` if you experience network hangs on writes.

## Rate Limits

Writing doc content is limited to **5 requests per 10 seconds**. Sleep at least 2.5 seconds between content write calls. Reading is 100 requests per 6 seconds.

## Local Files Used
- `scripts/check-superhuman-sync.sh`: identifies what changed, and refreshes the baseline
- `skills/superhuman-sync-push/scripts/push-superhuman-page.sh`: pushes an existing file's
  content to its page (see "Recommended: use the push helper script" below)
- `.superhuman-sync-manifest.json`: records the accepted baseline and page IDs

## Recommended Workflow

**Recommended: use the push helper script** for updating an existing page,
instead of the manual `curl -X PUT` / poll / verify / refresh sequence below.
It **defaults to a dry run** — no writes happen unless you pass `--yes` —
and it refuses to push (the whole batch, before touching anything) if any
target page changed remotely since your last accepted baseline, unless you
pass `--force`:

```bash
# Preview only — no writes:
skills/superhuman-sync-push/scripts/push-superhuman-page.sh links.md --doc-id Q_I7n93cZT

# Actually push, after reviewing the preview:
skills/superhuman-sync-push/scripts/push-superhuman-page.sh links.md --doc-id Q_I7n93cZT --yes
```

It handles PUT → poll `mutationStatus` → verify `updatedAt` advanced →
refresh the manifest baseline for just that file (via `--only`, see step 6
below) — all in one call, with retry on a transient 5xx/non-JSON response
and rate-limit sleeps between multiple files. It does not create new pages
(steps 3 below cover that manually) — every path must already have a
manifest entry.

The rest of this workflow describes what the script does under the hood —
useful for troubleshooting, creating a brand-new page, or doing this by
hand.

### 1) Audit first
Run the sync audit before pushing.

```bash
./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root .
```

Review the output for:
- `unchanged`
- `remote-changed`
- `untracked`
- `local-only`
- `remote-only`

### 2) Decide what to push
Only push files that you explicitly want Superhuman to accept as the new remote
state, **and** that fit the light-edit / notes criteria (formatting, cleanup,
new meeting minutes, discussion capture, or a small decision follow-up). If the
change is a major product-intent rewrite, edit on Superhuman instead and pull.

### 3) Push new files

For a new local file, create a new page in the target doc using the REST page creation endpoint and set:
- page name from the local filename or title
- page content from the file contents
- parent page when the document structure requires nesting

Create a new page:

```bash
DOC_ID="Q_I7n93cZT"
TITLE="Decision 002"
CONTENT=$(cat decisions-record/decision-002-proposed-architecture-integration-strategy-open-pending-org-feedback.md)

curl -sS -X POST \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg name "$TITLE" \
    --arg content "$CONTENT" \
    '{name: $name, content: {type: "canvas", canvasContent: {format: "markdown", content: $content}}}')" \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages"
```

Response includes the new `id` (e.g. `canvas-p9rn9X0k0_`) and a `requestId` for async tracking.

**Always verify content landed — do not assume it did.** In practice the page is often created empty even after the mutation reports `completed: true`. After every creation, poll the mutation, then fetch the page content (see Verification below) and confirm it's non-empty before moving on. If it's empty, immediately follow up with a PUT update using `contentUpdate` (same payload shape as step 4 below) and re-verify.

**Register the new page in the manifest — this does not happen automatically.** `check-superhuman-sync.sh` can only recognize a local file as matching a remote page via (a) an existing manifest `pageId` entry, (b) a Local-Sync naming-convention match, or (c) a filename-derived fallback title (dashes/underscores → spaces, each word capitalized) matched against the page's exact `name`. A freshly created page will keep showing as `local-only` until one of those matches, and titles written for readability (e.g. `"2026-09-10 Graeme - Payment and Portal Vision Messages"`) will *not* match the fallback algorithm's output (e.g. `"2026 09 10 Graeme Payment And Portal Vision Messages"`). Don't chase a title that satisfies the fallback matcher — just add the manifest entry directly once you have the page's `id` and `updatedAt`:

```bash
NEW_PATH="meeting-minutes/2026-09-10-example.md"
PAGE_ID="canvas-9juDdKVm_n"      # from the create response
PAGE_NAME="2026-09-10 Example"   # the title you actually set
UPDATED_AT=$(curl -sS -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://docs.superhuman.com/apis/v1/docs/$DOC_ID/pages/$PAGE_ID" | jq -r '.updatedAt')

jq --arg path "$NEW_PATH" --arg id "$PAGE_ID" --arg name "$PAGE_NAME" \
   --arg ts "$UPDATED_AT" --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   '.entries[$path] = {pageId: $id, pageName: $name, remoteUpdatedAt: $ts, lastCheckedAt: $now}' \
   .superhuman-sync-manifest.json > /tmp/manifest.json && mv /tmp/manifest.json .superhuman-sync-manifest.json
```

Re-run the audit afterward to confirm the file now reports `unchanged` rather than `local-only`.

To create a nested subpage, include `parentPageId` at creation time. The update endpoint does **not** support moving pages:

```bash
PARENT_ID="canvas-gAser6I8bD"

curl -sS -X POST \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg name "$TITLE" \
    --arg parent "$PARENT_ID" \
    --arg content "$CONTENT" \
    '{name: $name, parentPageId: $parent, content: {type: "canvas", canvasContent: {format: "markdown", content: $content}}}')" \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages"
```

### 4) Push updates to existing files

For a file that already maps to a page:
- update page metadata only if required
- replace page content using the REST page update/content update flow
- keep the manifest page ID stable

Update an existing page:

```bash
PAGE_ID="canvas-aGNoWH_Wp3"
TITLE="App Specification"
CONTENT=$(cat app-specification.md)

curl -sS -X PUT \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg name "$TITLE" \
    --arg content "$CONTENT" \
    '{name: $name, contentUpdate: {insertionMode: "replace", canvasContent: {format: "markdown", content: $content}}}')" \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages/$PAGE_ID"
```

Note the difference:
- **POST create** uses `content.canvasContent`
- **PUT update** uses `contentUpdate.canvasContent`

### 5) Handle asynchronous mutations

Write endpoints return a `requestId` when the mutation is queued. Poll for completion or simply wait a few seconds before verifying:

```bash
REQUEST_ID="mutate:..."
curl -sS \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://coda.io/apis/v1/mutationStatus/$REQUEST_ID"
```

Expected response: `{"completed": true}`. Content may not be visible via the API until the mutation completes.

### 6) Refresh the baseline (mandatory) — scoped to what you actually pushed
After a successful push, immediately update the manifest to record the new baseline. This is required to prevent a false "remote-changed" alert on the next audit — the push itself moved the page's `updatedAt`, so without a refresh the very next check would flag your own push as an unreviewed remote change.

**Scope the refresh with `--only`** — do not run a bare `--write-manifest`
after a partial push. A whole-manifest refresh also accepts the current
remote state of every *other* tracked file as the new baseline, including
any that changed remotely for reasons you never reviewed. (This is exactly
what almost happened in practice: pushing 3 of ~23 tracked files, then
running a bare `--write-manifest`, would have silently accepted an
unrelated, unreviewed remote edit on a file that was never touched by that
push.) Scope it to just the file(s) you pushed instead:

```bash
./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root . \
  --only links.md --write-manifest
# repeat --only for each additional file pushed in the same batch
```

This makes one cheap page-listing call (no export, no S3 download) and
records the current `remoteUpdatedAt` for each `--only`'d file — every other
manifest entry is left untouched. The push helper script does this
automatically after each successful push; only do it by hand if you pushed
manually. At minimum the manifest entry for each synced file should record:
- `pageId`
- `pageName`
- `remoteUpdatedAt`
- `lastCheckedAt`

If you can't run the script, update these fields directly in the manifest by hand — fetch `GET /docs/{docId}/pages` and copy each pushed page's `updatedAt` into its `remoteUpdatedAt`, leaving every other entry untouched.

## Verification

Spot-check pushed content with the direct content endpoint:

```bash
PAGE_ID="canvas-2tqFDK4pNV"
curl -sS -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages/$PAGE_ID/content?limit=50&contentFormat=plainText"
```

## Resolving `remote-changed` Drift Before Using `--force`
The audit and push script only compare `updatedAt` timestamps — they cannot tell you *what* changed remotely, and `--force` will silently clobber it. Don't force blind. Before forcing:

1. Pull the live remote content with the Verification endpoint above (use the flagged page's `pageId` from the audit output).
2. Compare it against your local file's content *from before your current edits* (e.g. `git show HEAD:path/to/file.md`, or the version you started from). If they match, the drift is a metadata-only touch (a rename, a view, an internal timestamp bump) and `--force` is safe.
3. If they don't match, treat it as a real conflict: pull the remote wording into your local file (or vice versa) and resolve it manually before pushing — do not force over unreviewed content.

## Push Rules
- Prefer page ID-based updates over name-based updates.
- If a page was renamed in Superhuman, keep the manifest page ID and update the local mapping instead of creating duplicates.
- If the file is new locally and no page exists, create a new page rather than overloading an unrelated page.
- If the file changed locally and remotely, resolve the conflict before pushing.
- **Avoid duplicate pages**: list existing pages first. The API allows multiple pages with the same name, so name matching alone is not enough to guarantee idempotency.
- **Content at creation is not always immediate**: when creating a page with content in the same POST call, verify the content appears; if not, send a separate PUT update with `contentUpdate`.
- **Nesting can only be set at creation**: `parentPageId` is only accepted in the `POST /pages` create payload. To move an existing page, delete it and recreate it under the desired parent.
- **Respect rate limits**: writing doc content is 5 requests per 10 seconds; sleep ~2.5 seconds between calls.

## Suggested Mapping Strategy
1. Use `pageId` from the manifest when available.
2. Fall back to page-name matching only when the manifest does not yet know the page.
3. Use the repository filename to generate a stable page title when creating new pages.

## Document Structure and Nesting
The Superhuman document follows a hierarchical structure where related pages are nested under parent pages:

- **Welcome** (top-level)
- **App Specification** (parent)
  - App Spec Change Record (child)
  - Gap analysis documents (children)
- **Decisions Record** (parent)
  - Decision 001-013 (children)
- **Meeting Minutes** (parent)
  - Individual meeting minutes (children)
- **Task Assignment** (top-level)
- **Member List** (top-level)
- **Links** (top-level)

### Creating Nested Pages
When creating a new page that belongs under a parent, include `parentPageId` in the POST request:

```bash
PARENT_ID="canvas-gAser6I8bD"  # Decisions Record

curl -sS -X POST \
  -H "Authorization: Bearer $SUPERHUMAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg name "$TITLE" \
    --arg parent "$PARENT_ID" \
    --rawfile content "$FILE" \
    '{name: $name, parentPageId: $parent, content: {type: "canvas", canvasContent: {format: "markdown", content: $content}}}')" \
  "https://coda.io/apis/v1/docs/$DOC_ID/pages"
```

**Important**: Nesting can only be set at creation time. The update endpoint does not support moving pages. To change a page's parent, delete it and recreate it under the desired parent.

### Parent Page Mapping
Use this mapping when creating new pages:

| Local File Path | Parent Page | Parent Page ID |
|----------------|-------------|----------------|
| `decisions-record/decision-*.md` | Decisions Record | `canvas-gAser6I8bD` |
| `app-specification/*.md` | App Specification | `canvas-aGNoWH_Wp3` |
| `meeting-minutes/*.md` | Meeting Minutes | `canvas-Fp4_lYBb3r` |
| `welcome.md` | (top-level) | - |
| `app-specification.md` | (top-level) | - |
| `decisions-record.md` | (top-level) | - |
| `task-assignment.md` | (top-level) | - |
| `member-list.md` | (top-level) | - |
| `links.md` | (top-level) | - |

## Common Push Outcomes
- `created`: a new cloud page was created for a new file
- `updated`: an existing page content was replaced with local content
- `skipped`: the local and remote versions already match
- `blocked`: the file is in conflict and needs manual resolution first
- `pending`: the API accepted the request but the mutation is still processing; verify content after a short delay

## Safety Notes
- Never push `AGENTS.md` to Superhuman.
- Never push any file under `skills/` to Superhuman.
- Keep the manifest local until the push is intentionally accepted.
- Prefer small, targeted pushes so changes are easy to verify.
- Do not include the `Authorization` header when fetching S3 export download links; those URLs are self-authenticating.

## Example Checks

```bash
# Audit before pushing
SUPERHUMAN_TOKEN="$SUPERHUMAN_TOKEN" ./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root .

# Preview a push (dry run, no writes) via the helper script
SUPERHUMAN_TOKEN="$SUPERHUMAN_TOKEN" skills/superhuman-sync-push/scripts/push-superhuman-page.sh links.md --doc-id Q_I7n93cZT

# Actually push, then refresh just that file's baseline (the script does this automatically)
SUPERHUMAN_TOKEN="$SUPERHUMAN_TOKEN" skills/superhuman-sync-push/scripts/push-superhuman-page.sh links.md --doc-id Q_I7n93cZT --yes

# Manual equivalent of the scoped baseline refresh, if you pushed by hand
SUPERHUMAN_TOKEN="$SUPERHUMAN_TOKEN" ./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root . --only links.md --write-manifest
```

## Checklist
1. Run the audit.
2. Confirm which files should be pushed.
3. Push via the helper script (dry run first, then `--yes`) for existing pages; create new pages manually (step 3 above).
4. Verify the cloud content.
5. Refresh the manifest scoped to what you pushed (`--only`) — the helper script does this automatically.
