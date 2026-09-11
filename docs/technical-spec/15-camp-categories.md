# Camp categories

| Field                  | Value                                                                  |
| ---------------------- | ---------------------------------------------------------------------- |
| **Category**           | Product                                                                |
| **Doc status**         | Active                                                                 |
| **Normative language** | Descriptive only                                                       |
| **Requirement IDs**    | N/A — extends the spec; no App Spec section names a directory taxonomy |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                           |

An org-defined, per-edition taxonomy ("theme topics") that camps pick from
so the public directory can filter by category.

## Implements (App Specification)

No App Spec section requires this. It extends the spec's §4a directory
concept with a filtering mechanism.

## How it is built

- **Org CRUD** on a per-edition category catalog (name, optional emoji,
  sort). Camps pick theirs (multi-select, suggested limit of 4) on the camp
  profile/registration; the directory gains filter chips by category.
- No formal taxonomy exists in the source corpus — the seed set is a
  proposed starting point the org can edit freely: Family-friendly, Food &
  drink, Bar, Music & sound, Performance, Workshops & talks, Art & making,
  Wellness & chill, Games & play, Late night, Quiet camp, Inclusive space.
- Some directory facts already exist as registration data (family-friendly,
  food-gifting, operating hours, sound level) and complement rather than
  duplicate the category system — the directory may also filter on those.

## Surfaces

Org console `/categories` — CRUD by the System manager, readable by every
org rank. `apps/web` `/directory` — filter chips.

## Invariants and tests

`packages/core/src/__tests__/camp-categories.test.ts`,
`e2e/specs/org-staff/camp-categories-crud.spec.ts`,
`e2e/specs/god/camp-categories-crud.spec.ts`.
