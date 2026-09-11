---
id: decision-006
title: Use shadcn plus Tailwind with versioned pen.dev design files as the primary UI design and build workflow
date: 2026-07-29
author: Beyers Nel
status: accepted
type: decision
related:
  - ../app-specification.md
  - ../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md
tags:
  - frontend
  - design-system
  - tooling
---

# Decision 006: Use shadcn plus Tailwind with versioned pen.dev design files as the primary UI design and build workflow
Date: 2026-07-29
Owner: Beyers Nel
Status: accepted
Related: [App Specification](../app-specification.md), [Kick-off meeting minutes](../meeting-minutes/2026-07-28-theme-camp-app-kick-off.md)

## Context

The team discussed whether to adopt an external open-source design system (Astryx) versus building with the current stack. Ryan confirmed the implementation is using shadcn + Tailwind and that design files are maintained in pen.dev and stored in the codebase as versionable assets (group chat, Ryan, 2026-07-24 01:20 and 11:26). The alternative design-system suggestion was explored but not adopted.

Given active implementation on this stack and no competing approved standard, a documented tooling baseline is needed.

## Decision

Adopt the current frontend and design-tooling baseline for MVP delivery:

- UI component system: shadcn components with Tailwind.
- Design source workflow: pen.dev design files managed as versioned project assets.
- Business logic remains first-party and project-owned, rather than outsourced to third-party component abstractions.

## Alternatives considered

- Replace the stack with Astryx/open-source social-first component presets.
- Delay UI implementation until a broader design-system evaluation is complete.
- Continue without an explicit tooling decision.

## Consequences

- Positive: keeps implementation velocity high by staying on the already-working stack.
- Positive: preserves local ownership of domain logic while still leveraging proven UI primitives.
- Negative: may forgo some prebuilt component breadth from alternative systems.
- Risk: future migration cost if a different system is later selected.

## Follow-up

- Actions: document guardrails for design-file updates and component usage consistency in implementation guides.
- Review date: after MVP stabilization or if design-system constraints become delivery blockers.
