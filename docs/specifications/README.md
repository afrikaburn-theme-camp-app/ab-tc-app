# Specifications

| Field                  | Value                                                                 |
| ---------------------- | --------------------------------------------------------------------- |
| **Category**           | Product                                                               |
| **Doc status**         | Active                                                                |
| **Normative language** | Descriptive only until a feature-spec format is accepted              |
| **Requirement IDs**    | N/A — index; each future spec cites Requirements IDs                  |
| **Owner / Updated**    | Repo maintainers, 2026-10-08                                          |

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

Exact file naming and body format are **provisional until the Product Owner /
Designer defines them**. Do not impose a template here yet. Legacy as-built
docs remain under [`../technical-spec/`](../technical-spec/README.md) and will
migrate into this folder once the format is settled.

**Spec and feature work.** Every built feature MUST have an accompanying Spec
([Decision 017](../requirements/decisions-record/decision-017-accepted-spec-driven-feature-delivery.md),
Amendment 1). Preferred: the Spec is `approved` before the feature work starts.
Permitted: Spec and implementation in one PR, provided the Spec is reviewed as
a Spec and is `approved` before that PR merges. Merging code never approves a
Spec, and the two must stay in step.

## Index

_No feature Specifications yet._
