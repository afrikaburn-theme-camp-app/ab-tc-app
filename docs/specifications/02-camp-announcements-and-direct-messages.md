# Camp announcements and direct messages

| Field                  | Value |
| ---------------------- | ----- |
| **Category**           | Product |
| **Doc status**         | `in review` — shipped with the feature work in this PR; `approved` once a reviewer accepts it as a Spec, `implemented` when the feature work merges |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs**    | `COMM-008`, `COMM-012`, `COMM-018` |
| **Owner / Updated**    | Repo maintainers, 2026-10-14 |
| **Depends on**         | Spec 01 / PR cluster-1 (`0030`) |

## Purpose

Port the already-built cluster from `feature-source` PR #74 into this repo
(migration `0031`). This Spec is the ratification contract for that port
(Decision 017). Reviewers approve Spec and code together in one PR.

Camp announcements reuse the org bulletin spine with a camp `group_id`.
Direct messages are 1:1 only, with blocks, disappearing-message timers, and an
org safety queue that sees report *copies* — never live conversations.

## Behaviour (WHAT ships)

### 1. Camp announcements (`COMM-012`)

- Camps MAY draft, publish, schedule (when dispatch is enabled), and pin
  announcements to member audiences (`everyone` or by project role).
- Sending MUST be gated by `canSendCampAnnouncement`: structural lead/admin
  backstop, otherwise `post_announcements` with audience-role scope; must-ack
  sends require `mayRequireAck` on that scope. Audience MUST be a project
  audience for *this* camp; foreign role ids fail closed.
- Pinning authority MUST follow posting authority for that audience
  (`canPinCampAnnouncement`).
- Must-acknowledge announcements (`presentation = acknowledge`) MUST gate the
  recipient until they acknowledge on their own notification row
  (`notifications.acknowledged_at`).
- Published announcements MUST be immutable (no edit of content after
  `published_at`). Delivery fan-out MUST be claimed via compare-and-set on
  `dispatched_at` so concurrent dispatch jobs do not double-claim.
- Org bulletins remain org-scoped (`group_id` null); camp rows MUST require a
  project audience whose `groupId` matches `bulletins.group_id` (DB check
  `bulletins_camp_audience_matches_group`).
- Recipients MUST be live memberships of that camp only; sanitized accounts
  and the author MUST NOT be reached. Pending invitees (no membership) MUST
  NOT receive announcements.
- A member without a delivery notification for a bulletin MUST NOT read it
  (delivery row is the read permission).

### 2. Direct messages (`COMM-008`, `COMM-018`)

- A burner MAY start a 1:1 conversation only when `canStartConversation`
  passes: target contactability (`nobody` | `camp_mates` | `anyone` via
  `canContact`), confirmed bio, neither party sanitized, and no block either
  way (`COMM-018`).
- Blocks MUST refuse starting and sending in either direction. Contactability
  is NOT re-checked for sends into an existing conversation — participants
  who want to stop messaging MUST block.
- Inbox list MUST show sender identity and unread count only — no body
  preview.
- Conversations MAY set a disappearing timer (`off` | `24h` | `7d` | `90d`);
  users MAY set `users.default_message_timer`. Unknown timer values MUST
  decode to `off`. Expiry sweep MUST hard-delete messages past `expires_at`.
- Only conversation participants MAY read the thread. Org staff, System
  managers, and camp leads MUST be refused like strangers for live
  conversations.
- Participants MAY report a bounded selection of messages (max 20). Org
  safety MAY review *copies* in `message_report_items` when
  `canReviewMessageReports` (personal-information / registrations tier —
  same class as medical). Resolve requires update rights in that domain.
  Report copies expire after the retention window; org MUST NOT gain live
  conversation access via reports.
- DM start/send/report MUST be rate-limited per account (`DM_RATE_LIMITS`).

## Surfaces

| App | Audience | Notable routes |
| --- | -------- | -------------- |
| `web` | Camp leads / members with `post_announcements`; all members as recipients | `/camps/[slug]/announcements`, `/camps/[slug]/announcements/new`, `/camps/[slug]/announcements/[id]`, `/bulletins/[id]` (recipient read + must-ack), `/api/announcements/dispatch` |
| `web` | Contactable burners | `/messages`, `/messages/[id]`, `/api/messages/expiry-sweep`; `/profile` (contactable + default timer); Message/block CTAs on `/burners/[id]` |
| `org` | Staff with personal-information registrations capability | `/safety`, `/safety/[id]`; org bulletin composer pin/order (`/bulletins`, …) — camp rows refused |

## Database

Additive migration `0031_announcements_and_direct_messages`:

- Enums: `bulletin_presentation` (`feed` \| `acknowledge`), `message_kind`,
  `message_report_status`, `message_timer`
- Tables: `conversations`, `conversation_participants`, `messages`,
  `user_blocks`, `message_reports`, `message_report_items`
- Bulletin columns: `group_id`, `presentation`, `meeting_url`,
  `pin_on_publish`, `pinned_at`, `pinned_by_user_id`, `send_at`,
  `dispatched_at`; check `bulletins_camp_audience_matches_group`
- `notifications.acknowledged_at`; `users.default_message_timer`
- Unique `conversations.pair_key` (sorted user-id pair)

## Out of scope (this PR)

- Roster logistics, member archive, shifts, onboarding presets (Specs 03–06)
- Directory photo tiles / Village cross-camp discovery (`COMM-001`–`007`,
  `COMM-020`)
- WhatsApp / Meet / Zoom / scheduling meetings (`COMM-009`–`011`)
- Shift / function / friend group formation (`COMM-013`–`016`)
- Email digest *bodies* for DMs (notification seam only)
- Group chats (1:1 only in this port)

## Acceptance

- Gate: `pnpm -w exec turbo run lint typecheck test build` for touched workspaces
- E2E (when run): `e2e/specs/camp-member/camp-announcements.spec.ts`;
  `e2e/specs/camp-member/direct-messaging.spec.ts`; org bulletin targeting
  specs remain green for org-scoped bulletins
- Spec status → `approved` when a reviewer accepts it as a Spec, `implemented` once the feature work merges; as-built notes land in
  `docs/technical-spec/11-bulletins-and-notifications.md` (and related)

## Provenance

`feature-source` commit `46f0ed2`. Stacked on cluster-1 branch.

## Implementation gaps / drift

Findings from reading this PR’s branch against Behaviour + cited Requirements.
These are review notes; they do **not** change Behaviour above.

- **Drift (docs):** Earlier stub Spec claimed a unique fan-out index on
  notification delivery. Migration `0031` and `notifications` in
  `packages/db/src/schema.ts` have **no** unique `(user_id, bulletin_id)`
  constraint — idempotency relies on `dispatched_at` compare-and-set in
  `apps/web/lib/announcements-store.ts`, not a DB uniqueness guard on
  delivery rows.
- **Gap (Requirements breadth):** `COMM-008` / `COMM-012` / `COMM-018` are
  the ratified slice; the rest of §4a `COMM-*` remains out of scope (see
  above). `docs/technical-spec/requirements-coverage.md` may still mark
  messaging coverage as incomplete relative to the full directory vision —
  that is intentional for this port, not a code defect in this PR.
- **Note:** Org safety queue is under `/safety` and uses the medical /
  personal-information registrations capability (`packages/core/src/messaging.ts`
  `canReviewMessageReports`) — confirm reviewers treat that as the correct
  audience for DM report copies.
- **Gap (e2e breadth):** Persona coverage is thin —
  `camp-announcements.spec.ts` (must-ack role gate) and
  `direct-messaging.spec.ts` (contactable chat + inbox preview). Blocks,
  reports, `/safety`, schedule/dispatch, and pin paths rely on unit tests.
