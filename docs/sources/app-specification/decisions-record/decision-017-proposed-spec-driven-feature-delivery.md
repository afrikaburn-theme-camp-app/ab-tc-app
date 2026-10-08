---
id: decision-017
title: Deliver features via requirements-informed specs reviewed before implementation
date: 2026-10-08
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - decision-015-accepted-whatsapp-for-operations-slack-for-engineering.md
  - ../meeting-minutes/2026-09-19-scheepers-project-abstraction-notes.md
tags:
  - process
  - delivery
  - documentation
---

# Decision 017: Deliver features via requirements-informed specs reviewed before implementation
Date: 2026-10-08
Owner: Beyers Nel
Status: proposed
Related: [App Specification](../app-specification.md), [Decision 015](decision-015-accepted-whatsapp-for-operations-slack-for-engineering.md)

## Context

WhatsApp working group, late September–early October 2026:

- Parallel workstreams and disagreement about where product discussion should live (Superhuman App Spec vs GitHub issues vs ad-hoc chat) had slowed shared understanding.
- Scheepers de Bruin (2026-09-29) restated a useful split: **Requirements = what**; **Spec = how**. He argued modular scoping (agree interfaces between subsystems) reduces friction — e.g. camp budgeting can require paid/not-paid flags and a pay link without embedding a full payment system in the same change.
- Beyers (2026-09-30) noted that this corpus’s “App Specification” is closer to product requirements, while `docs/technical-spec/` is closer to technical specification, and floated a SpecKit-style research → scope process for features (tooling detail is engineering HOW, not decided here).
- Beyers and Rohan Shackleford (2026-10-08): agreed Spec Driven Development is the way forward — Rohan focuses on creating specifications from requirements; engineers review and implement.

This record is about the **working-group delivery process**, not about renaming Superhuman pages or adopting a specific tooling kit.

## Decision to make

Provisionally adopt:

1. **Product requirements** (what / for whom / why) continue to live in this App Specification corpus and its Decision Records.
2. **Feature specifications** (how a change will work, scoped enough to implement and review) are written before implementation for non-trivial features, in a form non-engineers can read.
3. Each feature spec goes through a **review phase** (objections can be raised) before build.
4. Rohan packages specifications from requirements; engineers review and implement. Engineering discussion stays on Slack; operational visibility stays on WhatsApp ([Decision 015](decision-015-accepted-whatsapp-for-operations-slack-for-engineering.md)).

Still open until accepted: exact home for feature specs (repo path vs Superhuman vs both), and whether every change needs a written feature spec or only non-trivial ones.

## Alternatives considered

- Build from GitHub issues alone, without a readable pre-implementation spec — rejected for this working group: non-engineers cannot draft or review scope, and surprise during implementation has already caused friction.
- Keep all product discussion only in Superhuman with no per-feature write-up next to code — rejected as the sole path: sync cost and weak coupling to implementation review.
- Treat the App Spec itself as the implementation contract for every change — rejected: Requirements ≠ Spec (Scheepers); the App Spec stays operational WHAT/WHY.

## Consequences

- Positive: scope is visible before code; non-engineers can help draft; fewer mid-build surprises; clearer hand-off between requirements authors and implementers.
- Negative: small changes may feel heavier if the “when is a feature spec required?” bar is too low.
- Risks: two documentation surfaces (requirements corpus vs feature specs) can drift if cross-links are weak; renaming “App Spec” to “Product Requirements” on Superhuman is a separate editorial choice and is not decided here.

## Follow-up

- Review date: after the first feature delivered under this process, or when the working group accepts or rejects this record.
- Do not track people-to-do items in this corpus; engineering work stays on GitHub issues.
