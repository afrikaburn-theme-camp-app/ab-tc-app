---
id: decision-017
title: Deliver features via requirements-informed specs reviewed before implementation
date: 2026-10-08
author: Beyers Nel
status: accepted
type: decision
related:
  - ../requirements.md
  - decision-015-accepted-whatsapp-for-operations-slack-for-engineering.md
  - decision-018-accepted-requirements-corpus-moves-in-repo-superhuman-retired.md
  - ../meeting-minutes/2026-09-19-scheepers-project-abstraction-notes.md
  - ../../specifications/README.md
tags:
  - process
  - delivery
  - documentation
---

# Decision 017: Deliver features via requirements-informed specs reviewed before implementation
Date: 2026-10-08
Owner: Beyers Nel
Status: accepted
Related: [Requirements](../requirements.md), [Decision 015](decision-015-accepted-whatsapp-for-operations-slack-for-engineering.md), [Decision 018](decision-018-accepted-requirements-corpus-moves-in-repo-superhuman-retired.md), [Specifications](../../specifications/README.md)

## Context

WhatsApp working group, late September–early October 2026:

- Parallel workstreams and disagreement about where product discussion should live (Superhuman App Spec vs GitHub issues vs ad-hoc chat) had slowed shared understanding.
- Scheepers de Bruin (2026-09-29) restated a useful split: **Requirements = what**; **Spec = how**. He argued modular scoping (agree interfaces between subsystems) reduces friction — e.g. camp budgeting can require paid/not-paid flags and a pay link without embedding a full payment system in the same change.
- Beyers (2026-09-30) noted that this corpus’s former “App Specification” is closer to product requirements, while `docs/technical-spec/` is closer to technical specification, and floated a SpecKit-style research → scope process for features (tooling detail is engineering HOW, not decided here).
- Beyers and Rohan Shackleford (2026-10-08): agreed Spec Driven Development is the way forward — the Product Owner/Designer focuses on creating specifications from requirements; engineers review and implement.

## Decision

1. **Product requirements** (what / for whom / why) live in this Requirements corpus and its Decision Records ([Decision 018](decision-018-accepted-requirements-corpus-moves-in-repo-superhuman-retired.md)).
2. **Feature specifications** (how a change will work, scoped enough to implement and review) are written before implementation for every new behaviour or product feature, in a form non-engineers can read. Home: [`docs/specifications/`](../../specifications/README.md).
3. Each feature Specification goes through a **review phase** (objections can be raised) before build.
4. The **Product Owner/Designer** packages Specifications from Requirements; engineers review, modify for technical implementation, and implement. Engineering discussion stays on Slack; operational visibility stays on WhatsApp ([Decision 015](decision-015-accepted-whatsapp-for-operations-slack-for-engineering.md)).
5. **No new behaviour or product feature** may be introduced without an approved Specification sourced from Requirements.

The Specification file format itself remains provisional until the Product Owner/Designer defines it. `docs/technical-spec/` is the legacy as-built record pending that migration.

## Alternatives considered

- Build from GitHub issues alone, without a readable pre-implementation spec — rejected for this working group: non-engineers cannot draft or review scope, and surprise during implementation has already caused friction.
- Keep all product discussion only in Superhuman with no per-feature write-up next to code — rejected (and Superhuman sync is retired by Decision 018).
- Treat Requirements themselves as the implementation contract for every change — rejected: Requirements ≠ Spec (Scheepers); Requirements stay operational WHAT/WHY.
- Require a written Specification only for “non-trivial” changes — rejected for acceptance of this record: the bar is every new behaviour or product feature; hygiene/chores remain Exempt in PR templates.

## Consequences

- Positive: scope is visible before code; non-engineers can help draft; fewer mid-build surprises; clearer hand-off between requirements authors and implementers.
- Negative: small product changes still need a short approved Specification.
- Risks: two documentation surfaces (Requirements vs Specifications) can drift if cross-links are weak; format churn while the Product Owner/Designer settles the template.

## Follow-up

- Review date: after the first feature delivered under this process.
- Do not track people-to-do items in this corpus; engineering work stays on GitHub issues.
