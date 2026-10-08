# Superhuman Sync Audit Skill

## Purpose
Compare local documentation files against Superhuman Docs pages via REST API, identify remote drift, and maintain a sync manifest that records the last known remote baseline.

Run this **first** in the normal Superhuman → local loop. Push is secondary (see `superhuman-sync-push`).

## Scope
- Detect whether local docs have a matching cloud page and whether that page changed since the last check
- Report `local-only`, `remote-only`, `untracked`, `unchanged`, and `remote-changed` states
- Use page metadata only (`updatedAt`) for comparison — no export or content download
- Maintain a local manifest for baseline tracking

## What This Skill Does Not Do
- It does not use MCP.
- It does not modify Superhuman Docs content directly.
- It does not sync `AGENTS.md` or anything under `skills/` to Superhuman.
- It does not detect local-side drift (a local file edited since it was last pulled/pushed) — that's `git status` / `git diff`'s job, not this script's. This skill only tracks the remote side.
- It does not tell you *what* changed on a `remote-changed` page — only that it did. Use the `superhuman-rest-fetch` skill to pull and review the actual content.

## Requirements
- `curl`
- `jq`
- Bash on macOS or Linux
- A valid Superhuman API token in `SUPERHUMAN_TOKEN`

Set the token once per session:

```bash
export SUPERHUMAN_TOKEN="<YOUR_TOKEN>"
```

## Local Files Used
- `scripts/check-superhuman-sync.sh`: main sync audit utility
- `.superhuman-sync-manifest.json`: local baseline manifest

## API Base

The Superhuman Docs API is available at both of these bases:

```text
https://coda.io/apis/v1
https://docs.superhuman.com/apis/v1
```

Use `https://coda.io/apis/v1` if you see network hangs with the `docs.superhuman.com` alias.

## How the Check Works

The script makes exactly one kind of network call: `GET /docs/{docId}/pages`, paginated if needed. That single response carries every page's `updatedAt`. For each local file, the script:
1. Resolves the matching remote page (see Remote Conventions below).
2. Compares that page's `updatedAt` against the manifest's recorded `remoteUpdatedAt`.
3. Classifies the result — no export, no download, no hashing.

This means the script never touches the export/S3-download path, so it isn't subject to the export timeouts that can affect a manual pull. It also means it can't tell you *what* changed — only *that* something did. For that, pull and diff the page's content directly (see the `superhuman-rest-fetch` skill).

## Remote Conventions
The sync checker matches cloud pages using these strategies:
1. Manifest `pageId` when available
2. Cloud page names that follow `Local Sync :: <relative/path>`
3. Filename-to-title fallback, such as `links.md` -> `Links`

## Recommended Workflow

### 1) Run a read-only audit

```bash
./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root .
```

### 2) Review the report
Possible states:
- `unchanged` — remote `updatedAt` matches the manifest; nothing to do
- `remote-changed` — remote `updatedAt` moved since the manifest was last written; pull and review before accepting
- `untracked` — a matching remote page exists but the manifest has no baseline for it yet (first time seeing this pairing)
- `local-only` — no cloud page matched the local file
- `remote-only` — a cloud page under the `Local Sync ::` naming convention has no matching local file

### 3) Pull and reconcile anything `remote-changed` or `untracked`
Use the `superhuman-rest-fetch` skill to export, normalize, and diff the actual content before deciding what — if anything — to change locally.

### 4) Accept a baseline when appropriate

```bash
./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root . --write-manifest
```

Use this only when you intentionally want the current remote state to become the new baseline (e.g. after reconciling a `remote-changed` page, or immediately after a push — see the `superhuman-sync-push` skill).

**Scope it with `--only <path>`** (repeatable) when you've only reviewed some
of the changed files — e.g. right after pushing a subset of tracked files.
A bare `--write-manifest` accepts the current remote state of *every*
tracked file as the new baseline, including any that changed for reasons
you never looked at:

```bash
./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root . \
  --only links.md --write-manifest
```

This is what the `superhuman-sync-push` skill's push helper script uses
internally after each successful push, so a partial push never silently
accepts unrelated, unreviewed remote drift as part of its own baseline
refresh. `--only` doesn't override the default excludes (`AGENTS.md`,
`skills/**`, `scripts/**`) — a path dropped by those never reaches
classification in the first place.

### 5) Re-run after cloud edits
When a page is edited in Superhuman, run the checker again to detect remote drift.

## Manifest Notes
The manifest should remain local and versioned as a baseline record. A typical entry records:
- `pageId`
- `pageName`
- `remoteUpdatedAt`
- `lastCheckedAt`

There is deliberately no content hash of any kind in the manifest. `remoteUpdatedAt` — a timestamp the Coda API actually returns — is the only drift signal this tooling relies on. A hash computed locally over an exported/normalized page was tried and dropped: it wasn't reproducible across sessions (Coda transforms markdown on export in ways not fully documented — smart quotes, autolinked URLs, an injected technical table-header row, heading-level shifts), so it produced false positives and negatives instead of the reliability a hash is supposed to buy. Local-side drift (has the file on disk changed) is git's job, not the manifest's — `git status` / `git diff` answers that directly for a tracked file, so there's nothing left for a local hash to do here either.

## Sync Safety Rules
- Never sync `AGENTS.md` to Superhuman.
- Never sync any file under `skills/` to Superhuman.
- Prefer explicit baseline updates over automatic manifest writes.
- Use `X-Coda-Doc-Version: latest` when you want the freshest read and can tolerate an error if the snapshot is stale.
- Respect rate limits: reading is 100 requests per 6 seconds; writing doc content is 5 requests per 10 seconds.

## Common Failure Modes
- `local-only`: no cloud page matched the local file path or title
- `remote-only`: cloud page exists without a local file
- `untracked`: there is a matching cloud page, but no manifest baseline exists yet — not necessarily a problem, just means this pairing hasn't been through `--write-manifest` before

## Example Checks

```bash
# Dry run
SUPERHUMAN_TOKEN="$SUPERHUMAN_TOKEN" ./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root .

# Write baseline after accepting current state (everything)
SUPERHUMAN_TOKEN="$SUPERHUMAN_TOKEN" ./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root . --write-manifest

# Write baseline for just one file (e.g. after reviewing/pushing only that one)
SUPERHUMAN_TOKEN="$SUPERHUMAN_TOKEN" ./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root . --only links.md --write-manifest
```

## Checklist
1. Confirm the target doc ID.
2. Run the audit in read-only mode.
3. Pull and review anything reported `remote-changed` or `untracked`.
4. Update the manifest only when the current remote state is accepted as the new baseline.
5. Re-run after cloud edits to detect drift.
