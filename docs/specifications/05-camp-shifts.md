# Camp shifts with sign-up and swaps

| Field | Value |
| --- | --- |
| **Category** | Product |
| **Doc status** | `in review` |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs** | `CORE-003`; shift-related Requirements |
| **Owner / Updated** | Repo maintainers, 2026-10-12 |
| **Depends on** | Spec 04 / cluster-4 (`0033`) |

## Purpose

Port `feature-source` #86 (migration `0034`): camp shift teams, member
sign-up, and hand-on/swaps without lead approval.

## Behaviour

Camps MAY define shifts/teams; members MAY sign up and swap/hand-on per
core rules. No lead approval gate for swaps (as shipped in source).

## Database

Additive `0034_camp_shifts.sql`.

## Provenance

`e4a12ad`. Stacked on cluster-4.
