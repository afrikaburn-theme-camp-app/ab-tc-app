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

**Spec and feature work.** Every feature that is built MUST have an
accompanying Spec that follows these conventions. The Spec does not have to
land in a separate PR from the feature work: the PR author chooses.

- **Preferred:** get the Spec approved *before* the feature work, so a
  reviewer's objection costs a document edit, not re-work.
- **Allowed:** Spec and implementation in one PR (as the port-wave PRs do,
  where the code was already built elsewhere). The Spec stays `in review`
  until a reviewer has actually reviewed it as a Spec.
- **Either way, the two stay in step.** If a reviewer objects to the Spec and
  it changes, the feature work MUST change to match, in the same PR or a
  later one. A Spec that no longer describes the code, or code that no longer
  matches its Spec, is a defect.

## Index

| Spec | Status | Requirements (primary) | Depends on |
| ---- | ------ | ---------------------- | ---------- |
| [`01-access-expiry-carry-forward-projects-campmates.md`](01-access-expiry-carry-forward-projects-campmates.md) | `in review` | `SEC-019`, `PREVYR-*`, `CREATIVE-014/017/019`, `CORE-002`, `CDB-007` | — |
| [`02-camp-announcements-and-direct-messages.md`](02-camp-announcements-and-direct-messages.md) | `in review` | `COMM-*` / bulletins spine | Spec 01 |
| [`03-camp-roster-and-placement-notify.md`](03-camp-roster-and-placement-notify.md) | `in review` | roster logistics; placement notify | Spec 02 |
| [`04-archive-former-camp-members.md`](04-archive-former-camp-members.md) | `in review` | membership archive | Spec 03 |
| [`05-camp-shifts.md`](05-camp-shifts.md) | `in review` | `CORE-003` shifts | Spec 04 |
