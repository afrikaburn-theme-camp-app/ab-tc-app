# Skills Directory

This directory stores reusable, self-contained skills.

**Working directory for all Superhuman skills:** the parent of this
folder — `docs/sources/app-specification/` in the `ab-tc-app` monorepo
(`cd` there before running scripts; relative paths and the sync manifest
are rooted there).


## Structure

- `skills/<skill-slug>/SKILL.md`: Main skill instructions
- `skills/<skill-slug>/scripts/`: Optional automation scripts
- `skills/<skill-slug>/examples/`: Example requests/responses
- `skills/_templates/skill-template/`: Starter template for new skills

## Naming Conventions

- Use lowercase kebab-case for skill folder names.
- Keep one skill per folder.
- Keep examples and scripts scoped to their skill.

## Recommended Workflow

1. Copy `skills/_templates/skill-template` to a new folder.
2. Fill out `SKILL.md` with purpose, prerequisites, workflow, errors, and security notes.
3. Add scripts only when they are repeatable and safe.
4. Add examples for common and edge-case usage.

## Current Skills

**Default order:** audit → pull. Push is secondary (light edits / notes only).

- `superhuman-sync-audit`: Compare local docs against Superhuman pages and maintain a sync baseline (start here).
- `superhuman-rest-fetch`: Fetch Superhuman documents/pages using REST API only (dominant direction: remote → local).
- `superhuman-sync-push`: Push local content into Superhuman — **only** for light editing, formatting, cleanup, or notetaking (e.g. new meeting notes or discussions that add information or affect a decision), not bulk product-intent authorship from git.
