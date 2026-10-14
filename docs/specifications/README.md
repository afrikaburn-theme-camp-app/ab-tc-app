# Specifications

| Field                  | Value                                                                 |
| ---------------------- | --------------------------------------------------------------------- |
| **Category**           | Product                                                               |
| **Doc status**         | Active                                                                |
| **Normative language** | Descriptive only until a feature-spec format is accepted              |
| **Requirement IDs**    | N/A — index; each future spec cites Requirements IDs                  |
| **Owner / Updated**    | Repo maintainers, 2026-10-12                                          |

Feature **Specifications** describe how a change will work, scoped enough to
implement and review. They are **generated from**
[`docs/requirements/`](../requirements/README.md) and reviewed by engineers
before build.

**No new behaviour or product feature may ship without an approved
Specification** sourced from Requirements. Enforcement is convention and PR
templates (see `CONTRIBUTING.md`); there is no CI check yet.

## Roles

| Role | Responsibility |
| ---- | -------------- |
| **Product Owner / Designer** | Writes Specifications from Requirements |
| **Engineers** | Review and modify Specifications for technical implementation, then build |

## Lifecycle (provisional)

| Status | Meaning |
| ------ | ------- |
| `draft` | Being written; not ready for review |
| `in review` | Open for engineer (and working-group) objections |
| `approved` | Ready to implement; feature PRs must link this file |
| `implemented` | Delivered; keep for history / drift checks |

Exact file naming and body format remain **provisional**. The first port-wave
Spec below is the working pattern (metadata header, behaviour sections,
Requirements IDs, surfaces, out of scope, acceptance). Legacy as-built docs
remain under [`../technical-spec/`](../technical-spec/README.md).

**Port-wave convention:** Spec + implementation MAY ship in one PR; Spec
status is `in review` on the branch and becomes `implemented` on merge.
Review of that PR *is* Spec approval (Decision 017 for already-built clusters).

## Index

| Spec | Status | Requirements (primary) | Depends on |
| ---- | ------ | ---------------------- | ---------- |
| [`01-access-expiry-carry-forward-projects-campmates.md`](01-access-expiry-carry-forward-projects-campmates.md) | `in review` | `SEC-019`, `PREVYR-*`, `CREATIVE-014/017/019`, `CORE-002`, `CDB-007` | — |
| [`02-camp-announcements-and-direct-messages.md`](02-camp-announcements-and-direct-messages.md) | `in review` | `COMM-*` / bulletins spine | Spec 01 |
| [`03-camp-roster-and-placement-notify.md`](03-camp-roster-and-placement-notify.md) | `in review` | roster logistics; placement notify | Spec 02 |
| [`04-archive-former-camp-members.md`](04-archive-former-camp-members.md) | `in review` | membership archive | Spec 03 |
