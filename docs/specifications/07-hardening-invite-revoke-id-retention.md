# Hardening: invite revoke reliability and ID-retention sweep

| Field                  | Value |
| ---------------------- | ----- |
| **Category**           | Engineering / fix |
| **Doc status**         | `in review` — Spec review is this PR; on merge → `implemented` |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs**    | `SEC-020` (ID retention); invite lifecycle (no dedicated Requirement ID — hardens `CDB-027` invite path) |
| **Owner / Updated**    | Repo maintainers, 2026-10-14 |
| **Depends on**         | Spec 06 / cluster-6 (`0035`) |

## Purpose

Port remaining `feature-source` fixes that are **not** new product features:

- `#29` — wire the ID-retention purge caller + placement-panel resync coverage
- `#94` — revoke invites reliably (hydration bug) + e2e 360 role-spec fixes

Canvas UI fix `#80` already lands in Spec 03. This Spec is the ratification
contract for the hardening cluster (Decision 017).

## Behaviour (WHAT ships)

### 1. Invite revoke reliability (invite lifecycle / `CDB-027`)

- Camp leads MUST be able to revoke an unused invite from the camp invites
  UI (`revokeInvite` scoped to the group).
- The invites list MUST NOT read `window.location.origin` during render in a
  way that disagrees between server HTML and the first client paint. A
  hydration mismatch that throws away the subtree MUST NOT swallow revoke
  clicks (fix: `useOrigin` via `useSyncExternalStore` in
  `apps/web/components/camp-invites.tsx`).
- After a successful revoke, the UI MUST remove the invite from the list and
  refresh; failures MUST surface an error toast.

### 2. ID-retention sweep (`SEC-020`)

- The pure rule in `@quagga/core` `id-retention` (`identifyPurgeableIdBios` /
  `buildIdPurgePatch`, grace `ID_RETENTION_GRACE_DAYS`) MUST have a scheduled
  caller that applies it.
- Route `GET|POST /api/account/id-retention-sweep` MUST:
  - Require bearer auth (`ACCOUNT_SWEEP_SECRET` or `CRON_SECRET`), compared
    timing-safe; disabled when secret unset
  - Leave unauthenticated GET as status-only (erase nothing)
  - Run `sweepExpiredIdDocuments` (bounded batch, idempotent)
  - NEVER load ID ciphertext into memory to decide presence — presence is
    `IS NOT NULL` only
  - Write a run-level audit marker `bio.id_retention_purge` (not per-burner
    “we erased your ID” rows)
  - Return non-success when any purge in the batch failed
- Vercel cron MUST schedule this path (daily) in `apps/web/vercel.json`.

### 3. Placement panel resync (regression guard)

- After a successful placement save, the org placement panel MUST adopt the
  **normalized stored** camp code / erf values (not the raw typed draft), so
  the form is not left dirty against a no-op. Guarded by
  `apps/org/lib/__tests__/placement-panel-resync.test.ts` (+ e2e registration
  review coverage).

### 4. E2E / viewport hygiene

- Persona specs touched in this cluster (god access-expiry, camp-lead roles /
  officers) MUST remain green at 360 width where this PR adjusted them.

## Surfaces

| App | Audience | Notable routes / files |
| --- | -------- | ---------------------- |
| `web` | Camp leads | Camp invites revoke UI (`camp-invites.tsx`) |
| `web` | Cron / operator | `/api/account/id-retention-sweep` |
| `org` | Staff | Placement panel resync after assign |

## Database

No new migration. Uses existing bio ID columns and invite rows; purge nulls
ciphertext per `buildIdPurgePatch`.

## Out of scope (this PR)

- New product features (those are Specs 01–06)
- Changing the retention grace policy itself (rule already in core)
- Per-burner audit rows that re-identify whose ID was purged
- Rewriting tech-spec drift register entries (call out only — see gaps)

## Acceptance

- Gate: `pnpm -w exec turbo run lint typecheck test build` for touched workspaces
- Unit: `apps/web/lib/__tests__/id-retention-sweep.test.ts`;
  `apps/org/lib/__tests__/placement-panel-resync.test.ts`
- E2E (when run): invite revoke still works under hydration; god access-expiry
  / camp-lead roles·officers specs adjusted in this PR stay green
- Spec status → `implemented` on merge; tech-spec SEC-020 notes should flip
  from “no scheduled caller” to “caller wired”

## Provenance

`feature-source` `51b65e2`, `8566586`. Stacked on cluster-6.

## Implementation gaps / drift

Findings from reading this PR’s branch against Behaviour + cited Requirements.
These are review notes; they do **not** change Behaviour above.

- **Resolved (as-built docs):** [`docs/technical-spec/02-accounts-and-account-security.md`](../technical-spec/02-accounts-and-account-security.md)
  and [`23-security-threat-model.md`](../technical-spec/23-security-threat-model.md)
  (B7) described the ID purge as a pure rule with no caller; both are updated
  in this PR to say it is wired and scheduled (unverified in production until
  the first run).
- **Resolved (cron tip):** an earlier version of this PR's
  `apps/web/vercel.json` dropped the `/api/messages/expiry-sweep` entry that
  Spec 02 relies on (the whole file was copied from before that entry
  existed). It is restored; both sweeps run daily on Vercel Cron, which the
  project's Hobby plan supports (daily schedules only). `CRON_SECRET` must be
  set on the web app for the cron to authenticate.
- **Gap (Requirements):** Invite revoke has no `PREFIX-NNN` ID; Behaviour is
  engineering hardening of the invite path (`CDB-027`), not a new
  Requirements statement.
- **Note:** Sharing `ACCOUNT_SWEEP_SECRET` with the account-deletion sweeper
  is intentional (same operator blast radius) — not a Gap.
