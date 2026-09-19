---
id: decision-012
title: Decide AfrikaBurn map and erf integration strategy and readiness gate
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - ../meeting-minutes/2026-08-11-first-gis-meet.md
  - ../meeting-minutes/2026-09-09-second-gis-meet.md
  - ../meeting-minutes/2026-09-17-dev-alignment.md
  - https://github.com/afrikaburn-theme-camp-app/ab-tc-app/blob/main/docs/technical-spec/21-gis-spatial-data-research.md
  - decision-016-proposed-2027-container-app-integration.md
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
- AfrikaBurn is moving to a **GIS map system** that has mapped the whole site "with great precision" (Graeme Allan, relaying AfrikaBurn IT). *(Correction 2026-09-19: the 2026-08-03 note said "CIS"; that was a mishearing of GIS / QGIS — see the GIS meetings.)* Blocks are irregular and vary in size — examples given: 120m×60m, 95m×60m, and some as small as 50m — so camp layouts need to be placed at true scale within an assigned block, alongside other camps placed by the AfrikaBurn placement team.
- **Readiness-gate next step identified:** AfrikaBurn IT (Kshetra, cc Roger) will not schedule a workshop until the team sends a short written summary of what we want to achieve and our planned tech stack. Graeme will forward it once received.
- Scope clarified: this contact is specifically about **map/erf integration**, not the contributor app as a whole (confirmed 2026-08-03 09:33–09:33, Graeme Allan replying "Just the maps").
- Confirms Decision 011's direction: whatever layout tool ships should be able to place a camp's preferred layout, at scale, into a GIS-provided block/erf shape — supporting Section 13 (`ERF-*`) as specified.

## Follow-up
- Status stays **proposed until GIS access is formally granted**.
- Technical contract detail (formats, layers, DEM provenance) lives in [GIS / spatial-data research](https://github.com/afrikaburn-theme-camp-app/ab-tc-app/blob/main/docs/technical-spec/21-gis-spatial-data-research.md), not here.

## Update 2026-09-19 — GIS meetings
Source: [2026-08-11 first GIS meeting](../meeting-minutes/2026-08-11-first-gis-meet.md), [2026-09-09 second GIS meeting](../meeting-minutes/2026-09-09-second-gis-meet.md)

- The readiness-gate **workshop has been held** (both meetings). The written-summary blocker is cleared.
- Agreed access model: **read-only access to specific vector layers** (theme-camp boundaries first); updates returned to AfrikaBurn for manual re-integration; org stays system of record. "No API for now."
- Roger committed to granting that access within 1–2 weeks of 2026-09-09. **The grant itself has not been recorded.** Status therefore stays **proposed**.
- 2027 product scope that depends on this access is [Decision 016](decision-016-proposed-2027-container-app-integration.md).

## Update 2026-09-19 — Dev alignment catch-up
Source: [2026-09-17 dev alignment](../meeting-minutes/2026-09-17-dev-alignment.md)

- Graeme reported a meeting with AfrikaBurn's acting EDO (production manager Christie / Christy — **verify** spelling) who supported incremental ("baby steps") progress and indicated access to a GIS layer useful for containers and camp placement.
- That report is **second-hand** and mixes "given" / "will be given" language. It is **not** the formal grant this decision requires (nor a substitute for Roger's read-only Postgres vector-layer commitment from 2026-09-09).
- Status stays **proposed** until access is formally granted and recorded.
