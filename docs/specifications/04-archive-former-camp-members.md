# Archive former camp members

| Field | Value |
| --- | --- |
| **Category** | Product |
| **Doc status** | `in review` |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs** | Partial — camp membership lifecycle / roster |
| **Owner / Updated** | Repo maintainers, 2026-10-12 |
| **Depends on** | Spec 03 / cluster-3 (`0032`) |

## Purpose

Port `feature-source` #82 (migration `0033`): archive former camp members
without destroying history needed for ops.

## Behaviour

Camp leads/admins MAY archive former members; archived members are excluded
from active roster views while retained for audit/history as implemented.

## Database

Additive `0033_archive_former_members.sql`.

## Provenance

`128c4d1`. Stacked on cluster-3.
