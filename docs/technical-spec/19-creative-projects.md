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

## Implements (Requirements)

| Requirements §                | IDs                                                                                                                  | Status | Notes                                                                                                                                                        |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| §18 Creative Project Mode | CREATIVE-001 (art projects), CREATIVE-002 (mutant vehicles), CREATIVE-009 (roles), CREATIVE-018 (annual submissions) | ✅     |                                                                                                                                                              |
| §18                       | CREATIVE-005 (creative installations)                                                                                | 🚧     | `group_kind` has no distinct `installation` value; would ride under `artwork`                                                                                |
| §18                       | CREATIVE-007 (team onboarding)                                                                                       | 🚧     | Shared questionnaire routes now mount on `/artworks` and `/vehicles` as well as `/camps`; camp-authored onboarding presets remain a later cluster             |
| §18                       | CREATIVE-014 (Work Access Passes)                                                                                    | ✅     | Project registration forms request WAPs on the shared camp column; org review shows the count                                                                |
| §18                       | CREATIVE-017 (safety documents)                                                                                      | ✅     | `registration_safety_documents` with expiry; upload via registration upload route; org review gated on personal-information registrations capability         |
| §18                       | CREATIVE-019 (previous-year duplication)                                                                             | ✅     | Project carry-forward allow-list in `@quagga/core`; capped, de-duplicated safety-doc merge into a fresh/existing draft                                       |

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
