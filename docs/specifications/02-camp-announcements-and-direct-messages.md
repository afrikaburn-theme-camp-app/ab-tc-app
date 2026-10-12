# Camp announcements and direct messages

| Field                  | Value |
| ---------------------- | ----- |
| **Category**           | Product |
| **Doc status**         | `in review` — Spec review is this PR; on merge → `implemented` |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs**    | Partial — camp communications / `COMM-*`; extends bulletins spine; safety review path |
| **Owner / Updated**    | Repo maintainers, 2026-10-12 |
| **Depends on**         | Spec 01 / PR cluster-1 (`0030`) |

## Purpose

Port `feature-source` PR #74 (migration `0031`): camp announcements on the
bulletin spine, and 1:1 direct messages with blocks, timers, and an org
safety queue.

## Behaviour

### Camp announcements

- Camps MAY draft, publish, schedule (when dispatch enabled), and pin
  announcements to member audiences (including role-targeted).
- `post_announcements` permission (plus lead/admin backstop) gates sending.
- Must-acknowledge announcements MUST gate the member until acknowledged.
- Published announcements are immutable; delivery fan-out is idempotent.
- Org bulletins remain org-scoped (`group_id` null); camp rows require a
  project audience for that group.

### Direct messages

- Contactable burners MAY start 1:1 conversations; blocks refuse either way.
- Inbox shows sender + unread count only (no body preview).
- Per-conversation timers (`off|24h|7d|90d`); expiry sweep hard-deletes.
- Participants MAY report selected messages; org safety queue reviews copies
  (medical/personal-information tier); no live conversation access from org.

## Surfaces

| App | Routes |
| --- | ------ |
| web | `/camps/[slug]/announcements`, `/messages`, `/api/announcements/dispatch`, `/api/messages/expiry-sweep` |
| org | `/safety`, bulletin composer pin/order |

## Database

Additive `0031_announcements_and_direct_messages.sql`: bulletin presentation /
scheduling / pin columns; conversations, messages, blocks, reports; notification
ack + unique fan-out index; `users.default_message_timer`.

## Out of scope

Roster logistics, archive, shifts, onboarding presets; email digest bodies for
DMs (seam only).

## Provenance

`feature-source` `46f0ed2`. Stacked on cluster-1 branch.
