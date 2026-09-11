---
id: decision-002
title: Architecture integration strategy remains open pending org feedback
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - ../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md
tags:
  - architecture
  - product-direction
---

# Decision 002: Architecture integration strategy remains open pending org feedback
Date: 2026-07-29
Owner: Beyers Nel
Status: proposed
Related: [App Specification](../app-specification.md), [Kick-off meeting minutes](../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md)

## Context

The kick-off meeting raised the question of whether the platform should remain a single application or split organizational and community-led needs into separate structures.

## Decision

We will keep the architecture integration strategy open and treat it as pending feedback from AfrikaBurn before committing to a final structure.

## Alternatives considered

- Commit immediately to a single application structure.
- Commit immediately to a dual-application structure.
- Defer the choice until the organization confirms its requirements.

## Consequences

- Positive: avoids locking the project into the wrong structure before the org has reviewed the concept.
- Negative: implementation planning remains less certain until feedback is received.
- Risks: the team may duplicate design effort if the decision is left open too long.

## Follow-up

- Actions: revisit the architecture once AfrikaBurn feedback is available.
- Review date: after the org pitch and feedback cycle.

## Update 2026-08-05 — Group chat
- 11:12: Graeme Allan asked for the model to be explained in plain terms — one app, one app with switchable modules, or separate apps sharing a database — showing the org/camp boundary question is still not understood outside the technical group.
- 11:13–11:14: Ryan James Noble described the working technical answer: mono-repo apps share one backend/database; external apps (e.g. his Camp 404 build) integrate via an SDK + "Login with AfricaBurn" and can hold their own database; ice and gas are being pulled in as first-class mono-repo apps because they are AB departments.
- Status unchanged: this is a working technical answer from the dev group, not org-confirmed feedback. Still proposed.