# Documentation index and conventions

| Field                  | Value                               |
| ---------------------- | ----------------------------------- |
| **Category**           | Operational                         |
| **Doc status**         | Active                              |
| **Normative language** | RFC 2119 / RFC 8174 applies         |
| **Requirement IDs**    | N/A — operational, not spec-derived |
| **Owner / Updated**    | Repo maintainers, 2026-08-05        |

This file is the index and the rulebook for everything under `docs/`. If you are
about to read, write, or update a doc in this folder, start here.

`docs/sources/` holds verbatim primary sources (briefs, scope documents,
mirrored public pages) — never edited to match the product; see
[`sources/README.md`](sources/README.md). Product **Requirements** live at
[`requirements/`](requirements/README.md). Feature **Specifications** live at
[`specifications/`](specifications/README.md).

## Direction of information travel

**Requirements** (`docs/requirements/`) are the sole source of truth for what
the product should do. They change when meetings, discussions, and/or
decisions are recorded. **Specifications** (`docs/specifications/`) are
written from Requirements by the Product Owner/Designer, reviewed by
engineers, then implemented. **No new behaviour or product feature** ships
without an approved Specification.

> **Requirements:** [`requirements/requirements.md`](requirements/requirements.md)
>
> **Specifications:** [`specifications/`](specifications/README.md)
>
> Conventions for the Requirements corpus:
> [`requirements/README.md`](requirements/README.md) /
> [`requirements/AGENTS.md`](requirements/AGENTS.md)

Everything else in this repository — every file below, the code, the tests — is
**downstream** of Requirements (and, for new features, of an approved
Specification). That has one immediate consequence and one common
misunderstanding to avoid:

- **Downstream docs may describe required technical features Requirements never
  mention.** Migration discipline, auth architecture, deployment runbooks — none
  of that is in Requirements, and it doesn't need to be. Requirements are
  authoritative on _what the product should do_; this repo is authoritative on
  _how, and whether, that gets built_. A doc with no Requirement-ID relationship
  to Requirements is not a gap — see the **Requirement-ID protocol** below for
  how each doc states its own relationship (or lack of one) honestly.
- **Nothing in this repo may contradict Requirements and win.** If a doc here and
  Requirements disagree about what the product _should_ do, Requirements are
  right and the doc is stale, unless an accepted Decision Record says
  otherwise. (Docs are free to describe _why the build diverges_ —
  [`technical-spec/requirements-coverage.md`](technical-spec/requirements-coverage.md)
  §4 and §8, and each feature doc's own Drift section, do exactly that — but
  that's documenting a known gap against an unaccepted or not-yet-honoured
  Decision Record, not a disagreement about which document governs.)

Underneath that top tier:

1. **Requirements** (above) govern what the product should do.
   **Specifications** govern what may be built next. Where this repo's current
   build takes a position a governing Decision Record has not yet accepted,
   that is a documented drift, not a second source of truth — see
   `docs/technical-spec/`'s drift register (legacy as-built) and
   `GOVERNANCE.md`.
2. **[`GOVERNANCE.md`](../GOVERNANCE.md) and [`CONTRIBUTING.md`](../CONTRIBUTING.md)**
   govern process — decision-making, review, and how a change gets made.
   Human contributors start at `CONTRIBUTING.md`.
3. **[`build-spec.md`](build-spec.md) and `docs/technical-spec/`** (legacy
   as-built, pending migration into Specifications) win for engineering —
   schema, routes, stack, hard constraints — where any other doc in this repo
   disagrees with them on HOW, not WHAT.
4. **`AGENTS.md`** is the agent operating digest. It must not contradict any
   of the above; where it appears to, the above wins and `AGENTS.md` is
   stale.

(This inverts the precedence this file stated before the project moved to
open governance, where `AGENTS.md` won on process ahead of `CONTRIBUTING.md`
and `GOVERNANCE.md` did not yet exist.)

## The index

| Doc                                                                                            | Category                  | Doc status                | Requirement-ID coverage                                                                                                        |
| ---------------------------------------------------------------------------------------------- | ------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `README.md` _(this file)_                                                                      | Operational               | Active                    | N/A — index and conventions, not spec-derived                                                                                  |
| [`specifications/`](specifications/README.md)                                                  | Product                   | Active                    | Feature specs (draft → approved → implemented); format provisional pending Product Owner/Designer                                  |
| [`technical-spec/`](technical-spec/README.md)                                                  | Product                   | **Legacy** (as-built)     | **Exhaustive** (`requirements-coverage.md`) plus per-feature partial coverage — migrates into `specifications/`                    |
| [`build-spec.md`](build-spec.md)                                                               | Engineering Spec          | Active                    | Partial — hard constraints, schema, seeds; feature-specific content has moved to `technical-spec/`                             |
| [`compliance-and-incident-response.md`](compliance-and-incident-response.md)                   | Operational               | Active                    | N/A — operational/legal, not spec-derived                                                                                      |
| [`supply-chain-incident-response.md`](supply-chain-incident-response.md)                       | Operational               | Active                    | N/A — compromised-package runbook (Safe Chain / Dependabot age gates)                                                          |
| [`triage.md`](triage.md)                                                                       | Operational               | Active                    | N/A — operational, not spec-derived                                                                                            |
| [`synthesis.md`](synthesis.md)                                                                 | Planning                  | **Historical**            | N/A — superseded as an authoritative source by Requirements                                                                |
| [`simplification-audit.md`](archive/simplification-audit-2026-08.md)                           | Operational               | **Historical** (archived) | N/A — point-in-time audit transcript                                                                                           |
| [`deploy.md`](deploy.md)                                                                       | Operational               | Active                    | N/A — operational, not spec-derived                                                                                            |
| [`roadmap.md`](roadmap.md)                                                                     | Planning                  | Active                    | Partial — `RELEASE-*`                                                                                                          |
| [`sdk/`](sdk/README.md)                                                                        | Engineering Spec          | Draft                     | N/A — no Requirements section yet; specifies a `/v1` API and published SDK that are **not built**, pending Decision 005 (proposed) |
| [`requirements/`](requirements/README.md)                            | Product                   | Active                    | **Authoritative Requirements** — in-repo primary source                                                                            |
| [`requirements/decisions-record/`](requirements/decisions-record.md) | Planning                  | Active                    | **Operational** decisions — WHAT/WHY                                                                                               |
| [`archive/superhuman-sync/`](archive/superhuman-sync/README.md)      | Operational               | **Historical** (archived) | Retired Superhuman/Coda sync kit — portable, not wired into workflow                                                               |
| [`engineering-decisions/`](engineering-decisions/README.md)                                    | Planning                  | Active                    | **Engineering** decisions — HOW                                                                                                |
| [`technical-spec/21-gis-spatial-data-research.md`](technical-spec/21-gis-spatial-data-research.md) | Planning              | Draft                     | N/A — external-GIS research, not spec-derived                                                                                  |
| [`technical-spec/22-afrikaburn-tmi-identity-research.md`](technical-spec/22-afrikaburn-tmi-identity-research.md) | Planning    | Draft                     | N/A — external-identity research, not spec-derived                                                                             |
| [`technical-spec/23-security-threat-model.md`](technical-spec/23-security-threat-model.md) | Security            | Draft                     | Partial — `SEC-*` cross-cutting threat matrix (covered vs open); per-feature detail stays in sibling Security docs             |

Categories: **Product** (what's built vs. the spec) · **Architecture** (how the
system fits together, current state) · **Engineering Spec** (a subsystem's
design) · **Security** (auth architecture, threat model, compliance) ·
**Operational** (runbooks, process) · **Planning** (rationale, release
sequencing).

`architecture.md`, `component-spec.md`, `flows.md`, `questionnaire-spec.md`,
`notifications-spec.md`, `supplier-spec.md`, `accounts-security-spec.md` and
`auth-platform-spec.md` moved into `technical-spec/` (see that folder's
index for exactly where) as part of the 2026-09-11 restructure. The old
paths held short redirects for a transition period; those redirects have
since been removed outright, so any surviving code comment or external link
pointing at an old path is stale and should be repointed at the successor
doc named in that folder's index.

## Technical language guide

### Normative keywords — RFC 2119 / RFC 8174

> The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**,
> **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **NOT RECOMMENDED**, **MAY**, and
> **OPTIONAL** in this document are to be interpreted as described in
> [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and
> [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they
> appear in all capitals, as shown here.

That is the standard BCP 14 boilerplate. Whether it applies to a given doc is
whatever that doc's own header says under **Normative language** — check the
header, not a list here. (An earlier version of this section named the docs on
each side; a hand-maintained roster of doc names, duplicating a field that
already exists in every file, is guaranteed to go stale the moment a doc is
added or re-marked — the index above is kept current, this prose no longer
tries to be.) Lowercase `must`/`may`/`should` stay ordinary English everywhere,
including in docs marked RFC 2119 applies — capitalisation is what invokes the
RFC meaning, nothing else does.

Docs marked **Normative language: Descriptive only** report what exists or
what's planned; they don't impose requirements, so this convention doesn't
apply to them even where they happen to contain the word "must." See the index
above for which docs are currently marked which way.

### The status-symbol legend

This is the canonical, repo-wide meaning for these four symbols from now on,
copied from where it was first defined in [`technical-spec/requirements-coverage.md`](technical-spec/requirements-coverage.md):

| Symbol | Meaning                                                        |
| ------ | -------------------------------------------------------------- |
| ✅     | **Built** — working in the deployed apps, with tests           |
| 🚧     | **Partial** — some of it works; the rest is named nearby       |
| ❌     | **Not built** — no code, no database tables                    |
| ⚠️     | **Blocked** — cannot be built yet, and the blocker is not code |

**A section heading's glyph is a summary, not the last word.** In
`technical-spec/requirements-coverage.md`, a `##` heading glyph states the section's overall call;
the `**Requirement IDs:**` line beneath it is the authoritative, per-id
breakdown, and the two may legitimately differ in altitude rather than agree —
§8 and §10 head ⚠️ _blocked_ while every id they cite is ❌ _not built_, because
the platform's non-negotiable policy stance (never run a payment gateway;
Quicket stays the system of record) isn't quite the same claim as "the code
doesn't exist," even though the practical effect is the same. Where a heading
and its own citation line flatly disagree rather than differ in altitude,
that's a bug, not a difference of perspective — fix the heading.

**One collision to know about, not fix:** [`build-spec.md`](build-spec.md)'s org
capability-matrix table and
[`technical-spec/05-camp-roles-and-officers.md`](technical-spec/05-camp-roles-and-officers.md)'s
role-defaults table reuse ✅/❌ for a plain boolean "does this role have this
right, yes or no" — a different, older, local meaning that predates this
convention. Those specific pre-existing tables are left as they are; just
don't assume ✅/❌ means "built" in a table clearly answering a yes/no
permissions question. New tables SHOULD avoid reusing these four glyphs for
plain booleans, to stop the collision from spreading.

## The standardised metadata header block

Every doc in this folder (except `docs/sources/`, which isn't a spec) carries
this 5-row table directly under its H1, before any other content:

```markdown
| Field                  | Value                                                                              |
| ---------------------- | ---------------------------------------------------------------------------------- |
| **Category**           | Product \| Architecture \| Engineering Spec \| Security \| Operational \| Planning |
| **Doc status**         | Active \| Historical \| Draft                                                      |
| **Normative language** | RFC 2119 / RFC 8174 applies \| Descriptive only                                    |
| **Requirement IDs**    | Exhaustive \| Partial \| N/A — with a short qualifier                              |
| **Owner / Updated**    | _name or "Repo maintainers", date_                                                 |
```

Field definitions:

- **Category** — one of the six values in the index above. Pick the closest fit;
  don't invent a seventh without updating this table.
- **Doc status** — `Active` (current, maintained), `Historical` (kept for the
  record, not actively updated — state _why_ in the doc's own prose if not
  obvious), or `Draft` (not yet reviewed).
- **Normative language** — whether RFC 2119/8174 keywords carry weight in this
  doc. See above.
- **Requirement IDs** — `Exhaustive` (every relevant Requirements requirement is
  cited, doc-wide or section-wide), `Partial` (some are cited, best-effort, not
  audited for completeness — say which prefixes), or `N/A` (this doc has no
  meaningful relationship to the Requirements — say why in one clause, e.g.
  "operational, not spec-derived").
- **Owner / Updated** — who to ask, and when the header (not necessarily the
  body) was last touched.

Worked example, from [`technical-spec/requirements-coverage.md`](technical-spec/requirements-coverage.md):

```markdown
| Field                  | Value                                                                                                                      |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Category**           | Product                                                                                                                    |
| **Doc status**         | Active                                                                                                                     |
| **Normative language** | Descriptive only — this document reports build status; it does not itself impose requirements                              |
| **Requirement IDs**    | Exhaustive — full 1:1 section mirror of the Requirements. Every section below cites the `PREFIX-NNN` IDs it addresses |
| **Owner / Updated**    | Repo maintainers, 2026-08-05                                                                                               |
```

## Requirement-ID protocol

### What Requirements IDs look like

Every substantive requirement bullet in Requirements carries a stable
`PREFIX-NNN` id (e.g. `CDB-014`), one fixed prefix per numbered section,
append-only and never renumbered or reused — a requirement that no longer
applies is struck through in place and annotated, never deleted. Requirements
document this scheme under "Requirement ID Conventions"; this repo only ever
_cites_ those IDs, never mints its own.

### Header-level coverage, by doc type

- **A doc that mirrors Requirements structure 1:1** (today, only
  `technical-spec/requirements-coverage.md`, which mirrors all 21 sections):
  `Requirement IDs: Exhaustive`, and every section carries its own inline
  citation — see below.
- **A per-feature doc under `technical-spec/`** (legacy as-built) serving
  requirements scattered across one or more Requirements sections, usually with
  no dedicated section of its own (e.g. `technical-spec/10-questionnaire-engine.md`,
  which implements pieces of `ONBOARD-*`, `REG-*` and `SEC-*` without
  Requirements ever naming "questionnaires" as a section): `Requirement IDs:
Partial — <prefixes>`, explicitly best-effort and not audited for
  completeness. Each such doc carries an "Implements (Requirements)"
  table naming exactly which IDs it covers and at what status.
- **A purely operational doc** with no relationship to Requirements at all
  (`deploy.md`, `triage.md`): `Requirement IDs: N/A — operational, not
spec-derived`.

### Inline citation format

Where a doc cites specific IDs in its body (`technical-spec/requirements-coverage.md`,
and the "Implements" table in every doc under `technical-spec/`), the format
is a leading bold-bracketed line (or table row) grouped by this repo's
status glyph, matching the Requirements convention of bolding the ID
before the text it tags:

```markdown
**Requirement IDs:** ✅ CDB-037, CDB-040, CDB-041, CDB-043 · 🚧 CDB-042 · ❌ CDB-029, CDB-030 · ⚠️ CDB-001–CDB-024 _(Requirements §4)_
```

A trailing note in parentheses is fine for a divergence that doesn't reduce to a
single glyph (see `technical-spec/requirements-coverage.md` §4, §8, §14 for real examples).

**A range MUST NOT straddle an id with a different status.** `CDB-040–CDB-043`
inside the ✅ bucket is only correct if `041`, `042` and `043` all genuinely
belong there too — if one of them doesn't, enumerate around it
(`CDB-040, CDB-041, CDB-043`) rather than widening the range and hoping the
gap is obvious from the neighbouring bucket.

### The regeneration protocol

What happens when Requirements change — the strict, repeatable procedure this
whole convention exists to support:

1. **Requirements are edited** in a PR (a requirement added, changed, or
   removed) when a meeting, discussion, and/or decision warrants it.
2. **The change is logged** in
   [`requirements/requirements-change-record.md`](requirements/requirements-change-record.md),
   citing the specific `PREFIX-NNN` IDs touched.
3. **Identify affected IDs** from that Change Record entry (or the PR diff).
4. **Find every citing location**: `grep -rn "<ID>" docs/` — the header-level
   `Requirement IDs` field and any inline citations both use the literal ID
   string, so this is exhaustive by construction. Also search for the relevant
   wildcard prefix (e.g., `ONBOARD-*` if the ID is `ONBOARD-042`) to catch
   docs that cite the prefix range rather than individual IDs.
5. **A removed ID** is never deleted from a citing doc — struck through in
   place with `(Removed — see Change Record <date>)`, mirroring the Requirements
   convention for the same reason: so an old reference resolves to an
   explanation instead of a silent gap.
6. **A changed ID** (Requirements IDs are append-only, so this means the
   _wording_ under an existing ID changed): re-read the citing doc's claim. If
   this repo's implementation is unaffected, leave the citation. If the
   technical implication changed, update the doc's prose and note it — this is
   a human judgement call, not a mechanical sync. Update or create the relevant
   Specification under `docs/specifications/` when behaviour to build changes.
7. **A new ID**: check whether this repo's existing prose already covers the
   behaviour (common — Requirements sometimes catch up to shipped work before
   the reverse). If it does, add the citation to the relevant
   `technical-spec/` feature doc (and to `requirements-coverage.md`). If it
   doesn't, that's a real gap — feed it into `requirements-coverage.md`'s own
   ✅🚧❌⚠️ gap-analysis mechanism and/or a new Specification rather than
   starting a second tracking system.
8. **Update the header** if a whole prefix range is affected, not just one ID.
9. **Cite the Change Record** (date or link) in the commit message for any
   commit that exists specifically to re-sync citing docs against a Requirements
   change — this is scoped narrowly to those commits and doesn't change
   `CONTRIBUTING.md`'s ownership of the general commit-message format.

### Scope, honestly stated

`technical-spec/requirements-coverage.md` is fully retrofitted with per-section
inline citations — it was the mechanical case, since its 21 sections already
mirror the Requirements 21 sections exactly. Every doc under `technical-spec/`
carries an "Implements" table naming the IDs it covers, verified against the
requirement-index as of 2026-09-11 — but "verified once" is not "audited
forever": treat a `Partial` label as literally true and re-verify it when the
feature or the Requirements section changes. Docs outside `technical-spec/`
(`build-spec.md`, `roadmap.md`, `sdk/`) carry only a header-level, best-effort
coverage field. New feature work should land Specifications under
`docs/specifications/` rather than extending the legacy as-built tree.

## Contributing to these docs

This section is docs-specific only. For setup, commit conventions, the design
canvas workflow, and how to pick up an issue, start at
[`CONTRIBUTING.md`](../CONTRIBUTING.md) — nothing here repeats it.

When you add a new doc under `docs/`, or substantively edit an existing one:

- **It carries the metadata header block** (above), directly under the H1.
- **State Requirement-ID coverage honestly.** An honest `N/A` is worth more than
  a citation you can't back up. If you're not sure a doc relates to the App
  Spec at all, it probably belongs at `N/A`, not a guessed `Partial`.
- **If you cite Requirement IDs in body text, follow the inline format above**
  and add the doc to the index table if it's new.
- **If you're resolving a Requirement-ID change** (Requirements added/changed/
  removed something), follow the regeneration protocol above and say so in the
  PR description — which `PREFIX-NNN` IDs, and which docs you touched because of
  them.
- **Docs review follows the same path as code review** — no separate gate;
  `CONTRIBUTING.md`'s review section applies.
