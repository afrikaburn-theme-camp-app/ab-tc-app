# Camp roster logistics and placement-change notify

| Field                  | Value |
| ---------------------- | ----- |
| **Category**           | Product |
| **Doc status**         | `in review` — Spec review is this PR; on merge → `implemented` |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs**    | `CDB-011`, `CDB-012`, `CDB-013`, `CDB-014`, `CDB-028` (self-edit logistics), `CDB-030`–`CDB-033` (export/filter/search/missing-info as shipped); placement notify (no dedicated Requirement ID — extends staff erf/camp-code assignment) |
| **Owner / Updated**    | Repo maintainers, 2026-10-14 |
| **Depends on**         | Spec 02 / cluster-2 (`0031`) |

## Purpose

Port `feature-source` #75 (migration `0032` roster logistics), canvas UI
fixes #80, and placement-change notifications #81 into this repo. This Spec
is the ratification contract for that port (Decision 017).

## Behaviour (WHAT ships)

### 1. Camp roster logistics (`CDB-011`–`014`)

- Theme-camp, artwork, and mutant-vehicle projects MUST expose a roster to
  members who hold `view_member_details` (structural lead/admin backstop).
  Non-members and members without that permission MUST be refused as
  not-found (free-camp undiscoverability).
- Roster rows MUST NOT carry hard-locked fields or medical notes (list
  shape only). Bio *completion* MAY appear; bio contents MUST NOT.
- Members MAY record their own logistics for the current edition:
  `joining_build`, `joining_strike`, `arrival_date`, `departure_date`
  (`CDB-011`–`014`). Leads MUST NOT edit another member’s logistics
  (self-owned; Decision 008 posture).
- Arrival MUST NOT be after departure when both are set (DB check + Zod).
- Roster viewers of *this* project MAY see logistics columns and aggregates
  (build/strike counts, etc.). Logistics MUST NOT be public or generally
  visible to camp-mates outside the roster permission.
- Viewers with roster access MAY search, filter, and export CSV
  (`canExportCampRoster` = same gate as view).

### 2. Placement-change notify (staff erf / camp_code)

- Org staff with `update` in the `registrations` domain MAY assign or clear
  `registrations.camp_code` and `registrations.erf` (existing placement
  codes path).
- When placement is **first set**, **changed**, or **removed**, the camp’s
  structural `lead`/`admin` memberships MUST be notified in-app, and MUST
  receive immediate email when the registration email path is enabled
  (`placementNotification` / `shouldSendImmediateEmail`).
- A no-op re-save of identical values MUST NOT notify (`placementChange`
  returns null).
- Notification failure MUST NOT roll back a committed placement write
  (best-effort after commit).
- Plain members MUST NOT receive placement notifications (leads/admins
  only).

### 3. Canvas UI fixes (#80)

- Shipped announcement / DM / roster / safety screens MUST reflect the
  canvas review answers applied in this cluster (layout/copy/control
  fixes only — no new product Behaviour beyond §§1–2).

## Surfaces

| App | Audience | Notable routes |
| --- | -------- | -------------- |
| `web` | Members with `view_member_details`; each member for own logistics | `/camps/[slug]/roster` (and artwork/vehicle roster equivalents where mounted) |
| `org` | Staff with registrations update | Placement assign UI on registration review; triggers notify to web leads |
| `web` | Camp leads/admins | In-app notification + email for placement changes |

## Database

Additive `0032_camp_roster_logistics.sql`:

- Table `membership_logistics`: `membership_id`, `edition_id`,
  `joining_build`, `joining_strike`, `arrival_date`, `departure_date`
- Unique `(membership_id, edition_id)`
- Check `membership_logistics_arrival_before_departure`

Placement columns `registrations.camp_code` / `registrations.erf` already
existed; this cluster adds notify behaviour only for those writes.

## Out of scope (this PR)

- Member archive, shifts, onboarding presets (Specs 04–06)
- Interactive map / erf grammar / camp-side approve-reject loop
  (`ERF-001`–`023` layout tooling; Decisions 011/012 still proposed)
- Admin editing another camper’s logistics (`CDB-028` admin-managed model
  remains proposed under Decision 008)
- Spreadsheet import (`CDB-029`)
- Showing erf/camp_code on the participant app camp page (org-assigned;
  notify text carries the change, not a persistent camp-facing placement
  panel in this port)

## Acceptance

- Gate: `pnpm -w exec turbo run lint typecheck test build` for touched workspaces
- E2E (when run): `e2e/specs/camp-lead/roster-ops.spec.ts`; org registration
  review placement notify cases in
  `e2e/specs/org-staff/registration-review.spec.ts` (set/change/remove;
  no notify on no-op; leads not plain members)
- Spec status → `implemented` on merge

## Provenance

`feature-source` `d02545b`, `29c2367`, `90be785`. Stacked on cluster-2.

## Implementation gaps / drift

Findings from reading this PR’s branch against Behaviour + cited Requirements.
These are review notes; they do **not** change Behaviour above.

- **Drift (as-built docs):** [`docs/technical-spec/08-placement-codes-and-erf.md`](../technical-spec/08-placement-codes-and-erf.md)
  still says assigning/changing an erf is **“Deliberately not notified.”**
  This PR reverses that decision (`apps/org/lib/actions/placement.ts`
  header: notify on first assignment, every change, and removal). Tech-spec
  08 is stale relative to Behaviour §2 — update on merge, do not treat the
  old sentence as governing.
- **Drift (notify channel):** Stub Spec said “in-app” only; shipped Behaviour
  also sends immediate email to leads when the registration email path is on.
- **Gap (Requirements):** There is **no** Requirement ID for
  “notify camp leads when erf/camp_code changes.” Closest framing is §13
  camp feedback on placement (`ERF-019`–`023`), which still expects a
  camp-side approve/reject/comment loop that this port does **not** build.
- **Gap (visibility):** Camp leads are notified of placement text but still
  have no durable erf/camp_code surface under `apps/web` (tech-spec 08’s
  “org-only” note remains true for persistent UI).
