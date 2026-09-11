# Exports and scheduled jobs

| Field                  | Value                                                           |
| ---------------------- | --------------------------------------------------------------- |
| **Category**           | Product                                                         |
| **Doc status**         | Active                                                          |
| **Normative language** | Descriptive only                                                |
| **Requirement IDs**    | Partial — `REG-012`, `REG-029`, `CDB-030`, `CDB-034`, `SEC-020` |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                    |

The placement CSV export, the registration-deadline reminder job, and the
account-deletion sweep. Shipped, but previously documented only as roadmap
bullets and an env-var table row.

## Implements (App Specification)

| App Spec §                   | IDs                               | Status         | Notes                                                                                                                                              |
| ---------------------------- | --------------------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| §14 Annual registration      | REG-012, REG-029                  | ✅ / 🚧        | Export supports placement (layout upload path, staff-assigned camp code)                                                                           |
| §4 Camper database           | CDB-030 (export camper lists)     | ❌ (correctly) | The export is per-**camp** (registrations/placement), not per-camper — it is tested to never emit a personal field. Do not cite it against CDB-030 |
| §19 Permissions and security | SEC-020 (data-retention controls) | 🚧             | The deletion sweep is scheduled; the ID-retention purge is not — see [`02-accounts-and-account-security.md`](02-accounts-and-account-security.md)  |

## Placement export

`apps/org/app/api/registrations/export/route.ts` +
`packages/core/src/registration-export.ts`: a BOM-prefixed CSV, one row per
camp, fixed column set. Tested to never emit any hard-locked personal field
(phone, ID number, passport, emergency contact, medical) — the export type
has no column for any of them, and a regression test
(`packages/core/src/__tests__/registration-export.test.ts`) asserts this
structurally rather than by convention.

## Registration deadline reminders

`packages/core/src/registration-deadline.ts` (21/7/1-day milestones,
`REMINDABLE_STATUSES`, idempotent claim-and-send in one transaction) and
`apps/web/lib/deadline-reminders.ts`, exposed at
`apps/web/app/api/registrations/deadline-reminders/route.ts` (bearer-secret
auth, `timingSafeEqual`).

**Built but dormant, on two counts.** No Vercel Cron entry points at this
route (`apps/web/vercel.json` lists only the deletion sweep) — by decision,
not oversight, pending a scheduler being wired. Separately,
`editions.registration_closes_at` is never set by the seed data, so
`dueReminderMilestone` returns `null` unconditionally regardless of the
scheduler question. Cite this feature as built-but-inert, not as a live
reminder system.

## Account deletion sweep

`POST /api/account/deletion-sweep` — see
[`02-accounts-and-account-security.md`](02-accounts-and-account-security.md)
for the full account-deletion flow. This route is the one job actually
wired to a Vercel Cron entry (`apps/web/vercel.json`, 03:00 daily) and
requires `ACCOUNT_SWEEP_SECRET`.

## Invariants and tests

`packages/core/src/__tests__/{registration-export,registration-deadline}.test.ts`.
