---
id: decision-004
title: The first demonstrable slice should focus on placement and container management
date: 2026-07-29
author: Beyers Nel
status: accepted
type: decision
related:
  - ../app-specification.md
  - ../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md
  - ../meeting-minutes/2026-09-09-second-gis-meet.md
  - decision-016-proposed-2027-container-app-integration.md
tags:
  - mvp
  - delivery
---

# Decision 004: The first demonstrable slice should focus on placement and container management
Date: 2026-07-29
Owner: Beyers Nel
Status: accepted
Related: [App Specification](../app-specification.md), [Kick-off meeting minutes](../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md), [Decision 016](decision-016-proposed-2027-container-app-integration.md)

## Context

The kick-off meeting emphasized showing practical value to the organisation quickly, especially through placement tools and container-related management.

## Decision

The first demonstrable slice of the platform will focus on placement tools and container-related management.

## Alternatives considered

- Attempt to demonstrate the full platform immediately.
- Focus first on a different module such as budgeting or onboarding.
- Focus first on placement and container management.

## Consequences

- Positive: the demo stays concrete and relevant to the organisation’s immediate pain points.
- Negative: other modules will wait for later delivery phases.
- Risks: the team may overfit the early release to the pitch if the wider product plan is not kept in view.

## Follow-up

- Actions: keep later phases documented separately so the MVP focus does not become the long-term boundary.
- Review date: after the initial organisational pitch.

## Update 2026-08-05 — Group chat
- 10:16: Fin K proposed a concrete Phase 1 (AB pitch demo) list materially broader than "placement and container management" alone: account creation, camp entity creation, creative project registration, camp placement application, theme camp mapping, water/ice/gas ordering, and WAP allocation.
- 10:42: Fin K — "If we're happy to present Phase 1 as I outlined above, I don't think we need anything else for now" — no objection raised in review.
- The demonstrable-slice scope should be reconciled against this broader list once [Decision 013](decision-013-proposed-rebaseline-first-release-phase-scope.md) is resolved. Status remains accepted for the original placement/container framing.

## Update 2026-09-19 — GIS meetings
Source: [2026-09-09 second GIS meeting](../meeting-minutes/2026-09-09-second-gis-meet.md)

- AfrikaBurn spatial planning itself co-scoped the 2027 cycle to container placement. The **Container App is a standalone existing app** (it manages a camp's shipping containers end-to-end — buying, ordering, moving, placing, storing — not just placement); the Theme Camp App's involvement is **integration**, not a rebuild — see [Decision 016](decision-016-proposed-2027-container-app-integration.md).
- Status stays **accepted**. Reconciliation with Decision 013's broader Phase-1 list is still open.