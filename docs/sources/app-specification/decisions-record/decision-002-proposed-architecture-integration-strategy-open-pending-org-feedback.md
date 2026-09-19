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
  - ../meeting-minutes/2026-09-17-dev-alignment.md
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

## Update 2026-09-19 — GIS meetings
Source: [2026-08-11 first GIS meeting](../meeting-minutes/2026-08-11-first-gis-meet.md), [2026-09-09 second GIS meeting](../meeting-minutes/2026-09-09-second-gis-meet.md)

- The Theme Camp App (three surfaces: org console, camp app, supplier portal; shared login) was presented to AfrikaBurn spatial planning. Reception was positive. Shared "Login with AfrikaBurn" identity was well received.
- AfrikaBurn IT is building its own internal systems in parallel. The agreed next step is an **IT-team auth / architecture alignment meeting** — Roger flagged this as the more complicated question; spatial-data sharing itself is straightforward.
- Director-level movement was reported (Christy, **verify**) but is not ratification. Status stays **proposed**. The original review date ("after the org pitch and feedback cycle") is now partly due.

## Update 2026-09-19 — Dev alignment catch-up
Source: [2026-09-17 dev alignment](../meeting-minutes/2026-09-17-dev-alignment.md)

- Tim Doyle (participant relations manager; formerly ITC) shared AfrikaBurn framework material and described alignment timing as favourable. Graeme will arrange a meeting with org IT (**Havon** — spelling **verify**) via Tim to understand the registration / architecture overhaul and explore integration.
- Uniform authentication / a unique AfrikaBurn profile was restated as the integration hinge (Rohan); Graeme noted the org already documents a unique-profile approach in shared GitHub material.
- This advances the named IT-alignment next step from the GIS pass; it is still not org-confirmed architecture feedback. Status stays **proposed**.

## Update 2026-09-19 — WhatsApp Group Chat (TMI Identity)
Source: WhatsApp Group Chat (2026-09-17). Technical detail:
[AfrikaBurn TMI Identity research](https://github.com/afrikaburn-theme-camp-app/ab-tc-app/blob/main/docs/technical-spec/22-afrikaburn-tmi-identity-research.md).

- Graeme shared AfrikaBurn's production identity platform description: **TMI Identity** — applications integrate as **OIDC / OAuth 2.0 clients** (sign-in at `login.afrikaburn.net`); they must not integrate directly with LDAP, PostgreSQL, or the Keycloak database. Named integration conversation: **Havon** (spelling **verify**), Graeme, and the app's developer.
- Conceptual public repo named: [AfrikaBurn/TMI](https://github.com/AfrikaBurn/TMI). Identity module described as private / NDA.
- This is org-side identity posture, not Theme Camp App adoption. Status stays **proposed**.
