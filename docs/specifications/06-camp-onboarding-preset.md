# Camp onboarding preset with steps and totals

| Field                  | Value |
| ---------------------- | ----- |
| **Category**           | Product |
| **Doc status**         | `in review` — shipped with the feature work in this PR; `approved` once a reviewer accepts it as a Spec, `implemented` when the feature work merges |
| **Normative language** | RFC 2119 / RFC 8174 applies |
| **Requirement IDs**    | `ONBOARD-019`, `ONBOARD-020`; also touches `ONBOARD-015`–`018`, `ONBOARD-022` (carry-forward draft), `ONBOARD-023`–`025` (new campers / returning campers / camp leads — the tenure audience and the lead's totals); theme-camp only |
| **Owner / Updated**    | Repo maintainers, 2026-10-14 |
| **Depends on**         | Spec 05 / cluster-5 (`0034`) |

## Purpose

Port `feature-source` #87 (migration `0035`): camp-authored **onboarding
preset** on the existing questionnaire spine — not a second onboarding
product. This Spec is the ratification contract for that port
(Decision 017).

## Behaviour (WHAT ships)

### Preset on questionnaires (`ONBOARD-019`)

- Theme-camp leads/admins (or `manage_questionnaires` within scope) MAY
  create a draft from `buildOnboardingPreset()` (`preset: "onboarding"`) or
  a blank questionnaire. Artwork / mutant-vehicle / org MUST NOT author this
  preset (`ONBOARDING_GROUP_KINDS` = `theme_camp` only).
- An onboarding definition MAY contain only `info_block`, `video_link`, and
  `acknowledgement` blocks (bounded by `ONBOARDING_LIMITS`). Free-form answer
  collection belongs on an ordinary questionnaire.
- Default audience MUST be everyone in the camp (leads and co-leads
  included); the lead can switch any of them off. Blocking
  choice follows the same `may_block` / `canAuthorOnboarding` rules as other
  camp questionnaires.
- Sending rides the existing activation → `required_actions` → responses
  path. A blocking onboarding MUST gate the **app** until done (copy MUST
  NOT claim it blocks registration).
- Members MUST walk sections one step at a time (a definition MUST NOT use
  branching or shuffled sections). The preset places acknowledgements in the
  last section, but `validateOnboardingDefinition` does not enforce that
  order for edited definitions.
- Closed (recalled) sends MUST be refused for **all** camp questionnaires,
  not only onboarding (`questionnaire-store.ts`); the org status board no
  longer lists camp questionnaires; members are told leads can see their
  progress.

### Progress and completion totals (`ONBOARD-020`)

- Per activation+user, `onboarding_progress` MUST track `opened_at` and
  acknowledged block ids (`acknowledged` jsonb). Unique
  `(activation_id, user_id)`.
- Leads MUST see completion totals first (`tallyOnboardingCompletion`);
  names only on demand.
- Tenure classification (`classifyCampTenure`) is relative to **this camp**,
  never to AfrikaBurn as a whole.

### Carry-forward (`ONBOARD-022`)

- A camp MAY have only one onboarding per edition, enforced on carry-forward
  only (not when starting from the preset).
- Camps MAY carry the previous edition’s onboarding forward as a **draft**
  for editing — returning campers SHOULD NOT be forced to repeat unchanged
  material unnecessarily (Requirements §3 closing prose); exact send
  audience for returning vs new is as implemented in the store.

### Money / registration boundary

- Preset content MUST NOT ask for or describe payment (`ONBOARD-013` out).
- Nothing here is read by the registration flow — onboarding is camp↔member
  only.

## Surfaces

| App | Audience | Notable routes |
| --- | -------- | -------------- |
| `web` | Camp leads / `manage_questionnaires` | `/camps/[slug]/questionnaires` start chooser (blank vs preset); onboarding builder; onboarding-actions |
| `web` | Members | `/questionnaires/[activationId]` runner (the member page) |
| `web` | Camp leads / `manage_questionnaires` | `/camps/[slug]/questionnaires/onboarding/[activationId]` — the lead-only draft builder, not a member page |

## Database

Additive `0035_onboarding_progress.sql`:

- Table `onboarding_progress`: `activation_id`, `user_id`, `opened_at`,
  `acknowledged` (jsonb), `updated_at`
- Unique `(activation_id, user_id)`

Questionnaire definition `preset: "onboarding"` lives in existing
questionnaire JSON — no new definition table.

## Out of scope (this PR)

- Hardening invite revoke / ID retention (Spec 07)
- Full content checklist `ONBOARD-001`–`014` as mandatory sections (preset
  supplies editable starters; camps MAY delete/edit)
- Payment / ticket / WAP onboarding sections (`ONBOARD-013` and similar)
- Village / artwork / mutant-vehicle onboarding presets
- Supplier portal onboarding (separate surface)
- Platform burner bio onboarding gate (`/onboarding` bio flow) — already
  shipped; not this cluster

## Acceptance

- Gate: `pnpm -w exec turbo run lint typecheck test build` for touched workspaces
- E2E (when run): `e2e/specs/camp-lead/onboarding.spec.ts`
- Unit: `packages/core` camp-onboarding tests; web onboarding-store /
  onboarding-actions tests
- Spec status → `approved` when a reviewer accepts it as a Spec, `implemented` once the feature work merges

## Provenance

`feature-source` `9c97c3c`. Stacked on cluster-5.

## Implementation gaps / drift

Findings from reading this PR’s branch against Behaviour + cited Requirements.
These are review notes; they do **not** change Behaviour above.

- **Drift (docs framing):** [`docs/technical-spec/03-burner-bio-and-profiles.md`](../technical-spec/03-burner-bio-and-profiles.md)
  already marks `ONBOARD-019`/`020` ✅ via **generic** camp-lead blocking
  questionnaires. This cluster adds a **specialized preset + progress
  table** on the same spine — not a second product. Coverage notes should
  distinguish “any blocking questionnaire” vs “onboarding preset with
  steps/totals” after merge.
- **Note (not a Gap):** Ordinary camp questionnaires still exist alongside
  the preset. Camps that need dietary/shift answers MUST use a normal
  questionnaire — Behaviour forbids answer blocks on the onboarding preset
  by design (`ONBOARDING_BLOCK_KINDS`).
- **Gap (Requirements breadth):** Video *upload* (`ONBOARD-016` as media
  host) is a link card only; document upload (`ONBOARD-017`) is not in the
  preset block set. Document those as Out of scope rather than incomplete
  preset bugs.
