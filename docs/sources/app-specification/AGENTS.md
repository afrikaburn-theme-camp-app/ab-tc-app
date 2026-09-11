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
- **Product vs engineering decisions:** this corpus records **WHAT we build and WHY**. Engineering **HOW** decisions live in monorepo `docs/decisions/`, not here.
- Single source of truth by topic: each topic has one primary file.
- Chronological traceability: changes are logged in append-only records.
- Linkability: all major entries point to related specs, decisions, and tasks.
- Ownership clarity: every non-trivial entry includes author and date metadata.
- Retrieval-first writing: use clear headings and predictable formats.

## Repository Structure

### Top-level thematic files
- `app-specification.md`: Current product and feature specification baseline.
- `decisions-record.md`: Index or roll-up of architecture/product decisions.
- `task-assignment.md`: Work ownership and delivery responsibilities.
- `member-list.md`: Team roles and contributor reference.
- `links.md`: Canonical references to internal and external resources.

### Chronological and detailed records
- `app-specification/app-spec-change-record.md`: Append-only timeline of specification changes.
- `decisions-record/decision-###-<status>-<short-title>.md` (e.g. `decision-001-accepted-decision-record-format.md`): Detailed decision entries.

### Skills and operational helpers
- `skills/`: Reusable execution guides and templates.
- `skills/_templates/skill-template/`: Template for creating future skills.

## Navigation Rules
- Start with top-level files to understand the current state.
- Use subfolders for history and detailed records.
- Keep one concern per file; avoid mixed-topic dumping.
- Prefer adding linked records over rewriting historical context.

## Required Contribution Workflow

### 1) Classify the change
Before editing, determine the change type:
- Specification change
- New architecture or product decision
- Task ownership or planning update
- Team/member update
- Reference/link update

### 2) Update the source-of-truth file
Edit the thematic primary file first:
- Spec content -> `app-specification.md`
- Decision summary/index -> `decisions-record.md`
- Tasks -> `task-assignment.md`
- Members -> `member-list.md`
- References -> `links.md`

### 3) Append a chronological record (mandatory)
For every non-trivial change, add an entry to the relevant change log:
- Spec-related changes must be appended to `app-specification/app-spec-change-record.md`.
- Decision-related changes must create or update a `decisions-record/decision-XXX.md` file and be referenced from `decisions-record.md`.

Do not delete prior log entries. Corrections should be new entries that reference the older entry.

### 4) Link related artifacts
Every substantial change should link to related records:
- Spec entry links to decision(s), task(s), and references.
- Decision entry links to affected spec sections and tasks.
- Task updates link to the spec and/or decision driving the work.

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
- Affected tasks:

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
- Actions:
- Review date:
```

## Naming and Organization Conventions
- Keep filenames lowercase and kebab-case where possible.
- Use stable numeric IDs in filenames: `decision-001-<status>-<short-title>.md`, `decision-002-<status>-<short-title>.md`, etc.
- Never repurpose an existing decision ID for a different decision.
- Add new files rather than overloading existing ones with unrelated content.

## Editing Rules
- Preserve historical meaning; avoid silent rewrites of rationale.
- If intent changes, record the reason and timestamp in the log.
- Keep summaries concise and implementation-neutral where possible.
- Use explicit dates in ISO format: `YYYY-MM-DD`.

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
- A chronological log entry exists.
- Related files are cross-linked.
- Metadata includes author, date, type, and status.
- The entry is understandable without private context.

## Contributor Responsibility
Each contributor is responsible for:
- Accuracy and completeness of their entries.
- Maintaining traceability across files.
- Updating ownership and status when context changes.
- Leaving the repository easier to navigate than they found it.
