# Archive former camp members

| Field                  | Value |
| ---------------------- | ----- |
| **Category**           | Product |
| **Doc status**         | `in review` — Spec review is this PR; on merge → `implemented` |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs**    | `CDB-036` |
| **Owner / Updated**    | Repo maintainers, 2026-10-14 |
| **Depends on**         | Spec 03 / cluster-3 (`0032`) |

## Purpose

Port `feature-source` #82 (migration `0033`): archive former camp members
without destroying history needed for ops (`CDB-036`). This Spec is the
ratification contract for that port (Decision 017).

## Behaviour (WHAT ships)

### Archive and restore (`CDB-036`)

- Camp actors with `manage_members` (lead/admin backstop) MAY archive a
  current member (`canArchiveMember`) or restore a former member
  (`canRestoreMember`).
- Archiving MUST revoke camp access: every authz path that loads memberships
  MUST use `activeMembership()` (`archived_at IS NULL`). An archived row is
  treated as no membership for access, while the row and hung-off history
  (project roles held historically, logistics, questionnaire responses,
  audit) MUST be retained.
- The structural **lead** MUST NEVER be archivable. Handing the camp on is a
  lead transfer, not an archive.
- A co-lead (`admin`) MAY be archived or restored **only by the lead**.
  Co-leads MUST NOT archive each other; custom-role holders without
  `manage_members` MUST NOT archive.
- Nobody MAY archive themselves — that is Leave camp (membership delete).
- Org-rank accounts that happen to hold a camp membership MUST NOT be
  archivable as camp members via this path (`not_camp_role` / role allow-
  list: `member` | `admin` only).
- Restore MUST return the person as a plain `member` with **no** custom
  project roles restored — re-promotion is deliberate.
- Archiving MUST waive pending **org** questionnaires that reached the
  person *only because* of their role in this camp (audience re-derived
  with vs without this membership). Forms that still apply without this
  camp MUST remain.
- Former members MUST be excluded from active roster / camp-mate views;
  roster MAY offer a “Former members” filter for history under the same
  roster permission model.
- Re-invite of a former member MAY restore the archived row (race-safe)
  rather than creating a duplicate membership; a plain member invite MUST
  NOT quietly restore former co-lead privileges.

### Audit

- Archive and restore MUST write audit actions `camp.member.archive` /
  `camp.member.restore` with actor and subject.

## Surfaces

| App | Audience | Notable routes |
| --- | -------- | -------------- |
| `web` | Leads/admins / `manage_members` | Camp roster: archive/restore controls; `status=former` filter on `/camps/[slug]/roster` |

## Database

Additive `0033_archive_former_members.sql`:

- `memberships.archived_at` (null = current)
- `memberships.archived_by_user_id` (SET NULL on archiver account delete)

SQL helpers: `activeMembership()` / `formerMembership()` in `@quagga/db`.

## Out of scope (this PR)

- Shifts, onboarding presets (Specs 05–06)
- Hard-delete of historical membership rows
- Permanent POPIA erasure of the person (account sanitization is separate;
  `SEC-020` / Spec 07)
- Spreadsheet import of archived status (`CDB-029`)

## Acceptance

- Gate: `pnpm -w exec turbo run lint typecheck test build` for touched workspaces
- Unit: `packages/core` member-archive tests; `packages/db` membership-archive
  helper tests; web membership-archive-guard / roster store coverage
- E2E: no dedicated persona file named for archive on this branch — exercise
  via roster ops if present; otherwise unit gate is the primary check
- Spec status → `implemented` on merge

## Provenance

`feature-source` `128c4d1`. Stacked on cluster-3.

## Implementation gaps / drift

Findings from reading this PR’s branch against Behaviour + cited Requirements.
These are review notes; they do **not** change Behaviour above.

- **Gap (e2e):** No dedicated `e2e/specs/**/*archiv*` persona suite on this
  branch; Behaviour relies on unit/integration tests. Reviewers should not
  assume browser coverage for archive/restore races or org-questionnaire
  waiver.
- **Drift (coverage matrix):** `docs/technical-spec/requirements-coverage.md`
  may still list `CDB-036` as ❌ relative to pre-port as-built — this cluster
  is the implementation; flip coverage on merge.
- **Note:** Restore strips custom roles by design (2026-09-28). That is
  intentional Behaviour, not a Gap against `CDB-036`’s “without permanently
  deleting historical records” — history remains on the archived row; live
  privileges do not auto-return.
