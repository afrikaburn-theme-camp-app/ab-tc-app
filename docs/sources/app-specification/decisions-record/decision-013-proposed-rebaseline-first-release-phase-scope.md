---
id: decision-013
title: Rebaseline first-release phase scope to match implemented MVP trajectory
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - decision-004-accepted-first-demonstrable-slice-placement-and-container-management.md
  - ../meeting-minutes/2026-09-17-dev-alignment.md
tags:
  - release-planning
  - delivery
---

# Decision 013: Rebaseline first-release phase scope to match implemented MVP trajectory
Date: 2026-07-29
Owner: Beyers Nel
Status: proposed

## Context
Suggested First Development Release is marked at risk. The listed Phase 1 sequence no longer matches current MVP outcomes (strong registration/review, security, suppliers, questionnaires; several original Phase 1 modules still pending).

## Decision to make
- Option A: retain current phase list as aspirational only.
- Option B: rewrite phases to reflect shipped MVP and near-term delivery order.
- Option C: split into two views: shipped baseline versus planned roadmap phases.

## Consequences to evaluate
- Stakeholder clarity and expectation management.
- Planning reliability for task assignment and sequencing.
- Risk of reporting delivery progress against obsolete milestones.

## Follow-up
- After acceptance, align Section 20 with task board and decision records in one pass.

## Update 2026-08-05 — Group chat
- 10:16: Fin K proposed a concrete Option B rebaseline:
  - Phase 1 (AB pitch demo, creative-project/AB Org registration only): user account creation (Camp Lead role), camp entity creation, creative project registration (LNT, Sound Policy, budget stats), camp placement application, theme camp mapping (tent/water tank/parking objects), water applications, ice ticketing, gas applications, containers, WAP allocation.
  - Phase 2+ (optional intra-camp extras): shift planning, intra-camp expenses/budgeting, meal rotas, private tent placement under stretchies, non-camp-lead user creation, village functionality.
- 10:42: Fin K — "If we're happy to present Phase 1 as I outlined above, I don't think we need anything else for now."
- 10:45–10:48: Ryan James Noble reviewed; flagged gas as possibly supplier-run and a candidate to drop into Phase 2+; water/ice still need user journeys defined. Fin K agreed a supplier-style gas system would move to Phase 2+.
- 10:49–11:16: Graeme Allan clarified gas is community-run (the Quaggafontein Gas Project), collectivised like the container project rather than a pure third-party supplier — bearing on whether gas stays in Phase 1.
- Net effect: informal convergence on Option B, with gas's Phase 1/2 placement still open pending confirmation it is AB/community-run rather than supplier-run. Status remains proposed — no explicit sign-off recorded.

## Update 2026-09-19 — GIS meetings
Source: [2026-09-09 second GIS meeting](../meeting-minutes/2026-09-09-second-gis-meet.md)

- AfrikaBurn spatial planning co-scoped 2027 to integration with the standalone Container App ([Decision 016](decision-016-proposed-2027-container-app-integration.md)). Further evidence for an Option-B rebaseline, still informal. Status stays **proposed**.

## Update 2026-09-19 — Dev alignment catch-up
Source: [2026-09-17 dev alignment](../meeting-minutes/2026-09-17-dev-alignment.md)

- Finlay restated the same Phase-1 vs Phase-2+ split in operational terms: compulsory / org-linked first; internal camp tools later.
- Near-term packaging named in the meeting (historical context only — this corpus does not track tasks): Finlay drives Container Project user-stories work; Rohan packages village materials; Ruchir reviews Graeme's financial plan when capacity allows; group reconvenes in ~three weeks.
- Further informal Option-B evidence. Status stays **proposed**.
