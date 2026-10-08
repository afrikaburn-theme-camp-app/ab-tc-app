---
id: decision-018
title: Requirements corpus lives in-repo; Superhuman sync retired; App Spec renamed Requirements
date: 2026-10-08
author: Beyers Nel
status: accepted
type: decision
related:
  - ../requirements.md
  - decision-017-accepted-spec-driven-feature-delivery.md
  - ../../specifications/README.md
  - ../../archive/superhuman-sync/README.md
tags:
  - process
  - documentation
  - requirements
---

# Decision 018: Requirements corpus lives in-repo; Superhuman sync retired
Date: 2026-10-08
Owner: Beyers Nel
Status: accepted
Related: [Requirements](../requirements.md), [Decision 017](decision-017-accepted-spec-driven-feature-delivery.md), [Specifications](../../specifications/README.md)

## Context

The product corpus lived under `docs/sources/app-specification/` as a
Superhuman ↔ git sync root (pull-dominant). Superhuman was kept so
non-engineers could hand-edit the document. That workflow was not used enough
to justify the sync complexity (manifests, skills, absolute-link constraints,
token custody).

Separately, the document titled “App Specification” was misnamed: it records
**Requirements** (what / for whom / why). Feature **Specifications** (how to
build) are a different layer — see Decision 017.

## Decision

1. The **repository is the single source of truth** for Requirements. Path:
   `docs/requirements/`.
2. **Superhuman sync is retired** for this product. No pull/push loop; no
   `SUPERHUMAN_TOKEN` in active workflow. Sync skills and the audit script are
   **archived** (not deleted) at `docs/archive/superhuman-sync/` for possible
   reuse in another repo.
3. Terminology: **“App Spec” / “App Specification” → “Requirements”** in
   active docs, templates, and agent digests. Stable `PREFIX-NNN` requirement
   IDs are unchanged.
4. Links inside the corpus are ordinary **repo-relative** paths (including
   up-tree). The old “no up-tree links / absolute GitHub URLs only” rule was a
   Superhuman constraint and no longer applies.
5. Out-of-repo follow-up (not blocking this decision): post a one-line “moved
   to GitHub” note on the Superhuman doc and revoke the sync token when
   convenient.

## Alternatives considered

- Keep Superhuman as collaborative primary with git as a mirror — rejected:
  unused complexity.
- Delete sync tooling outright — rejected: archive for portability to another
  repo.
- Rename without moving out of `docs/sources/` — rejected: `sources/` is for
  verbatim never-edited mirrors; Requirements are actively edited.

## Consequences

- Positive: one surface (git + PRs); simpler agent and contributor guidance;
  correct Requirements vs Specifications naming with Decision 017.
- Negative: non-engineers edit via PR (or a maintainer commits on their
  behalf) instead of Superhuman WYSIWYG.
- Risks: temporary link rot until the terminology sweep lands (same change
  set); historical meeting minutes may still say “App Spec”.

## Follow-up

- Review date: after the first Requirements edit under the new path.
- Superhuman “moved” note and token revocation remain outside this repo.
