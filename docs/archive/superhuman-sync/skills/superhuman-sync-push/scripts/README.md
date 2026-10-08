# Scripts

This skill uses `push-superhuman-page.sh`. It reads the local sync manifest
to resolve each path's target page, defaults to a dry run (no writes) and
requires an explicit `--yes` to mutate Superhuman Docs, and verifies the
page's `updatedAt` actually advanced before refreshing the manifest baseline
(scoped to just the file(s) pushed, via `check-superhuman-sync.sh --only`).
See the skill's `SKILL.md` for full usage.
