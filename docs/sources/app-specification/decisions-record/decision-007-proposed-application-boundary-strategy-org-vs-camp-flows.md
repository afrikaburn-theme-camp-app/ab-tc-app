---
id: decision-007
title: Confirm application boundary strategy for compulsory org flows versus broader camp-management flows
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - ../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md
  - decision-002-proposed-architecture-integration-strategy-open-pending-org-feedback.md
  - decision-005-proposed-backend-first-platform-api-mcp-sdk-no-community-plugins.md
tags:
  - architecture
  - product-direction
---

# Decision 007: Confirm application boundary strategy for compulsory org flows versus broader camp-management flows
Date: 2026-07-29
Owner: Beyers Nel
Status: proposed

## Context
The spec marks Development Direction as at risk because architecture boundaries are still open. Group chat highlighted a split between a tight compulsory org registration app and broader optional camp-planning features (Fin, 2026-07-22 09:56; Graeme acknowledged, 10:42). Current MVP also introduces backend-first extensibility patterns (Decision 005).

## Decision to make
Choose the boundary model for delivery and governance:
- Option A: single integrated app with role-gated modules.
- Option B: dual-application model (compulsory org-registration app + optional camp-management app) on shared backend.
- Option C: hybrid model (single core app now, formal split only when threshold criteria are met).

## Consequences to evaluate
- User friction for compulsory flows.
- Delivery speed and maintenance overhead.
- Security, permission boundaries, and support complexity.

## Follow-up
- Set decision deadline before next major scope freeze.
- Update app-specification.md and roadmap language immediately after acceptance.

## Update 2026-08-05 — Group chat
- 11:13–11:14: Ryan James Noble explained the working model to Graeme Allan: mono-repo apps (org-affiliated modules — users, camps, containers, gas, ice) share one backend/database; a non-mono app (his Camp 404 build) integrates via SDK + "Login with AfricaBurn" API access while keeping its own database. This leans toward Option C (hybrid): a single core app/backend now, with formal separation only for apps built outside the mono-repo.
- 11:12: Graeme Allan's clarifying question shows this model has not yet been confirmed as the agreed boundary — status remains proposed.
