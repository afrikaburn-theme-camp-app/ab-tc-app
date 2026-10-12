# Camp onboarding preset with steps and totals

| Field | Value |
| --- | --- |
| **Category** | Product |
| **Doc status** | `in review` |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs** | `ONBOARD-019`, `ONBOARD-020`, related `ONBOARD-*` |
| **Owner / Updated** | Repo maintainers, 2026-10-12 |
| **Depends on** | Spec 05 / cluster-5 (`0034`) |

## Purpose

Port `feature-source` #87 (migration `0035`): camp-authored onboarding
preset with steps and completion totals.

## Behaviour

Camps MAY configure an onboarding preset (steps/totals); completion is
tracked for members per the shipped rules.

## Database

Additive `0035_onboarding_progress.sql`.

## Provenance

`9c97c3c`. Stacked on cluster-5.
