# Camp roster logistics and placement-change notify

| Field                  | Value |
| ---------------------- | ----- |
| **Category**           | Product |
| **Doc status**         | `in review` |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs**    | Partial — roster/logistics (`CDB-*` arrival/departure), placement notify |
| **Owner / Updated**    | Repo maintainers, 2026-10-12 |
| **Depends on**         | Spec 02 / cluster-2 (`0031`) |

## Purpose

Port `feature-source` #75 (migration `0032`), canvas UI fixes #80, and
placement-change notifications #81.

## Behaviour

- Camp members MAY record logistics fields on the roster; camp leads see
  roster operations for placement/ops.
- When staff set or change erf/camp_code placement, camp leads MUST be
  notified (in-app).
- Canvas review answers applied to shipped announcement/DM/roster/safety
  screens (#80).

## Database

Additive `0032_camp_roster_logistics.sql` (and related schema from #75).

## Provenance

`d02545b`, `29c2367`, `90be785`. Stacked on cluster-2.
