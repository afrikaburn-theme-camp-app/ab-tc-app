# Org status board

| Field                  | Value                                                                                                                       |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Category**           | Product                                                                                                                     |
| **Doc status**         | Active                                                                                                                      |
| **Normative language** | Descriptive only                                                                                                            |
| **Requirement IDs**    | N/A — extends the spec; App Spec §5 (camper statistics) is a distinct, unbuilt camp-facing feature, not this org-side board |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                                                                |

The organiser console's landing page: a glanceable status board for running
the burn, not a public statistics feature.

## Implements (App Specification)

App Spec §5 (STATS-001–031) describes **camp**-facing statistics and is
separately not built — see the App Spec coverage doc. This board is an
**org**-facing operational dashboard and extends the spec; it should not be
cited as partial progress toward §5.

## How it is built

Headline KPI cards: registered burners in the app (+ bios completed),
camps by registration status with a funnel bar, free vs. registered camps,
questionnaire completion rates for active sends, officer coverage across
registered camps (assigned vs. outstanding), supplier onboarding progress
distribution and standings, a recent-activity feed (from `audit_events`).
Numbers are derived live from real rows — a fresh database correctly shows
zeroes, since nothing is seeded (see the seeding rule in
`AGENTS.md`'s hard engineering rules).

## Surfaces

`apps/org` `/` (overview) and `/status` (status board).

## Invariants and tests

`apps/org/lib/__tests__/{queries-projection,console-gate}.test.ts`.
