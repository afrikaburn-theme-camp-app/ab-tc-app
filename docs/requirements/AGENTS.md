# AGENTS.md

## Mission

This folder (`docs/requirements/` inside the `ab-tc-app` monorepo) is the
intelligence memory and architecture log for **product requirements**. The
monorepo root `AGENTS.md` governs engineering process for the apps; **this file
governs only the Requirements corpus.**

Its purpose is to:

- Preserve feature intent, decisions, and constraints so information is not lost.
- Keep Requirements aligned with implementation goals via Specifications.
- Reduce product drift through frequent gap analysis.
- Maintain auditable ownership and chronology for every meaningful update.

If a change cannot be traced, linked, and justified, it is incomplete.

## Documentation Principles

- **Operational vs engineering decisions:** this corpus records **operational**
  decisions — WHAT we build, for whom, and WHY, at a product/working-group
  level. Technical detail that could influence implementation belongs in
  `docs/specifications/` (feature specs) or `docs/technical-spec/` (legacy
  as-built / research until migrated). Engineering **HOW** decisions live in
  `docs/engineering-decisions/`, not here.
- **No task tracking in this corpus.** Engineering work is tracked via GitHub
  issues on [afrikaburn-theme-camp-app/ab-tc-app](https://github.com/afrikaburn-theme-camp-app/ab-tc-app).
- **When Requirements may change:** only when meetings, discussions, and/or
  decisions are recorded that affect product intent. Do not invent behaviour
  here to match an implementation you already shipped without a paper trail.
- Single source of truth by topic: each topic has one primary file.
- Chronological traceability: changes are logged in append-only records.
- Linkability: all major entries point to related requirements, decisions, and
  references.
- Ownership clarity: every non-trivial entry includes author and date metadata.
- Retrieval-first writing: use clear headings and predictable formats.

## Repository Structure

### Top-level thematic files

- `requirements.md`: Current product and feature requirements baseline.
- `decisions-record.md`: Index of **operational** (WHAT/WHY) decisions.
- `member-list.md`: Team roles and contributor reference.
- `links.md`: Canonical references to internal and external resources.

### Chronological and detailed records

- `requirements-change-record.md`: Append-only timeline of **`requirements.md`
  changes only**.
- `requirement-index.md`: Index of every `PREFIX-NNN` ID.
- `decisions-record/decision-###-<status>-<short-title>.md`: Detailed decision
  entries.
- `meeting-minutes/`: Working-group notes.

## Navigation Rules

- Start with `requirements.md` for the current product baseline.
- Use the other top-level files to understand the current state of each topic.
- Use subfolders for history and detailed records.
- Keep one concern per file; avoid mixed-topic dumping.
- Prefer adding linked records over rewriting historical context.

## Required Contribution Workflow

### 1) Classify the change

Before editing, determine the change type:

- Requirements change
- New operational (product) decision
- Team/member update
- Reference/link update

### 2) Update the source-of-truth file

Edit the thematic primary file first:

- Requirements content -> `requirements.md`
- Decision summary/index -> `decisions-record.md`
- Members -> `member-list.md`
- References -> `links.md`
- Feature specs / HOW -> `docs/specifications/` or `docs/engineering-decisions/`
  (not this corpus)

### 3) Append a chronological record (when the topic has one)

- **`requirements.md` changed** → append to `requirements-change-record.md`.
  That file is **only** the log of why the official Requirements changed. Do
  not put meeting minutes, decision-record updates, member-list or links edits,
  or other corpus housekeeping in it.
- **Decision-related changes** → create or update a
  `decisions-record/decision-XXX.md` file and reference it from
  `decisions-record.md`.
- Member-list, links, and meeting-minutes updates live in those files. They do
  **not** get a Change Record entry.

Do not delete prior *requirements* log entries. Corrections should be new
entries that reference the older entry.

### 4) Link related artifacts

Every substantial change should link to related records:

- Requirements entry links to decision(s) and references.
- Decision entry links to affected requirements sections.
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
type: requirements-change|decision|reference-update
related:
  - <path-or-id>
  - <path-or-id>
tags:
  - <feature>
  - <domain>
```

## Chronological Paper Trail Standard

### Requirements change record entry template

Use this template for entries in `requirements-change-record.md`:

```md
## YYYY-MM-DD - <Change Title>
Owner: <name>
Type: requirements-change
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

Decision records stay **operational**. Do not put GIS formats, stack choices,
or implementation contracts in them — those go to `docs/specifications/`,
`docs/technical-spec/` (research / legacy), or `docs/engineering-decisions/`
(HOW). Do not list people-to-do items; this corpus does not track tasks.

## Naming and Organization Conventions

- Keep filenames lowercase and kebab-case where possible.
- Use stable numeric IDs in filenames:
  `decision-001-<status>-<short-title>.md`, etc.
- Never repurpose an existing decision ID for a different decision.
- Add new files rather than overloading existing ones with unrelated content.

## Editing Rules

- Preserve historical meaning; avoid silent rewrites of rationale.
- If intent changes, record the reason and timestamp in the log.
- Keep summaries concise and **implementation-neutral**. Technical detail
  belongs in Specifications / engineering docs.
- Use explicit dates in ISO format: `YYYY-MM-DD`.
- Relative links within the repo are preferred (including up-tree to
  `docs/specifications/`, `docs/engineering-decisions/`, etc.).

## Minimum Definition of Done for Documentation Changes

A contribution is complete only when all are true:

- The appropriate source-of-truth file is updated.
- If **`requirements.md`** changed, a Change Record entry exists that names
  what changed and why.
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
