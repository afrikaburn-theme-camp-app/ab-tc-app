# Placement codes and erf

| Field                  | Value                                                          |
| ---------------------- | -------------------------------------------------------------- |
| **Category**           | Product                                                        |
| **Doc status**         | Active                                                         |
| **Normative language** | Descriptive only                                               |
| **Requirement IDs**    | Partial — `ERF-001–023` (Requirements §13), `LAYOUT-001–043` (§11) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                   |

AfrikaBurn staff assign each registered camp a code and an erf (a free-text
field on the registration), unblocking downstream logistics (container
booking, gate lists) without building the interactive layout/placement tool
itself. Shipped, but previously undocumented outside a roadmap bullet.

## Implements (Requirements)

| Requirements §                           | IDs                                                           | Status | Notes                                                                                                                                                                                                                                               |
| ------------------------------------ | ------------------------------------------------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| §13 AfrikaBurn map and erf placement | ERF-019–023 (approve/reject/comment/revise loop)              | 🚧     | The mechanism already exists as the registration section-review loop (see [`06-registration-and-review.md`](06-registration-and-review.md)) but nothing in the layout/erf domain uses it — there is no layout artifact to approve or comment on yet |
| §13                                  | ERF-001–018 (structured map/erf data, interactive assignment) | ⚠️     | Blocked — see Drift                                                                                                                                                                                                                                 |
| §11 Theme-camp layout tool           | LAYOUT-001–043                                                | ⚠️     | Not built; camps instead upload a layout diagram (up to 4 files) and state text placement preferences at registration                                                                                                                               |

## Drift

> ⚠️ **DRIFT — opposes-with-proposed-decision, Requirements §11/§13.** AGENTS.md
> and `docs/roadmap.md` previously described placement/layout tooling as
> "permanently" or "if ever" deferred. The governing records — **Decision
> 011 (theme-camp layout tool strategy)** and **Decision 012 (map/erf
> integration strategy and readiness gate)** — are both `proposed`, not
> settled, and Decision 012's own record notes AfrikaBurn holds a usable
> GIS of the site, which undercuts the premise that "no structured geo data
> exists at all." Treat placement/layout as deferred pending those two
> decisions, not as permanently out of scope. 2027 spatial work with the
> org is container-placement **integration** (Decision 016, proposed) — see
> [`21-gis-spatial-data-research.md`](21-gis-spatial-data-research.md).

> ⚠️ **Requirements Decision 004 (accepted) named placement + container
> management as the first demonstrable slice.** The repo shipped
> registration/review/suppliers instead. This is the one confirmed
> decision-not-honoured case in the drift register (as opposed to a
> not-yet-accepted proposal) — see the working group's own **Decision 013
> (rebaseline first-release phase scope, proposed)** for the record that
> should reconcile this.

## How it is built

- `registrations.camp_code` (unique per edition) and `registrations.erf`
  (free text) — staff-assigned, `packages/core/src/placement-codes.ts` +
  `apps/org/lib/actions/placement.ts`.
- **Visible to the camp's members.** `canViewCampPlacement` gates a
  read-only Placement card on the participant camp page
  (`apps/web/components/camp-placement.tsx`); non-members never have the
  data loaded. There is still no camp-side approve, reject or comment loop —
  a real gap against ERF-019.
- **Notified.** First assignment, every change and removal notifies the
  camp's structural lead/admin memberships in-app (and by immediate email
  when the registration email path is on) — best-effort after commit; a
  no-op re-save does not notify
  (`apps/org/lib/actions/placement.ts`).
- Feeds the placement CSV export — see
  [`09-exports-and-scheduled-jobs.md`](09-exports-and-scheduled-jobs.md).

## Invariants and tests

`packages/core/src/__tests__/placement-codes.test.ts`,
`apps/org/lib/__tests__/placement-actions.test.ts`.
