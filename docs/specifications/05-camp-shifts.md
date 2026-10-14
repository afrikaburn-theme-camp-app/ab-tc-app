# Camp shifts with sign-up and swaps

| Field                  | Value |
| ---------------------- | ----- |
| **Category**           | Product |
| **Doc status**         | `in review` — Spec review is this PR; on merge → `implemented` |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs**    | `CORE-003`; in-wave `SHIFT-001`, `SHIFT-002` (bounded repeat), `SHIFT-003`–`SHIFT-005`, `SHIFT-008`, `SHIFT-010`, `SHIFT-012`, `SHIFT-013`, `SHIFT-017`–`SHIFT-022`, `SHIFT-025`–`SHIFT-026` (as shipped) |
| **Owner / Updated**    | Repo maintainers, 2026-10-14 |
| **Depends on**         | Spec 04 / cluster-4 (`0033`) |

## Purpose

Port `feature-source` #86 (migration `0034`): camp shift teams, member
sign-up, lead assign, and hand-on / open-offer swaps **without** lead
approval. This Spec is the ratification contract for that port
(Decision 017).

## Behaviour (WHAT ships)

### Management (`CORE-003`, admin SHIFT slice)

- Structural lead/admin (`canManageShifts` — backstop only; no
  `manage_shifts` custom privilege yet) MAY create, edit, and delete shifts
  and edit the starter team list (add / rename / remove; capped).
- A shift MUST have: name, calendar `shift_date`, `start_minute` (0–1439),
  `duration_minutes` (15–1440), `capacity` (1–50), optional team, optional
  required camp project role, `signup_mode` `open` | `assign`.
- Leads MAY create repeating shifts for a bounded set of days
  (`SHIFT_MAX_REPEAT`).
- Open board MUST show every build / event / strike day of the edition window
  (`SHIFT_BUILD_DAYS` / `SHIFT_STRIKE_DAYS`) — NOT filtered by a member’s
  travel plans.

### Sign-up and assign

- Eligible members MAY self-sign-up on `open` shifts (`decideSignUp`) when
  capacity remains, no clash, and required role (if any) is held via an
  accepted assignment.
- Leads MAY assign eligible members (`decideAssign` / `signup_mode` assign
  or open).
- One assignment per `(shift_id, membership_id)`.

### Hand-on and offer (no lead approval)

- The holder MAY hand a shift to a specific campmate (accepter must accept)
  or offer it as needing a replacement for any eligible member to take
  (`decideHandTo` / `decideAcceptHandover` / `decideTakeOffered`).
- Swaps and hand-ons MUST NOT require lead approval (`SHIFT-023` is **out of
  scope** for this port — deliberate product choice, 2026-09-27/28).
- The holder MUST remain on the shift until the moment it moves — a spot
  MUST NOT go silently empty.
- Hand-on and offer are mutually exclusive on a row (DB check
  `shift_assignments_one_hand_on`).

### Notifications

- In-app shift notifications MUST fire for assign / unassign / handover /
  change / cancel payloads (`notification_kind` includes `shift`). Email /
  WhatsApp / SMS reminder options (`SHIFT-027`–`029`) are out of scope.

## Surfaces

| App | Audience | Notable routes |
| --- | -------- | -------------- |
| `web` | Leads/admins | `/camps/[slug]/shifts`, `/shifts/new`, `/shifts/[id]/edit`, teams editor |
| `web` | Members | `/camps/[slug]/shifts`, `/shifts/mine`, `/shifts/[id]/hand-on` |

## Database

Additive `0034_camp_shifts.sql`:

- Enum `shift_signup_mode` (`open` \| `assign`); `notification_kind` += `shift`
- Tables `shift_teams`, `shifts`, `shift_assignments`
- `groups.shift_teams_seeded_at`
- Constraints: start minute, duration, capacity bounds; one hand-on XOR offer;
  not-to-self hand-on; unique `(shift_id, membership_id)`; unique team name
  per camp

## Out of scope (this PR)

- Onboarding presets (Spec 06); invite revoke / ID retention (Spec 07)
- `SHIFT-006` dedicated shift-lead role slot; `SHIFT-007` free-text skills
  (camp **project role** is the skill gate instead)
- `SHIFT-009` compulsory/optional flag; `SHIFT-011` Village-wide shifts
- `SHIFT-014`–`016` attendance / late cancel / no-show recording
- `SHIFT-023` administrator approval for swaps (explicitly refused by this
  port)
- `SHIFT-024`, `SHIFT-027`–`029` email / WhatsApp / SMS reminders
- Custom-role `manage_shifts` privilege (callout in `shifts.ts` — Ryan’s
  call to add later)
- Cross-camp / Village shift boards

## Acceptance

- Gate: `pnpm -w exec turbo run lint typecheck test build` for touched workspaces
- E2E (when run): `e2e/specs/camp-lead/shifts.spec.ts`
- Unit: `packages/core` shifts tests + web shifts-store coverage
- Spec status → `implemented` on merge

## Provenance

`feature-source` `e4a12ad`. Stacked on cluster-4.

## Implementation gaps / drift

Findings from reading this PR’s branch against Behaviour + cited Requirements.
These are review notes; they do **not** change Behaviour above.

- **Drift (Requirements):** §6 closing prose and `SHIFT-023` imply swaps may
  need administrator approval and that replacements must meet role/skill
  conditions. This port **implements** role/skill gates and **rejects** lead
  approval for swaps by design. Treat `SHIFT-023` as Out of scope (above),
  not as a silent Gap to fix in this PR.
- **Gap (Requirements breadth):** Attendance, no-shows, Village open,
  compulsory flag, and non-in-app reminders (`SHIFT-014`–`016`, `011`, `009`,
  `027`–`029`) are unimplemented — listed Out of scope, not accidental
  omissions.
- **Gap (permissions):** Only structural lead/admin manage shifts; there is
  no `manage_shifts` custom-role grant yet (`packages/core/src/shifts.ts`
  header). Camps that want a “shift captain” custom role cannot grant manage
  without promoting to admin.
- **Drift (coverage matrix):** `requirements-coverage.md` §6 may still mark
  all `SHIFT-*` as ❌ from pre-port as-built — flip for the in-wave IDs on
  merge.
