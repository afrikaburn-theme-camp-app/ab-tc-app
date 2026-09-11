---
id: decision-011
title: Decide theme-camp layout tool strategy (defer, lightweight planner, or full CAD implementation)
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - decision-004-accepted-first-demonstrable-slice-placement-and-container-management.md
tags:
  - placement
  - product-direction
---

# Decision 011: Decide theme-camp layout tool strategy (defer, lightweight planner, or full CAD implementation)
Date: 2026-07-29
Owner: Beyers Nel
Status: proposed

## Context
Theme-Camp Layout Tool is at risk. Spec expects a rich scaled planner. MVP currently supports layout uploads and placement preferences only due to mapping/data constraints.

## Decision to make
- Option A: defer full layout tooling until map inputs are stable.
- Option B: build a lightweight non-geospatial camp planner first.
- Option C: begin full object-based scaled planner now with assumptions and iterative correction.

## Consequences to evaluate
- Delivery risk and rework likelihood.
- Value to camps before map integration is solved.
- Alignment with Decision 004 MVP demonstration goals.

## Signals from group chat (2026-08-03)
The team ran a UX ideation session (Ryan James Noble, Graeme Allan, with Michael Hazel and Fin K weighing in) that points toward **Option B** with a concrete phased shape, ahead of any formal decision:

- **v1 — generic planner, no real map data:** user defines a bounded area, marks which side is the road, and places labelled shapes (squares/circles/triangles, solid or dotted borders for zone vs object) from a preset library — tent sizes (1x1 to 3x3+), standard parking bays (3x5), generators/fire installations with an automatic safety-radius clearance, a cabling tool to connect power/water, speakers, carpets. Deliberately excludes image upload (cost/value trade-off not worth it yet).
- **v2 — plot-specific:** free-draw or pick-a-plot, with the tool auto-sizing to the camp's actual plot dimensions.
- **v3 — neighbours:** show adjacent camps once placement data supports it.
- **Same tool reused for tent-under-Bedouin placement** (Section 12 / `TENT-*`), just scoped to a smaller area — confirmed as one mechanism, not two.
- **New requirement surfaced, not yet in the spec:** camps should be able to indicate a noise-zone preference — Loud, Loudish, Quietish, Quiet — as part of their placement submission (Graeme Allan, 2026-08-03 10:05). Not yet added to `app-specification.md`; needs a decision on where it lives (likely `REG-*`, Section 14, or the layout tool itself) before it's added.
- **AI/automation explicitly deferred for the actual layout-creation step.** Ryan, Michael, and Fin K aligned against AI-assisted layout automation for now — cost, the risk that camps "won't know what they've proposed," and (per Fin K) a broader discomfort with outsourcing creative/participatory effort to AI. Graeme's one exception: AI/tooling *reconfiguring a proposed layout to fit an assigned erf* if the original doesn't fit — which is already what Section 13 (`ERF-*`) specifies as a placement-team-side suggestion feature, not new scope. Phase 3 of the spec's Suggested First Development Release (`RELEASE-*`, "AI-assisted layout optimisation") should be read as this same narrow, later-phase item, not general-purpose AI layout generation.

## Follow-up
- Reassess immediately after mapping stakeholder meeting outcomes.
- Recommend moving toward Option B formally, with the v1→v2→v3 phasing above, once Decision 012's readiness-gate blocker (Kshetra/Roger summary email, see [Task Assignment](../task-assignment.md)) is cleared and Ryan's UX proposal is reviewed by the team.
- Open question: where the new Loud/Loudish/Quietish/Quiet zone-preference requirement should be specified.
