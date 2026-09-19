# 2026-09-09 Second GIS meeting

## Source
- Meeting: 9 September 2026 (~42 min).
- Attendees (from the Fathom export): Kshetra Govindasamy, Roger Van Wyk, Graeme Allan, Ryan James Noble, Beyers Nel, Krishna Lodha. Note-takers labelled "Tim" / "Havon" in the export — identity unverified (one remark treats them as AI note-takers).
- Recorded via Fathom. The summary below is interpreted from that transcript.
- Transcript wording is **not** authoritative spec language. Speaker attribution in the Fathom export is noisy in places.

## Terminology
In the meeting the Theme Camp App was referred to as "Ryan's app" / "Ryan's team". Ryan James Noble has left the team. New writing in this corpus uses **Theme Camp App** (Quagga Portal).

The **Container App** is a standalone existing app, separate from the Theme Camp App. It manages everything to do with a camp's shipping containers — buying one, ordering one, having it moved, having it placed on site, moving it offsite to storage — and is not limited to placement. In this meeting the 2027 project was described as a "container placement" tool; that planning slice is the point of integration with the Container App, not a rebuild of it.

## Meeting Purpose

To explore integrating a community-built app with AfrikaBurn's spatial data.

## Key Takeaways

- Proposed Integration: The Theme Camp App, built on a single Postgres database with AfrikaBurn's auth, could replace fragmented Google Sheets and enable powerful new coordination tools.
- Immediate Scope: The 2027 project is limited to a "container placement" tool. This requires a formal proposal to Lexi (Placements Lead) to justify adding to her established workflow.
- Data Access: The Theme Camp App team will receive read-only access to specific vector layers from AfrikaBurn's new local Postgres server, which is replacing AWS.
- Critical Next Step: The Theme Camp App team must meet with AfrikaBurn's IT team to align on the app's architecture and auth system, as they are also building internal systems.

## Topics

### AfrikaBurn's Spatial Data & Infrastructure

- Data Source: QGIS project with layers for infrastructure, drainage, contours, and high-res imagery.
- Infrastructure Migration: Data is moving from AWS to a new local Postgres server at the AfrikaBurn office.
- Data Access Plan:
    - The Theme Camp App team gets read-only access to specific vector layers (e.g., theme camp boundaries).
    - Updates are sent back to AfrikaBurn for manual integration to protect data integrity.
- Data Collection:
    - Elevation: A Digital Elevation Model (DEM) is created from high-resolution drone photogrammetry (not LIDAR).
    - Drainage: Lines are algorithmically derived from the DEM.
    - Geographic Features: Mapping features like sand dunes requires on-the-ground validation with tools like QField.

### Proposed App: A Centralized Platform

- Problem: Current coordination relies on fragmented Google Sheets, creating chaos and inefficiency.
- Solution: A single, centralized app built on a monorepo architecture.
    - Tech Stack: Next.js, Tailwind, ShadCN, Neon Postgres (hosted on Vercel).
    - Core Principle: A shared login system using AfrikaBurn's identity provider enables secure, cross-app data sharing.
- Key Features:
    - Org Portal: Manages applications, suppliers, and POPIA-compliant data (e.g., passport numbers) with full audit logs.
    - Theme Camp Management: Enables self-service for camp registration, roles, and resource sharing.
    - Questionnaire Builder: Allows the org to create mandatory forms, solving the problem of collecting information from participants.

### The 2027 Container Placement Project

- Goal: Build a tool for theme camps to plan their internal layouts after receiving their allocated boundary.
- Workflow:
  1. Input: A camp receives its allocated boundary as a vector file.
  2. Planning: The camp uses the tool to place pre-defined objects (e.g., rectangles for containers) within its boundary.
  3. Output: The tool generates a layout plan for submission.
- Challenge: The tool must integrate with Lexi's (Placements Lead) established workflow.
    - Rationale: A formal proposal is needed to demonstrate how the tool saves time and adds value without disrupting her process.
- Dependency: The project is blocked until Kshetra receives final specs (shapes, sizes) for containers and other infrastructure from DPW.

## Next Steps (as of the meeting)

These were operational follow-ups at the time of the meeting. This corpus no longer tracks tasks; they are recorded here only as historical context.

- Roger: grant the Theme Camp App team read-only Postgres access to vector layers within the next 1–2 weeks (from 2026-09-09).
- Kshetra: get final container specs from DPW; draft a formal proposal for Lexi (Placements Lead); schedule a meeting between the Theme Camp App team and AfrikaBurn IT.
- Theme Camp App team: UX demo of the 2027 container-placement planning slice (Container App integration) using a static screenshot; prepare for the IT-team architecture/auth meeting.
