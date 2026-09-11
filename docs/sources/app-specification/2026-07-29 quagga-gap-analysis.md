# Gap Analysis — Quagga Portal Specification vs. Implementation

**Date:** 29 July 2026
**Specification:** `ab-app-docs/app-specification.md` (source-of-truth master doc, exported 29 Jul 2026)
**Implementation:** `afrikaburn-contributors-app/` (Turborepo: `apps/web`, `apps/org`, `apps/suppliers`; shared `@quagga/*` packages)
**Method:** Static review of the codebase — database schema (`packages/db/src/schema.ts`, 43 tables, migrations through 0022), domain logic (`packages/core/src`), app routes, README, and `docs/roadmap.md`. No code was executed.

---

## Executive summary

The specification describes a broad **camp-management platform** (onboarding, camper database, shifts, budgets, payments, WAPs, tickets, layout/placement CAD tooling, villages). The implementation is a narrower but deep **registration-and-review platform** (identity, camps, the six-section registration wizard, org review loop, questionnaires, suppliers, notifications, security).

Of the spec's 11 "Core Modules Required for Every Camp", roughly **3 are built or substantially built, 3 are partial, and 5 are missing** — and crucially, several of the missing ones are **deliberate, documented descopes**, not oversights. The team's `docs/roadmap.md` records explicit decisions that directly contradict the spec:

- **Ticketing is "out, permanently"** — stays entirely with Quicket (spec §10 requires ticket allocation management).
- **The platform never holds or processes money** — no payment gateway, no camp dues collection (spec §8 requires a payment gateway).
- **Placement/layout tooling is explicitly deferred** — no structured geo data exists to build against (spec §11–13 require a full scaled layout CAD tool).
- **An admin-managed camper identity database "should likely never be built"** — replaced by a self-serve Burner Bio model (spec §5 requires an admin-managed camper database with ID numbers).

The two documents therefore disagree not only on progress but on **product philosophy**: the spec is admin-centric ("give camp admins tools to manage people"), while the codebase is participant-centric ("fewer forms; derive over ask; the burner owns their own data"). Reconciling these two documents is the single most important follow-up action.

The implementation also contains substantial work the spec never asked for: a full supplier portal (third app), a questionnaire engine, bulletins/notifications, an audit trail, and a security/auth stack that materially exceeds the spec's §19 requirements.

### Scorecard against the spec's own Phase 1 list (§20)

| Phase 1 item | Status |
|---|---|
| Camp account creation | ✅ Built |
| User roles | ✅ Built (exceeds spec) |
| Camper onboarding | 🟡 Partial (platform-level Burner Bio, not camp-authored) |
| Camper database | 🟡 Partial (self-serve bios + rosters, not admin-managed records) |
| Camper statistics | ❌ Missing (org-side stats exist; camp-side dashboards don't) |
| Shift management | ❌ Missing |
| Working budget | ❌ Missing |
| Camp-fee payments | ⛔ Deliberately descoped (platform never holds funds) |
| Work Access Pass allocation | 🟡 Minimal (a single count field on registration) |
| Ticket allocation | ⛔ Deliberately descoped (Quicket owns ticketing) |
| Camp-list export | ❌ Missing (CSV export exists only for questionnaire results) |
| Annual submission forms | ✅ Built (six-section wizard + org review loop) |
| Previous-year duplication | ❌ Not yet built (planned as R1 flagship; schema is ready) |
| Basic placement-layout tool | ⛔ Deliberately deferred |
| Standard camp objects | ⛔ Deliberately deferred |
| Private tent placement under Bedouin tents | ⛔ Deliberately deferred |

Legend: ✅ Built · 🟡 Partial · ❌ Missing (no decision recorded against it) · ⛔ Missing by explicit recorded decision

---

## Section-by-section findings

### §3 Camper Onboarding — 🟡 Partial, different model

**Spec:** Camps author their own structured onboarding (intro, culture, rules, principles, videos, documents, acknowledgements, compulsory steps, completion tracking, new-vs-returning distinction).

**Reality:** Onboarding exists but is **platform-level, not camp-authored**. The "Burner Bio" flow (`apps/web/components/onboarding/bio-flow.tsx`, `packages/core/src/bio.ts`) onboards a burner once per edition into their own profile. The building blocks for camp-authored onboarding exist and are strong:

- A full **questionnaire engine** (`questionnaire_definitions` / `questionnaire_activations` / `questionnaire_responses`, `packages/db/src/schema.ts:1153`) with group-authored scope (`authored_scope = 'group'`), audiences, and versioning.
- **Blocking required actions** (`required_actions` with types `questionnaire | acknowledgement | payment | profile_update`) — the machinery for "compulsory steps that gate registration" already exists (schema.ts:240).
- Returning-camper awareness exists at the individual level (`burner_bios.attended_years`, `first_time`).

**Gap:** No camp-facing UI for building an onboarding curriculum (videos, documents, per-camp acknowledgements, completion dashboards). Roadmap lists "camp-people tools" as an unvalidated candidate direction.

### §5 Camper Database and Camp List — 🟡 Partial, deliberately different model

**Spec:** Admin-managed camper records: full legal name, SA ID/passport, arrival/departure, build/strike attendance, fee status, notes; admins add/edit/import/export campers.

**Reality:** The inverse model — **self-owned profiles attached to camp memberships**:

- `burner_bios` (schema.ts:559) holds legal name, contact email, phone, two emergency contacts, medical notes, SA ID/passport — with the sensitive fields **hard-locked private** and ID/passport/medical **AES/pgcrypto-encrypted at rest**, plus a documented POPIA purpose limitation and a purge design (`packages/core/src/id-retention.ts`).
- Camps have member rosters with roles, invites (`invites`, one-time tokens, lead transfer), custom project roles with permissions (`project_roles`, Roles v2), and per-camp member reference codes (`memberships.ref_code`) for the camp's own off-platform EFT reconciliation.
- Medical notes are visible to own-camp leads and org staff only, on detail views only, with every disclosing read audited (`apps/web/lib/medical-access.ts`, `apps/org/lib/medical-audit.ts`).

**Gaps vs. spec:** No admin add/edit of other people's records, no spreadsheet import, no camp-list export, no arrival/departure dates, no fee status, no duplicate detection, no archiving, no admin-only notes per camper. **This is a recorded decision, not drift** — roadmap: Graham's admin-managed camper-identity database "should likely never be built without a hard AB requirement — it's the opposite of the self-serve bio model." The spec's security requirements (§5), however, are **met or exceeded** (encryption, restricted permissions, audit logs, POPIA consent framing).

### §6 Camper Statistics — ❌ Missing (camp-side)

**Spec:** Per-camper participation stats and a camp-admin dashboard (totals, paid/outstanding, onboarding, shifts, tickets, WAPs).

**Reality:** Org-side statistics exist (`packages/core/src/org-stats.ts`, `apps/org/components/status-board/` incl. a registrations chart). Individual bios carry raw inputs (attended years, skills, camp history). There is **no camp-admin statistics dashboard**, and most of the counted things (shifts, tickets, fees, WAPs) don't exist as features to count.

### §7 Shift Management — ❌ Missing

No shift tables, no shift UI, no sign-up/swap/attendance logic anywhere in the schema or apps. Roadmap lists shifts inside the unvalidated "camp-people tools" candidate. Reminder channels (in-app, email) exist as infrastructure via notifications; WhatsApp/SMS are listed as "distant" candidates.

### §8 Working Budget and Financial Tracking — ❌ Missing

No budget tables or UI. The only budget-shaped datum is `registrations.s6_expected_budget_zar` (a single declared number for review purposes). Roadmap treats a budget tool as a candidate ("value depends on whether treasurers actually want a tool or a spreadsheet") — manual-recording-only if it ever lands.

### §9 Camp Fees and Payment Gateway — ⛔ Deliberately descoped

**Spec:** Payment gateway for dues, deposits, instalments, refunds; automatic budget updates.

**Reality:** An explicit product law in the opposite direction: **"The platform never holds or processes money"** (README, roadmap principle 6, AGENTS.md). What exists is payment *reference/status* tracking only — `payments` table (schema.ts:1498) with `pending | reconciled | waived`, a human-readable reference generator, and `memberships.ref_code` so camps can reconcile their own bank accounts. Registration is free; there is no payment UI in any registration context. A gateway (Paystack/Peach/PayFast candidates) is contemplated in R1 **only if AfrikaBurn asks for it**, and only for AB-side logistics fees — never camp dues.

### §10 Work Access Pass Allocation — 🟡 Minimal

**Spec:** A full WAP tool — categories, per-camper allocation, eligibility rules, approval tracking, exports.

**Reality:** One integer: `registrations.s4_work_access_passes` (the count a camp requests in Section 4 of the registration wizard, optional and non-blocking per `packages/core/src/registration-sections.ts:14`). No categories, no per-camper allocation, no eligibility logic, no export.

### §11 Ticket Allocation and Ticket Status — ⛔ Deliberately descoped

Roadmap, verbatim: **"Out, permanently (Ryan, 22 Jul 2026): ticketing — it stays entirely with Quicket; the platform records status at most and never issues, transfers, or integrates tickets."** Nothing ticket-related exists in the schema. Note the spec itself only required ticket *management*, not issuance — but even the management layer (allocation tracking per camper) is absent and decided against.

### §12 Theme-Camp Layout Tool — ⛔ Deliberately deferred

**Spec:** A scaled CAD-like layout designer with ~30 accurately-sized object types, rotation, clearance/safety areas.

**Reality:** Explicitly parked (roadmap: "no structured geo data exists, the official map is a PDF that arrives late… The layout designer / erf-fit ideas stay parked until AB's map process changes"; principle 5 names the layout designer as the canonical "big speculative build" that never blocks a release). What exists instead:

- Layout **file uploads** on registration Section 4 (`s4_layout_upload_urls`, max 4).
- Free-text `s4_area_dimensions`.
- **Placement-preference zones** (`packages/core/src/placement-zones.ts`) — a per-edition picker of real Tankwa Town zones for Section 5 first/second choice.

### §13 Private Tent Placement Under Bedouin Tents — ⛔ Missing (falls under the same deferral)

Nothing exists. Entirely dependent on the deferred layout tool.

### §14 AfrikaBurn Map and Erf Placement — ⛔ Deliberately deferred

Nothing map-related exists. The planned R1 substitute is **staff-assigned ERFs + camp codes on profiles** ("unblocks container booking without any placement tool"). The org↔camp feedback loop the spec wants for layout review does exist — but for registration content, not geometry (see §15).

### §15 Annual Registration and Placement Submission — ✅ Built (the core of the app)

The strongest match to the spec:

- **Six-section wizard** (`apps/web/components/registration/`, server-side completeness predicates in `packages/core/src/registration-sections.ts`): Identity, Leave No Trace, Participation & gifting, Size & logistics, Sound & placement, Suppliers & commerce. Content follows Finlay's real registration form rather than the spec's longer list.
- **Seven-state workflow** (`registration_status`: draft → submitted → under_review → changes_requested → approved / rejected / withdrawn) — matches the spec's tracking list except placement-specific states ("placement allocated", "final layout approved"), which depend on descoped placement tooling.
- **Org review loop**: per-section reviews with open/resolved state (`section_reviews`) and threaded camp↔org replies (`section_review_replies`) — this delivers the spec §13 "send back / comment / revise" collaboration pattern, applied to registration content.
- Review console in `apps/org/app/(console)/registrations/`.

**Gaps within the section:** The spec's submission contents that correspond to descoped modules are absent (camper list, full budget, safety documentation, ticket/WAP requirements beyond a count).

### §16 Previous-Year Submissions — ❌ Not yet built (schema-ready, planned)

The data model is edition-scoped throughout (`registrations` unique per group × edition; roadmap principle 3: "persistent entities, per-edition records" is "the spine"). But there is **no duplication or comparison feature yet** — "Previous-year duplication + change-comparison view" is named the **flagship fewer-forms feature of R1**. Only one edition (AfrikaBurn 2027) is seeded, so nothing exists to carry forward yet. Expiry-flagging of stale carried-forward data is a candidate ("carry-forward extensions").

### §17 Plug-and-Play and Turnkey Camp Prevention — 🟡 Partial

**Spec:** Mandatory baseline submission; automated enhanced-disclosure triggers (>20 participants, >R100k dues, turnkey services); external-service disclosure; org review powers.

**Reality:**
- Baseline submission: largely present — registration requires participation plan, fee structure, paid-performers answer, and a **mandatory Plug & Play acknowledgement** (`s6_plug_and_play_ack === true` gates submission, registration-sections.ts:107).
- External-service disclosure: **structured supplier declarations** (`supplier_declarations` linking registrations to a vetted supplier repository) replace free text — arguably better than spec.
- Org review: review console, per-section flags, supplier standings (`good | watch | suspended | …`), org-internal supplier notes (`infraction | blessing | note`), audit trail, cross-year comparison pending §16.
- **Missing:** the automated disclosure *triggers* (participant/fee thresholds, per-person charge anomalies) and a risk-indicator dashboard. Roadmap accepts the *value* but wants AB to confirm it would act on it first.

### §18 Village Functionality — ❌ Missing

No village/collective entity, no shared lists/shifts/budgets. Roadmap treats "Collectives" as "a questionable feature until real demand shows" (with a note to ask Mad Hatters at kickoff). The `groups` design (one table, many-to-many memberships) would generalise, but nothing village-shaped exists.

### §19 Creative Project Mode — 🟡 Partial (ahead of the spec's phasing)

The spec puts this in Phase 3; the implementation already has the substrate and some UI:

- `groups.kind` includes `artwork` and `mutant_vehicle` (schema.ts:49).
- Web routes exist: `apps/web/app/(app)/vehicles/` (incl. a registration form with grant-interest capture — `registrations.grants_interest` drives `mv_grant_requesters` / `art_grant_requesters` questionnaire audiences) and `apps/web/app/(app)/artworks/`.
- These projects reuse the same membership/roles/questionnaire spine, exactly as the spec envisions.

Full Creative Project Mode (build/strike planning, safety docs, budgets) inherits the gaps of those underlying modules.

### §20 (spec 19) Permissions and Security — ✅ Built, exceeds spec

The one area where reality is clearly ahead of the document:

- **Role-based permissions at three layers:** structural membership roles (`god`/`org_staff`/`lead`/`admin`/`member`/`engineer`), per-camp custom roles with permission objects (Roles v2, incl. officer roles with explicit consent flow), and org roles/departments resolved through a single capability matrix (`packages/core/src/org-permissions.ts` — `orgCan`, read by gate, actions, and UI alike).
- **Security requirements checklist vs. spec:** POPIA-compliant processing (documented lawful purpose + bounded retention for IDs) ✅ · encryption at rest for ID/passport/medical ✅ · MFA (TOTP with encrypted backup codes + passkeys) ✅ · audit logs (`audit_events` + medical-read auditing + `security_events`) ✅ · masked/locked identity numbers ✅ (hard-locked, no reveal path) · data-retention controls ✅ (id-retention module; purge job wiring pending) · consent records ✅ (officer consent, medical label-as-consent) · payment security ✅ by absence (no money) · account deletion with referential-integrity-preserving sanitization ("Departed Burner") ✅ · DB-backed rate limiting, cross-subdomain SSO, session listing/revocation ✅.
- Spec roles not modelled: treasurer, build/strike captain, shift lead, placement coordinator, wrangler — these attach to unbuilt modules (though custom project roles can label them today, and wrangler assignment is planned for R1).

### §21 (spec 21) Core Development Principle — ✅ Aligned, arguably the app's strongest suit

The spec's closing principle ("make genuine participation easier and administrative abuse harder… reduce repetitive work") is the codebase's explicit first law ("Fewer forms, not more" — README, roadmap principle 1, enforced in review). The divergences documented above (self-serve bios over admin databases, no payment handling, no ticket duplication of Quicket) are all *derivable from the spec's own principle*, even where they contradict its feature list.

---

## Built but not in the specification

Significant delivered work the spec never asked for:

1. **Supplier platform** — an entire third app (`apps/suppliers`): self-registration, onboarding steps, org-controlled documents with acknowledgements, standings, org-internal notes, seeded from AB's public supplier list; plus structured supplier declarations inside camp registration. (The spec only mentions "service providers" as a camper type and external-service disclosure.)
2. **Questionnaire engine** — definitions/activations/responses with audiences, versioning, blocking behaviour, grid questions, results view with CSV export (`apps/org/components/questionnaires/`). Positioned as the vehicle for Form 2 in R1 and reusable for camp onboarding later.
3. **Bulletins & notifications** — org broadcasts to resolved audiences plus a unified per-user notification inbox across all three apps.
4. **Org console infrastructure** — accounts management, departments, org roles, audit viewer, status board, and a `/system` diagnostics panel.
5. **Editions as a root namespace** — the year-scoping spine that makes §16 (previous-year duplication) cheap when it lands.
6. **Camp-category taxonomy and public camp directory** with duplicate-name detection.

---

## Biggest gaps ranked by spec-emphasis vs. reality

1. **Shift management** (§7) — a full spec chapter, entirely absent, and *not* explicitly descoped; the largest undecided gap.
2. **Camp-side statistics/dashboards** (§6) — absent; partially blocked on other missing modules.
3. **Previous-year duplication** (§16) — the spec's and the roadmap's shared top priority; schema-ready but not built; becomes urgent for a second edition.
4. **Working budget** (§8) — absent; the descope covers payments, but a manual budget tool is spec'd and undecided.
5. **WAP allocation tool** (§10) — only a count field; the per-camper allocation workflow is absent and undecided.
6. **Camp-authored onboarding UI** (§3) — machinery exists (questionnaires, required actions); the camp-facing product doesn't.
7. **Layout/placement tooling** (§12–14) — the spec's largest single feature area, deliberately parked pending AB map data; the fallback (uploads + zone preferences + staff-assigned ERFs) covers the mandatory submission path.

## Recommended follow-ups

1. **Reconcile the two documents.** The spec is the declared "Source of Truth Master document", yet at least four of its requirements are contradicted by recorded engineering decisions (tickets, payments, admin camper DB, placement tooling). Either the spec should absorb the decisions record, or the decisions need revisiting with AfrikaBurn — right now both documents claim authority.
2. **Decide the undecided gaps** (shifts, budget, WAP allocation, camp statistics, camp-list export) — they sit in spec-Phase-1 but roadmap-candidate limbo, which is where misaligned expectations grow.
3. **Prioritise previous-year duplication** before a second edition is seeded — both documents agree it's the flagship.
4. **Update the spec's Phase 1** to reflect what shipped instead (suppliers app, questionnaire engine, bulletins, security stack) so stakeholder-facing progress reporting matches reality.
