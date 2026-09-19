# AGENTS.md

## Mission
This folder (`docs/sources/app-specification/` inside the `ab-tc-app` monorepo) is
the intelligence memory and architecture log for the Theme Camp App product
specification. It is the Superhuman ↔ git sync root (see `README.md` here).
**Sync is pull-dominant:** Superhuman → local is the default; push only for light
edits, formatting, cleanup, or notetaking (e.g. new meeting notes / discussions
that add information or affect a decision). The monorepo root `AGENTS.md`
governs engineering process for the apps; **this file governs only the App
Specification corpus.**

Its purpose is to:
- Preserve feature intent, decisions, and constraints so information is not lost.
- Keep specifications aligned with implementation goals.
- Reduce product drift through frequent gap analysis.
- Maintain auditable ownership and chronology for every meaningful update.

If a change cannot be traced, linked, and justified, it is incomplete.

## Documentation Principles
- **Operational vs engineering decisions:** this corpus records **operational** decisions — WHAT we build, for whom, and WHY, at a product/working-group level. Technical detail that could influence implementation belongs in `docs/technical-spec/` (research, until it is a built feature). Engineering **HOW** decisions live in `docs/engineering-decisions/`, not here.
- **No task tracking in this corpus.** Engineering work is tracked via GitHub issues on [afrikaburn-theme-camp-app/ab-tc-app](https://github.com/afrikaburn-theme-camp-app/ab-tc-app). `task-assignment.md` is a tombstone so historical links resolve.
- Single source of truth by topic: each topic has one primary file.
- Chronological traceability: changes are logged in append-only records.
- Linkability: all major entries point to related specs, decisions, and references.
- Ownership clarity: every non-trivial entry includes author and date metadata.
- Retrieval-first writing: use clear headings and predictable formats.

## Repository Structure

### Top-level thematic files
- `welcome.md`: Entry page — two-sentence product intro and links to the other root pages.
- `app-specification.md`: Current product and feature specification baseline.
- `decisions-record.md`: Index of **operational** (WHAT/WHY) decisions.
- `task-assignment.md`: Tombstone — tasks are not tracked here.
- `member-list.md`: Team roles and contributor reference.
- `links.md`: Canonical references to internal and external resources.

### Chronological and detailed records
- `app-specification/app-spec-change-record.md`: Append-only timeline of **`app-specification.md` changes only**.
- `decisions-record/decision-###-<status>-<short-title>.md` (e.g. `decision-001-accepted-decision-record-format.md`): Detailed decision entries.

### Skills and operational helpers
- `skills/`: Reusable execution guides and templates.
- `skills/_templates/skill-template/`: Template for creating future skills.

## Navigation Rules
- Start with `welcome.md` for the product at a glance and links to the other root pages.
- Use the other top-level files to understand the current state of each topic.
- Use subfolders for history and detailed records.
- Keep one concern per file; avoid mixed-topic dumping.
- Prefer adding linked records over rewriting historical context.

## Required Contribution Workflow

### 1) Classify the change
Before editing, determine the change type:
- Specification change
- New operational (product) decision
- Team/member update
- Reference/link update

### 2) Update the source-of-truth file
Edit the thematic primary file first:
- Spec content -> `app-specification.md`
- Decision summary/index -> `decisions-record.md`
- Members -> `member-list.md`
- References -> `links.md`
- Technical research / HOW -> `docs/technical-spec/` or `docs/engineering-decisions/` (not this corpus)

### 3) Append a chronological record (when the topic has one)
- **`app-specification.md` changed** → append to `app-specification/app-spec-change-record.md`. That file is **only** the log of why the official spec changed. Do not put meeting minutes, decision-record updates, member-list or links edits, task-assignment, Welcome, or other corpus housekeeping in it.
- **Decision-related changes** → create or update a `decisions-record/decision-XXX.md` file and reference it from `decisions-record.md`.
- Member-list, links, meeting minutes, and Welcome updates live in those files. They do **not** get a Change Record entry.

Do not delete prior *spec* log entries. Corrections should be new entries that reference the older entry. Entries that never belonged (non-spec events) should be removed rather than left to imply the spec changed when it did not.

### 4) Link related artifacts
Every substantial change should link to related records:
- Spec entry links to decision(s) and references.
- Decision entry links to affected spec sections.
- Do not add task lists to this corpus.

### 5) Validate discoverability
Before finalizing, verify:
- A future contributor can find this update by topic and by date.
- Ownership is clear.
- Rationale is clear.
- Related artifacts are cross-linked.

## Metadata Standard (Use In New Entries)
Add this metadata block at the top of new decision files and major log entries:

```yaml
id: <unique-id>
title: <short descriptive title>
date: YYYY-MM-DD
author: <name>
status: draft|active|superseded|archived
type: spec-change|decision|task-update|reference-update
related:
  - <path-or-id>
  - <path-or-id>
tags:
  - <feature>
  - <domain>
```

## Chronological Paper Trail Standard

### Spec change record entry template
Use this template for entries in `app-specification/app-spec-change-record.md`:

```md
## YYYY-MM-DD - <Change Title>
Owner: <name>
Type: spec-change
Status: active|superseded
Related: <link/id list>

### What changed
- ...

### Why it changed
- ...

### Impact
- Affected features:
- Affected decisions:

### Validation / Gap Analysis
- Expected outcome:
- Drift risk addressed:
- Follow-up checks:
```

### Decision record template
Use this structure in each `decisions-record/decision-XXX.md` file:

```md
# Decision XXX: <Title>
Date: YYYY-MM-DD
Owner: <name>
Status: proposed|accepted|rejected|superseded
Related: <link/id list>

## Context
...

## Decision
...

## Alternatives considered
...

## Consequences
- Positive:
- Negative:
- Risks:

## Follow-up
- Review date:
```

Decision records stay **operational**. Do not put GIS formats, stack choices, or implementation contracts in them — those go to `docs/technical-spec/` (research) or `docs/engineering-decisions/` (HOW). Do not list people-to-do items; this corpus does not track tasks.

## Naming and Organization Conventions
- Keep filenames lowercase and kebab-case where possible.
- Use stable numeric IDs in filenames: `decision-001-<status>-<short-title>.md`, `decision-002-<status>-<short-title>.md`, etc.
- Never repurpose an existing decision ID for a different decision.
- Add new files rather than overloading existing ones with unrelated content.

## Editing Rules
- Preserve historical meaning; avoid silent rewrites of rationale.
- If intent changes, record the reason and timestamp in the log.
- Keep summaries concise and **implementation-neutral**. Technical detail belongs in `docs/technical-spec/`.
- Use explicit dates in ISO format: `YYYY-MM-DD`.
- **Synced pages must not link outside this corpus.** This tree is mirrored to Superhuman, so up-tree relative paths (`../..`, `../../..`) break there. Reference anything outside the corpus (`docs/technical-spec/`, `docs/engineering-decisions/`, repo files) with an **absolute URL** (e.g. a GitHub `blob/main` link). Ordinary in-corpus body links may stay relative. **`welcome.md` is Superhuman-first:** its root-page list MUST use each page's Superhuman `browserLink` (`https://docs.superhuman.com/d/_dQ_I7n93cZT/_su…`), not repo-relative `.md` paths — Coda does not resolve those.

## Superhuman Sync Direction and Exclusions

### Direction
- **Default:** pull Superhuman → local (`superhuman-sync-audit` +
  `superhuman-rest-fetch`). Prefer changing product intent on Superhuman.
- **Push only when:** light editing, formatting, cleanup, or notetaking —
  especially new meeting minutes or group-discussion capture that adds
  information Superhuman lacks, or that should update a decision record.
- **Do not** use push to force large unilateral App Spec rewrites from git onto
  the working group without Superhuman-side consensus.

### Never sync to Superhuman
- Do not sync `AGENTS.md` to Superhuman.
- Do not sync any skills content to Superhuman, including all files under `skills/`.
- Do not sync `scripts/**` or this folder's `README.md`.
- Treat these files as local operational guidance for contributors and agents only.
- If a sync process is automated, explicitly exclude `AGENTS.md`, `skills/**`,
  `scripts/**`, and `README.md`.

## Minimum Definition of Done for Documentation Changes
A contribution is complete only when all are true:
- The appropriate source-of-truth file is updated.
- If **`app-specification.md`** changed, a Change Record entry exists that names what changed in the spec and why.
- If a decision changed, the decision file (and index) are updated.
- Related files are cross-linked.
- Metadata includes author, date, type, and status where the template requires it.
- The entry is understandable without private context.

## Contributor Responsibility
Each contributor is responsible for:
- Accuracy and completeness of their entries.
- Maintaining traceability across files.
- Updating ownership and status when context changes.
- Leaving the repository easier to navigate than they found it.
