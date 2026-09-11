---
id: decision-012
title: Decide AfrikaBurn map and erf integration strategy and readiness gate
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - ../task-assignment.md
tags:
  - placement
  - integration
---

# Decision 012: Decide AfrikaBurn map and erf integration strategy and readiness gate
Date: 2026-07-29
Owner: Beyers Nel
Status: proposed

## Context
AfrikaBurn Map and Erf Placement is at risk. Implementation is blocked on map/system process clarity from AfrikaBurn stakeholders.

## Decision to make
- Option A: define formal readiness gate and postpone implementation until required map/data contracts exist.
- Option B: implement with provisional manual map overlays while contracts are negotiated.
- Option C: build data adapters now against expected formats and harden once official formats are confirmed.

## Consequences to evaluate
- Rework risk if upstream map format/process changes.
- Time-to-value for placement support.
- Operational dependency on external stakeholders.

## Progress and new information (group chat, 2026-08-03)
- AfrikaBurn is moving to a **CIS map system** that has mapped the whole site "with great precision" (Graeme Allan, relaying AfrikaBurn IT). Blocks are irregular and vary in size — examples given: 120m×60m, 95m×60m, and some as small as 50m — so camp layouts need to be placed at true scale within an assigned block, alongside other camps placed by the AfrikaBurn placement team.
- **Readiness-gate next step identified:** AfrikaBurn IT (Kshetra, cc Roger) will not schedule a workshop until the team sends a short written summary of what we want to achieve and our planned tech stack. Graeme will forward it once received. This is now tracked as an explicit task — see [Task Assignment](../task-assignment.md) ("Draft and send a summary email... to AfrikaBurn IT").
- Scope clarified: this contact is specifically about **map/erf integration**, not the contributor app as a whole (confirmed by Ryan James Noble, 2026-08-03 09:33–09:33, Graeme Allan replying "Just the maps").
- Confirms Decision 011's direction: whatever layout tool ships should be able to place a camp's preferred layout, at scale, into a CIS-provided block/erf shape — supporting Section 13 (`ERF-*`) as specified.

## Follow-up
- Capture outcomes from Roger/Kshetra meeting and finalize required integration contract checklist.
- Immediate blocker: get the goals + tech-stack summary email sent to Kshetra/Roger (task assigned to Ryan James Noble, 2026-08-03) — this unblocks scheduling the actual workshop.
