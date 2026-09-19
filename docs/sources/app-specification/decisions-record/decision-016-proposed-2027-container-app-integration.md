---
id: decision-016
title: 2027 Container App integration — spatial scope, gates, and Placements-workflow integration
date: 2026-09-19
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - decision-004-accepted-first-demonstrable-slice-placement-and-container-management.md
  - decision-011-proposed-theme-camp-layout-tool-strategy.md
  - decision-012-proposed-map-erf-integration-strategy-readiness-gate.md
  - ../meeting-minutes/2026-08-11-first-gis-meet.md
  - ../meeting-minutes/2026-09-09-second-gis-meet.md
  - https://github.com/afrikaburn-theme-camp-app/ab-tc-app/blob/main/docs/technical-spec/21-gis-spatial-data-research.md
tags:
  - placement
  - integration
  - 2027
---

# Decision 016: 2027 Container App integration — spatial scope, gates, and Placements-workflow integration
Date: 2026-09-19
Owner: Beyers Nel
Status: proposed
Related: [App Specification](../app-specification.md), [Decision 004](decision-004-accepted-first-demonstrable-slice-placement-and-container-management.md), [Decision 011](decision-011-proposed-theme-camp-layout-tool-strategy.md), [Decision 012](decision-012-proposed-map-erf-integration-strategy-readiness-gate.md), [2026-08-11 first GIS meeting](../meeting-minutes/2026-08-11-first-gis-meet.md), [2026-09-09 second GIS meeting](../meeting-minutes/2026-09-09-second-gis-meet.md), [GIS research](https://github.com/afrikaburn-theme-camp-app/ab-tc-app/blob/main/docs/technical-spec/21-gis-spatial-data-research.md)

## Context

Two GIS meetings with AfrikaBurn spatial planning (2026-08-11, 2026-09-09)
narrowed the 2027 engagement. AfrikaBurn's Placements workflow is owned by
Lexi (Placements Lead); allocations currently land around 30 January. The
org will not add a tool to that workflow without a formal proposal showing
it saves time without disrupting it.

The **Container App** is an existing standalone app, separate from the Theme
Camp App. It manages everything to do with a camp's shipping containers:
buying one, ordering one, having it moved, having it placed on site, and
moving it offsite to storage. It is **not limited to placement**. The 2027
cycle discussed with AfrikaBurn spatial planning concerns its
container-placement slice. The Theme Camp App will integrate with the
Container App in future; how is not yet specced. Technical notes live in the
GIS research doc, not here — and neither record captures the Container App's
internals.

This record is the operational scope and the gates. It is not the layout-tool
strategy question (Decision 011) and not the GIS access-contract question
(Decision 012).

## Decision to make

Provisionally: for the 2027 cycle, the Theme Camp App's spatial work is the
integration with the standalone Container App (its container-placement
slice, and with AfrikaBurn GIS), gated on all four of:

1. A formal proposal **accepted by Lexi** (Placements Lead) that the tool
   saves her and Nikki time against the current allocation workflow.
2. **DPW final specs** for container and other infrastructure shapes and
   sizes (Kshetra chasing as of 2026-09-09).
3. **Formal GIS read-only access** granted (Decision 012 — still proposed
   until that grant exists).
4. An **IT-team auth / architecture alignment meeting** held — AfrikaBurn
   IT is building internal systems in parallel; Roger flagged this as
   the more complicated question.

Until those gates clear, the Theme Camp App does not treat container-workflow
integration as in-cycle product scope.

## Alternatives considered

- Build a full theme-camp layout tool in the Theme Camp App now — rejected
  for 2027; see Decision 011. The org asked for one piece of work at a time.
- Wait for a complete map/data contract before any integration — rejected;
  read-only vector-layer access (once granted) is enough to start the
  integration conversation.
- Treat the Container App as in-scope Theme Camp App product — rejected; it
  is a standalone app covering the whole container lifecycle. Only
  integration concerns belong here.

## Consequences

- Positive: 2027 scope is small enough to put in front of Placements without
  asking Lexi to change her process.
- Negative: the Theme Camp App's own layout/erf product (App Spec §11 / §13)
  stays deferred.
- Risks: Lexi may decline; DPW specs may slip; GIS access may not land
  (Decision 012). Ground GPS accuracy (Roger) means even a working
  integration is a planning aid, not a survey instrument.

## Follow-up

- Actions: none tracked in this corpus. Engineering work is tracked via
  GitHub issues on [afrikaburn-theme-camp-app/ab-tc-app](https://github.com/afrikaburn-theme-camp-app/ab-tc-app).
- Review date: after Lexi's response to the proposal, or when Decision 012
  moves off `proposed`.
