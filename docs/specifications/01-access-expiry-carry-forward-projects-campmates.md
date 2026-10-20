# Access expiry, carry-forward v2, creative-project parity, campmates

| Field                  | Value |
| ---------------------- | ----- |
| **Category**           | Product |
| **Doc status**         | `in review` — shipped with the feature work in this PR; `approved` once a reviewer accepts it as a Spec, `implemented` when the feature work merges |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs**    | `SEC-019`; `PREVYR-001`, `PREVYR-009`, `PREVYR-010`, `PREVYR-014`; `CREATIVE-007`, `CREATIVE-014`, `CREATIVE-017`, `CREATIVE-019`; `CORE-002`, `CDB-007` |
| **Owner / Updated**    | Repo maintainers, 2026-10-12 |

## Purpose

Port the already-built cluster from `feature-source` PR #73 into this repo.
This Spec is the ratification contract for that port (Decision 017). Reviewers
approve Spec and code together in one PR.

## Behaviour (WHAT ships)

### 1. Org access expiry (`SEC-019`)

- Org role assignments MAY carry an optional inclusive last day of access
  (`expires_at`, end of day SAST).
- After that boundary, the assignment MUST grant nothing on every authz path
  (core resolvers, org session, medical path). Unparseable dates fail closed.
  `god` is unchecked by expiry.
- The org accounts UI MUST show expired roles as expired and MUST NOT count
  them toward live capabilities. Setting a *new* past expiry is refused;
  leaving an already-expired assignment unchanged is allowed.

### 2. Carry-forward v2 + history (`PREVYR-*`)

- Camp leads/admins MUST be able to view past registrations for their camp
  (`/registration/history`), including years that are not the most recent
  prior.
- They MAY choose any strictly earlier same-camp edition as the carry-forward
  source, whatever its status (server re-validates same camp + earlier year;
  a never-submitted draft is a valid source — deliberate, so a camp that
  started but never submitted can still reuse its answers).
- Year-on-year comparison (`/registration/changes` and org review) MUST use
  the carried source when set, otherwise the most recent earlier submitted
  edition for that camp — never another camp's row.
- Rows that hold unsent edits (draft / changes_requested after a prior
  submit) MUST NOT be presented as "what was submitted."

### 3. Creative-project parity (`CREATIVE-*`)

- Artwork and mutant-vehicle registrations MUST support Work Access Pass
  requests, safety documents with expiry, and previous-edition answer
  carry-forward (including capped, de-duplicated safety-doc merge).
- Questionnaire list/builder/results MUST mount on `/artworks` and
  `/vehicles` as well as `/camps`, kind-gated (wrong kind → redirect/404).
- Org review MUST surface safety documents only to actors with the
  personal-information registrations capability. WAP counts are shown to any
  org actor who can open the review page (they are counts, not personal
  information).

### 4. Campmates + avatar (`CORE-002`, `CDB-007`)

- Privacy flags gain a third audience level: `camp_mates` (legacy
  true/false remain public/private).
- Confirmed bios MAY opt into the camp people list and set contactability
  (`nobody` | `camp_mates` | `anyone`). Unconfirmed (in-progress onboarding)
  bios MUST NOT appear to camp-mates.
- Profile photograph upload is private Blob storage, raster-only, size-capped,
  served only via `/api/avatar/[userId]` after `canViewAvatar`. Cross-origin
  mutations are refused. Account sanitization deletes the blob.

## Surfaces

| App | Audience | Notable routes |
| --- | -------- | -------------- |
| `org` | Staff | Accounts expiry UI; registration review comparison; project safety docs |
| `web` | Camp leads, members, project leads | `/camps/.../registration/{history,changes}`, `/camps/.../people`, `/burners/[id]`, `/artworks|vehicles/.../questionnaires`, avatar APIs |

## Database

Additive migration `0030_epics_expiry_safety_docs_campmates`:
`contactability` enum; `registration_safety_documents`;
`org_role_assignments.expires_at`; `users.avatar_key`;
`burner_bios.contactable`, `burner_bios.listed_in_camp_people`.

## Out of scope (this PR)

- Camp announcements / DMs (cluster 2 / migration `0031`)
- Roster logistics, member archive, shifts, camp onboarding presets
- ID-retention sweep fix from source `#29` (separate hardening item)
- Changing Requirements Decision Records that remain `proposed`

## Acceptance

- Gate: `pnpm -w exec turbo run lint typecheck test build` for touched workspaces
- E2E (when run): god role access-expiry; registration history; campmate
  profiles / three-level privacy; creative-project WAP / safety / questionnaires
- Spec status → `approved` when a reviewer accepts it as a Spec, `implemented` once the feature work merges; as-built notes land in
  `docs/technical-spec/` for the affected feature docs

## Provenance

Reference implementation: `feature-source` commit `4eb47b7`
(`feat(core,db,web,org): access expiry, carry-forward, projects, campmates (#73)`),
ported onto this repo's IA without adopting the source's flat `docs/` layout.

## Implementation gaps / drift

Findings from reading this PR’s branch against Behaviour + cited Requirements.
These are review notes; they do **not** change Behaviour above.

- **Resolved in Behaviour (org review WAP):** an earlier draft of §3 required
  WAP counts to be capability-gated like safety documents. Safety docs are gated
  (`getReviewSafetyDocuments` → `canReadPersonalInformationIn(..., "registrations")`
  in `apps/org/lib/project-registration.ts`). WAP counts
  (`registration.s4WorkAccessPasses` / `wapField` in
  `apps/org/app/(console)/registrations/[id]/page.tsx` and
  `apps/org/lib/project-review.ts`) are **not** capability-gated — any org
  actor who can open the review page sees them. Behaviour §3 now says so;
  a reviewer who wants WAP counts gated must change the code and this line.
- **Resolved in Behaviour (carry-forward source status):** an earlier draft of
  §2 said **submitted** editions only. Code lists prior rows
  via `listPriorRegistrations` and `findCarryForwardSource`
  (`apps/web/lib/registration-store.ts`) accepts **any** prior status
  (including never-submitted drafts). Server re-check
  `isValidCarryForwardSource` (`packages/core/src/registration-carry-forward.ts`)
  only requires same camp + earlier year — no `submittedAt`.
- **Aligned (for reviewers):** Inclusive last-day UI → exclusive `expires_at`
  in `isOrgRoleAssignmentLive`; registration history / YoY comparison;
  creative-project questionnaires kind-gating; campmates privacy and avatar
  paths match Behaviour §§1–4 aside from the two drifts above.
