---
id: decision-008
title: Decide canonical camper data model (admin-managed roster records versus self-owned profile model)
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - decision-005-proposed-backend-first-platform-api-mcp-sdk-no-community-plugins.md
tags:
  - data-model
  - privacy
  - architecture
---

# Decision 008: Decide canonical camper data model (admin-managed roster records versus self-owned profile model)
Date: 2026-07-29
Owner: Beyers Nel
Status: proposed

## Context
Camper Database and Camp List is marked at risk. The spec requires admin-managed records (import/export/edit model), while MVP uses self-owned Burner Bios linked to memberships.

## Decision to make
Choose and standardize the canonical model:
- Option A: keep self-owned profile model as canonical; add only minimal camp-admin overlays.
- Option B: introduce admin-managed camper records as canonical for camp operations.
- Option C: dual-layer model (self-owned core identity + admin operational layer) with strict field ownership rules.

## Consequences to evaluate
- POPIA/privacy exposure and consent complexity.
- Administrative burden versus participation UX.
- Migration complexity and duplicate-source-of-truth risk.

## Follow-up
- Define authoritative fields and write ownership matrix.
- Align import/export, audit, and retention requirements after decision.
