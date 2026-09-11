# Questionnaire engine

| Field                  | Value                                                                                                                                                                              |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Category**           | Product                                                                                                                                                                            |
| **Doc status**         | Active                                                                                                                                                                             |
| **Normative language** | Descriptive only — engineering-invented mechanism; the App Spec has no dedicated "questionnaire" section                                                                           |
| **Requirement IDs**    | Partial — `ONBOARD-*`, `REG-*`, `SEC-*`, `COMM-012` (this is repo-extends-spec: the mechanism itself is not named by any App Spec section, though it implements pieces of several) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                                                                                                                       |

A general-purpose questionnaire builder, audience targeting and
notification-gate engine. It is the substrate the Burner Bio, camp
onboarding, the January registration form, and org bulletins-adjacent
required-actions all run on.

## Implements (App Specification)

| App Spec §                | IDs                                                                                                                                                                                                 | Status | Notes                                                                                                                                                                                                           |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| §3, §14                   | See [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md) and [`06-registration-and-review.md`](06-registration-and-review.md) for how this engine implements ONBOARD-* and REG-* pieces | —      | This doc covers the mechanism itself                                                                                                                                                                            |
| §4a Camper communications | COMM-012 (group communications)                                                                                                                                                                     | 🚧     | Org → audience only via this engine's activation mechanism; no camp-level broadcast exists here (see [`11-bulletins-and-notifications.md`](11-bulletins-and-notifications.md) for the separate bulletin system) |

## Authoring levels and audiences

Three authoring levels:

1. **Org level — internal**: audience is org members; appears only inside
   the organiser console (a pending-questionnaire gate there, never in the
   participant app).
2. **Org level — outbound**: an audience selector resolving one or more of
   `all_current_burners`, `camp_leads`, `registered_camp_leads`,
   `mv_leads`, `mv_grant_requesters`, `art_leads`, `art_grant_requesters`,
   or `officer:<key>` (every holder of a given officer role across
   registered camps — see
   [`05-camp-roles-and-officers.md`](05-camp-roles-and-officers.md)).
3. **Project level**: authored by a project's lead/admin (or a member
   holding `manage_questionnaires`), targeting the project's own custom
   roles or "everyone."

## Engine mechanics

- A **definition** is a versioned JSON of fields (`questionnaire_definitions`).
- An **activation** = definition × edition × audience spec × options
  (`blocking` bool, `due_at` nullable). Activating resolves the audience at
  send time into `required_actions` rows per targeted user.
- **Notification gates**: on activation, each targeted user gets a
  required-action; if `blocking`, the app routes them to the fill page
  before anything else — the only reachable pages while gated are the fill
  page and sign-out. Non-blocking activations surface as a dashboard banner
  / pending item. An email is also sent via Resend (console-logged when
  unset).
- Submitting responses (`questionnaire_responses`, JSONB by field id) flips
  the required-action to completed.
- **Blocking status is explicit everywhere** a questionnaire surface
  appears: "Required — blocks the app until done" (destructive/warning
  treatment) vs. "Optional" (muted).
- **Completion tracking**: an author-side per-activation list (sent /
  completed / per-user status).
- **Audience resolution is a pure, tested core function**
  (`resolveAudience(spec, editionId)`), returning user ids.

## Surfaces

- **Org console** `/questionnaires`: list, builder, activation flow
  (audience picker with a live resolved-count preview, blocking toggle, due
  date), results view.
- **Participant app** `/camps/[slug]/questionnaires` (lead/admin, or a
  member holding `manage_questionnaires`): the same builder scoped to the
  project.
- **Participant app, member side**: the blocking gate page, or a
  non-blocking "Pending questionnaires" dashboard card.

## Guardrails

- Responses are visible only to the authoring level that sent them — org
  sends to the org console, project sends to that project's leads/admins;
  never cross-project.
- The fewer-forms principle applies to the builder itself: authoring UI
  warns "every question you add is a question someone in the desert has to
  answer."

## Builder v2 — content and question types

Target parity with common form builders, adapted to this platform's
constraints:

- **Content blocks**: section/page break, standalone info text, image block.
  Video is deliberately excluded (no-connectivity culture and file weight).
- **Question types**: short answer, paragraph, single/multi-select
  (including dropdown rendering and "Other…" free text), yes/no, linear
  scale, rating, multiple-choice/checkbox grids, date, time, number, file
  upload.
- **Logic**: per-question required flag, response validation (length,
  regex, numeric range, email/URL presets), min/max selection counts,
  branching (go-to-section based on a radio/dropdown answer).
- **Respondent UX**: multi-page navigation with a progress bar, per-page
  validation, draft autosave, author-set confirmation message, an
  edit-after-submit toggle, an author preview mode.
- **Author features**: duplicate as template, manual close/reopen, a
  response-summary view with per-question charts, CSV export of responses.
- **Explicitly excluded** (the platform makes them irrelevant, or a product
  decision cut them): email-collection lists (accounts + gates + Resend
  cover it), quiz mode/points/answer keys, collaborator sharing (org/camp
  roles cover it), fixed themes, prefilled-link generation, add-ons/scripts,
  embedding.

## Invariants and tests

`packages/core/src/__tests__/{questionnaire-engine,questionnaire-activation,questionnaire-authz,questionnaire-snapshot,questionnaire-grid}.test.ts`.
