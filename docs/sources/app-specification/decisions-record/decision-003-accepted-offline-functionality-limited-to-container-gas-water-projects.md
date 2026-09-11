---
id: decision-003
title: Offline functionality is limited to container gas and water projects
date: 2026-07-29
author: Beyers Nel
status: accepted
type: decision
related:
  - ../app-specification.md
  - ../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md
tags:
  - offline
  - operations
---

# Decision 003: Offline functionality is limited to container gas and water projects
Date: 2026-07-29
Owner: Beyers Nel
Status: accepted
Related: [App Specification](../app-specification.md), [Kick-off meeting minutes](../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md)

## Context

The meeting aligned offline work specifically with the container, gas, and water organization projects.

## Decision

Offline functionality will be scoped to the container, gas, and water organization projects unless a later decision expands that scope.

## Alternatives considered

- Build offline support for all modules.
- Exclude offline support entirely.
- Limit offline support to the container, gas, and water projects.

## Consequences

- Positive: keeps offline effort focused on the highest-priority operational workflows.
- Negative: other modules will continue to depend on normal connectivity.
- Risks: if more modules later need offline support, additional design work will be required.

## Follow-up

- Actions: revisit scope only if the org or delivery team identifies a broader offline need.
- Review date: after the initial org pitch or when offline requirements change.