# Hardening: invite revoke reliability and ID-retention sweep

| Field | Value |
| --- | --- |
| **Category** | Engineering / fix |
| **Doc status** | `in review` |
| **Normative language** | Descriptive only |
| **Requirement IDs** | `SEC-020` (retention); invite lifecycle |
| **Owner / Updated** | Repo maintainers, 2026-10-12 |
| **Depends on** | Spec 06 / cluster-6 (`0035`) |

## Purpose

Port remaining source fixes that are not new product features:
- `#29` — wire ID-retention purge + placement resync coverage
- `#94` — revoke invites reliably + e2e 360 role-spec fixes

Canvas UI fix `#80` already lands in Spec 03.

## Provenance

`51b65e2`, `8566586`. Stacked on cluster-6.
