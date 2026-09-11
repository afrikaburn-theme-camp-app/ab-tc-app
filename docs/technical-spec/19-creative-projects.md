# Creative projects (artworks and mutant vehicles)

| Field                  | Value                                                                                                                      |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Category**           | Product                                                                                                                    |
| **Doc status**         | Active                                                                                                                     |
| **Normative language** | Descriptive only                                                                                                           |
| **Requirement IDs**    | Partial — `CREATIVE-001, CREATIVE-002, CREATIVE-005, CREATIVE-007, CREATIVE-009, CREATIVE-014, CREATIVE-017, CREATIVE-018` |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                                                               |

Art projects and mutant vehicles are first-class citizens of the same
`groups` spine as theme camps — a different `kind`, the same identity,
membership, roles and review machinery.

## Implements (App Specification)

| App Spec §                | IDs                                                                                                                  | Status | Notes                                                                                                                                                        |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| §18 Creative Project Mode | CREATIVE-001 (art projects), CREATIVE-002 (mutant vehicles), CREATIVE-009 (roles), CREATIVE-018 (annual submissions) | ✅     |                                                                                                                                                              |
| §18                       | CREATIVE-005 (creative installations)                                                                                | 🚧     | `group_kind` has no distinct `installation` value; would ride under `artwork`                                                                                |
| §18                       | CREATIVE-007 (team onboarding)                                                                                       | 🚧     | The Burner Bio gate applies to all kinds; project-scoped questionnaire authoring exists for camps but has no equivalent route for artworks/vehicles yet      |
| §18                       | CREATIVE-014 (Work Access Passes)                                                                                    | ❌     | `s4WorkAccessPasses` is a `registrations`-table column; projects don't write to `registrations` at all — projects have _no_ WAP field, less built than camps |
| §18                       | CREATIVE-017 (safety documents)                                                                                      | ❌     | The artwork registration form has a safety callout, not a document upload                                                                                    |
| §18                       | CREATIVE-019 (previous-year duplication)                                                                             | ❌     | Carry-forward is `registrations`-only (see [`07-previous-year-carry-forward.md`](07-previous-year-carry-forward.md)); camps got it, projects did not         |

## How it is built

- `groups.kind ∈ {org, theme_camp, artwork, mutant_vehicle}` — one table,
  one permission spine (`project-roles.ts`, `project-permissions.ts`
  are kind-agnostic).
- Annual submissions use a **different mechanism** from the camp
  registration wizard: questionnaire-activation-backed responses
  (`apps/web/lib/project-registration-store.ts`), not `registrations`
  columns — read on the org side by `apps/org/lib/project-review.ts`.
- Anything built for camps on the shared spine arrives for creative
  projects roughly free; the gaps above (WAP, safety documents,
  carry-forward) are exactly the places that were built directly onto
  `registrations` rather than onto the shared spine, and so did not
  generalise automatically.

## Invariants and tests

`apps/web/lib/__tests__/project-registration-store.test.ts`.
