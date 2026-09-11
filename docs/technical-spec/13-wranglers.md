# Wranglers

| Field                  | Value                                                                          |
| ---------------------- | ------------------------------------------------------------------------------ |
| **Category**           | Product                                                                        |
| **Doc status**         | Active                                                                         |
| **Normative language** | Descriptive only                                                               |
| **Requirement IDs**    | Partial — `SEC-012` (App Spec §19; the wrangler board itself extends the spec) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                   |

Each registered camp is assigned an AfrikaBurn **wrangler** — an org staff
member who shepherds it through registration and beyond. Shipped; previously
undocumented outside scattered mentions in other specs.

## Implements (App Specification)

| App Spec §                   | IDs                           | Status | Notes                                                                                         |
| ---------------------------- | ----------------------------- | ------ | --------------------------------------------------------------------------------------------- |
| §19 Permissions and security | SEC-012 (theme-camp wrangler) | ✅     | The role itself is spec'd; the assignment board and workflow around it extend beyond the spec |

## How it is built

- `wrangler_assignments` — one per camp per edition, by design (a wrangler
  is edition-scoped, not a permanent relationship).
- `apps/org/app/(console)/wranglers/page.tsx` — the board: assign a
  wrangler (an org role holder) to a registered camp, with per-camp
  progress visible (registration status, milestones as they get defined).
- `packages/core/src/notifications.ts` (`wranglerAssignedNotification`) —
  the camp is notified when a wrangler is assigned; see
  [`11-bulletins-and-notifications.md`](11-bulletins-and-notifications.md).
- Authorised the same way as every other org surface —
  `packages/core/src/org-permissions.ts` — see
  [`16-org-permissions-and-system-panel.md`](16-org-permissions-and-system-panel.md).

## Invariants and tests

`apps/org/lib/__tests__/wrangler-actions.test.ts`.
