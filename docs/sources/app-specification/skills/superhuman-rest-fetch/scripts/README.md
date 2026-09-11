# Scripts

This skill uses `pull-superhuman-page.sh`. It exports a page, decompresses
and normalizes the result (stripping the injected `Column N` table header,
reverting smart quotes, unwrapping identity autolinks), and diffs it against
the corresponding local file. Read-only against the local filesystem — it
never writes to the local `.md` file, only to a temp file (or `--out`). See
the skill's `SKILL.md` for full usage.
