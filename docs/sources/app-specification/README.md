# App Specification (Superhuman sync home)

This directory is the **local working copy** of the AfrikaBurn Theme Camp App
Specification corpus. It used to live in the standalone `ab-app-docs` repository;
**this tree is now the only home**. Superhuman remains the collaborative surface
for the working group; git is the auditable engineering record.

## Sync direction (read this first)

**Dominant direction is Superhuman → local.** Product discussion, decisions, and
spec edits happen on Superhuman; we pull them down into this tree so the monorepo
stays current. Treat remote as the usual source of truth for content.

**Push (local → Superhuman) is the minority path.** Use it only for light work
that does not rewrite product intent in bulk, for example:

- formatting and cleanup
- notetaking
- adding **new meeting notes** or capturing **group discussions** that introduce
  information Superhuman does not have yet
- small follow-ups when those notes **affect a decision** (and the change is
  reflected in the decision / change-record paper trail)

Do **not** treat git as the place to author major App Spec rewrites and then
force them up. Prefer editing on Superhuman, then pull. When in doubt: pull and
reconcile first; push only what you deliberately want the working group to see.

> **Authoritative Superhuman doc:**  
> https://docs.superhuman.com/d/AB-Theme-Camp-Development_dQ_I7n93cZT/App-Specification_suoUXVqN  
> **Doc ID:** `Q_I7n93cZT`

Product intent is governed by `app-specification.md` (and the Superhuman page it
maps to). Engineering specs under `docs/*.md` are **downstream** — see
[`../../README.md`](../../README.md).

## Layout

| Path | Role |
| ---- | ---- |
| `welcome.md` | Entry page — two-sentence product intro and links to the other root pages |
| `app-specification.md` | Current product/feature baseline |
| `decisions-record.md` + `decisions-record/` | Product decisions (WHAT/WHY) — not engineering HOW |
| `task-assignment.md` | Tombstone — tasks are not tracked in this corpus |
| `member-list.md`, `links.md` | People and references |
| `app-specification/` | Change record (**`app-specification.md` only**) + requirement index |
| `meeting-minutes/` | Meeting notes mirrored from Superhuman |
| `.superhuman-sync-manifest.json` | Accepted remote baseline (page IDs + `updatedAt`) |
| `scripts/check-superhuman-sync.sh` | Metadata-only audit / baseline write |
| `skills/` | Agent/human runbooks + pull/push helpers |
| `AGENTS.md` | Conventions for editing **this** corpus (not the whole monorepo) |

**Not synced to Superhuman:** `AGENTS.md`, `skills/**`, `scripts/**`, this
`README.md`.

## Auth

Scripts read **`SUPERHUMAN_TOKEN`** (or `--token`). Export it yourself in the
shell before running anything:

```bash
export SUPERHUMAN_TOKEN="<token from Superhuman/Coda account settings>"
```

Do **not** commit the token. Prefer a personal access token with docs read/write
only. Agent shells often do not inherit exports across invocations — pass the
token in the **same** command as the script, or use `--token` every time.

API base (either works; prefer Coda if Superhuman hostname hangs):

```text
https://coda.io/apis/v1
https://docs.superhuman.com/apis/v1
```

Requires: `bash`, `curl`, `jq` (and `perl` for full pull normalization).

## Working directory

All relative paths in skills and the manifest are rooted **here**:

```bash
cd docs/sources/app-specification
```

## Common commands

Default loop is **audit → pull → reconcile locally → accept baseline**. Push is
optional and uncommon.

```bash
# 1) Audit (metadata only — does not download page bodies)
./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root .

# 2) Pull pages that are remote-changed (never overwrites local; prints a diff)
./skills/superhuman-rest-fetch/scripts/pull-superhuman-page.sh \
  --path app-specification.md --doc-id Q_I7n93cZT

# 3) After you intentionally accept remote (or finished reconciling), refresh baseline
./scripts/check-superhuman-sync.sh --doc-id Q_I7n93cZT --root . \
  --only app-specification.md --write-manifest

# 4) Occasional push — light edits / notes only (dry run, then --yes)
./skills/superhuman-sync-push/scripts/push-superhuman-page.sh \
  meeting-minutes/2026-09-10-example.md --doc-id Q_I7n93cZT
./skills/superhuman-sync-push/scripts/push-superhuman-page.sh \
  meeting-minutes/2026-09-10-example.md --doc-id Q_I7n93cZT --yes
```

Full workflows: `skills/superhuman-sync-audit` and `skills/superhuman-rest-fetch`
first; `skills/superhuman-sync-push` only when the push criteria above apply.

## Relationship to the rest of `docs/sources/`

Sibling folders (`quaggapedia/`, `afrikaburn-org/`, scope briefs) are **verbatim
one-way mirrors** — never edited to match the product.

**This folder is different:** it syncs with Superhuman. **Pull dominates**; push
is allowed for light edits, formatting, cleanup, and notetaking (including new
meeting notes or discussion capture that may touch a decision). Keep the change
record and decision paper trail per `AGENTS.md`.

## Legacy

The standalone `ab-app-docs` repo is **legacy**. Do not treat it as canonical
after this tree is committed. Point collaborators here instead.
