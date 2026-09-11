# Previous-year carry-forward

| Field                  | Value                                            |
| ---------------------- | ------------------------------------------------ |
| **Category**           | Product                                          |
| **Doc status**         | Active                                           |
| **Normative language** | Descriptive only                                 |
| **Requirement IDs**    | Partial — `PREVYR-001–PREVYR-025` (App Spec §15) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                     |

A returning camp's registration and a returning burner's bio are pre-filled
from the previous edition. Shipped, but documented until now only as a
roadmap bullet — this doc is the first dedicated technical record of it.

## Implements (App Specification)

| App Spec §                    | IDs                                                                               | Status         | Notes                                                                                                                                                                   |
| ----------------------------- | --------------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| §15 Previous-year submissions | PREVYR-011 (archive every submitted version)                                      | ✅             | Per-edition rows, unique on `group_id × edition_id`                                                                                                                     |
| §15                           | PREVYR-002, PREVYR-013 (duplicate last year's submission)                         | ✅             | `packages/core/src/registration-carry-forward.ts`; fills only empty fields, in one transaction, never marks a section complete on the camp's behalf                     |
| §15                           | PREVYR-003 (carry camper data forward)                                            | ✅             | `packages/core/src/bio-carry-forward.ts` — the burner's own bio, since camper data is self-owned (see [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md)) |
| §15                           | PREVYR-012 (start a new submission)                                               | ✅             | "Start fresh" path                                                                                                                                                      |
| §15                           | PREVYR-001 (view all previous submissions)                                        | 🚧             | Only the single most recent prior submission is offered (`limit 1`); no list, no way to open an older year                                                              |
| §15                           | PREVYR-008 (update only changed sections)                                         | 🚧             | Deliberately does the opposite by design — see Drift                                                                                                                    |
| §15                           | PREVYR-009, PREVYR-010 (compare against previous year; flag changed fields)       | 🚧             | Built, but reviewer-side only, and only when the registration was actually carried forward (`carriedForwardFromId` set) — a camp that starts fresh gets no comparison   |
| §15                           | PREVYR-014 (duplicate another, non-latest, previous submission)                   | ❌             | Most recent only                                                                                                                                                        |
| §15                           | PREVYR-015 (start from a template)                                                | ❌             |                                                                                                                                                                         |
| §15                           | PREVYR-016 (flag camper details for re-confirmation)                              | 🚧             | The bio is re-walked every edition (`completedAt: null` on carry), which serves as re-confirmation without a dedicated "changed since last year" flag                   |
| §15                           | PREVYR-017, PREVYR-019–021 (safety certs, insurance, fire/gas — flagged/expiring) | ❌ (vacuously) | Nothing carries because none of these are captured at all (see [`06-registration-and-review.md`](06-registration-and-review.md) Drift)                                  |
| §15                           | PREVYR-022, PREVYR-024, PREVYR-025 (WAP, budget, arrival-date re-confirmation)    | 🚧             | WAP and arrival date are excluded from carry-forward by design (re-asked every year); the declared budget does carry                                                    |
| §15                           | PREVYR-023 (ticket re-confirmation)                                               | ❌             | Tickets are not modelled at all                                                                                                                                         |

## Drift

> ⚠️ **The rollover rule is a deliberate design choice with no dedicated
> Decision Record.** Carry-forward is explicitly a _typing aid, never a
> shortcut through the process_ (`docs/roadmap.md`): a returning camp still
> makes a new proposal reviewed on its own merits, and nothing is marked
> complete on the camp's behalf. This reconciles awkwardly with
> PREVYR-005/006/008, which describe carrying layout/infrastructure forward
> and updating only what changed — the build instead blanks every Form-2
> field every year and pre-fills only Form-1. Recommendation: record this
> reconciliation as a proposed Decision Record rather than leaving an
> unrecorded product choice in `docs/roadmap.md` alone.

## How it is built

- `packages/core/src/registration-carry-forward.ts`: `findCarryForwardSource`
  (the one prior row, ordered by year desc), `diffRegistrations`/
  `changedFields` (the comparison machinery), `NON_CARRIED_FIELDS` (derived
  from `formForSection` — Form-2 fields are structurally excluded).
- `packages/core/src/bio-carry-forward.ts`: copies the prior bio into the new
  edition, everything except `firstTime` (an edition-relative claim).
- `apps/web/lib/registration-store.ts` and `apps/web/lib/bio-store.ts` wire
  the above into the wizard and onboarding flow respectively.
- `apps/org/lib/registration-placement.ts` and
  `apps/org/components/registration/carry-forward-comparison.tsx` render the
  reviewer-side diff when `carriedForwardFromId` is set.
- `apps/web/components/registration/carry-forward-banner.tsx` — the
  camp-facing "You registered in {year}" / "Start fresh" banner.

## Invariants and tests

`packages/core/src/__tests__/{registration-carry-forward,bio-carry-forward}.test.ts`.
