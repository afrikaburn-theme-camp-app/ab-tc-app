---
id: decision-005
title: Build a backend-first platform with user-scoped API and MCP access, with SDK/template extensibility and no community plugins
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - ../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md
  - ../meeting-minutes/2026-09-09-second-gis-meet.md
tags:
  - architecture
  - platform
  - integration
---

# Decision 005: Build a backend-first platform with user-scoped API and MCP access, with SDK/template extensibility and no community plugins
Date: 2026-07-29
Owner: Beyers Nel
Status: proposed
Related: [App Specification](../app-specification.md), [Kick-off meeting minutes](../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md)

## Context

In group-chat discussion after kickoff, Ryan proposed building the system as a backend-first platform with a user-scoped API and MCP server, so camps or projects can build their own client apps while reusing the shared identity/profile and permission backbone (group chat, Ryan, 2026-07-24 16:41).

Further discussion accepted configurable modules but rejected open community plugin execution in the core app due to security and maintenance risk, favouring an SDK/template + pull-request contribution model (group chat, Ryan and Ruchir, 2026-07-28 20:37–20:46).

This direction directly affects architecture boundaries, integration model, extension mechanics, and security posture.

## Decision

Treat backend-first platform architecture as the preferred technical direction for MVP evolution:

- Keep core domain capability in shared backend and packages.
- Expose user-scoped access through controlled API and MCP interfaces.
- Support extensibility through an SDK/template model and upstream contribution workflow.
- Do not support arbitrary community plugin execution in the core platform.

This remains proposed pending AfrikaBurn feedback and the open architecture-integration decision ([Decision 002](decision-002-proposed-architecture-integration-strategy-open-pending-org-feedback.md)).

## Alternatives considered

- Keep all functionality in a single first-party UI app only.
- Split into completely independent apps with no shared backend contract.
- Allow runtime community plugin loading in the main app.

## Consequences

- Positive: scales to diverse camp workflows without forcing all complexity into one compulsory interface.
- Positive: preserves stronger security controls than open plugin execution.
- Negative: increases initial backend/API design and governance overhead.
- Risk: if API/MCP boundaries are underspecified, custom integrations may fragment behaviour.

## Follow-up

- Actions: define minimum public API/MCP contract and permission boundaries; document SDK/template governance rules.
- Review date: after AfrikaBurn architecture feedback and first external camp-integration trial.

## Update 2026-08-05 — Group chat
- 11:13–11:14: Ryan James Noble elaborated the model in response to a question from Graeme Allan: mono-repo apps share one backend/database; a non-mono app (his Camp 404 build) integrates via SDK + "Login with AfricaBurn," giving it API access to shared tooling while keeping its own database. Ice and gas are being pulled into the mono-repo as first-class apps since they are AB departments; supplier-facing tooling stays external.
- This confirms and elaborates the existing direction rather than changing it. Status remains proposed pending AfrikaBurn feedback (Decision 002).

## Update 2026-09-19 — GIS meetings
Source: [2026-09-09 second GIS meeting](../meeting-minutes/2026-09-09-second-gis-meet.md)

- MCP / "Login with AfrikaBurn" was pitched to AfrikaBurn spatial planning and received without objection.
- Kshetra's "maybe not an API for now" referred to **GIS-server access**, not this platform API. The two threads must not be collapsed — GIS access is Decision 012. Status stays **proposed**.
