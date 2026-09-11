# App Specification coverage — gap register

| Field                  | Value                                                                                                                      |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Category**           | Product                                                                                                                    |
| **Doc status**         | Active                                                                                                                     |
| **Normative language** | Descriptive only — this document reports build status; it does not itself impose requirements                              |
| **Requirement IDs**    | Exhaustive — full 1:1 section mirror of the App Specification. Every section below cites the `PREFIX-NNN` IDs it addresses |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                                                               |

Companion to the **App Specification** — the authoritative,
Requirement-ID-tagged source of truth for what the product should do; its
link and the full precedence chain are in
[`../README.md`](../README.md#direction-of-information-travel). That
document says what the product should do; this one says what is built, how,
and what each unbuilt part would actually take. Section numbers match the
App Spec so the two can be read side by side.

This is the App-Spec-shaped **gap register**: a 1:1 mirror by section
number, corrected against the code as of 2026-09-11. For a feature-by-feature
account with routes, tables and tests, see the individual docs under
[`docs/technical-spec/`](README.md) — each is cross-linked from the relevant
section below. Drift (a repo position that opposes an unaccepted App Spec
Decision Record) is flagged in each feature doc, not duplicated here.

| Label            | Meaning here                                     |
| ---------------- | ------------------------------------------------ |
| ✅ **Built**     | Working in the deployed apps, with tests         |
| 🚧 **Partial**   | Some of it works; the rest is named below        |
| ❌ **Not built** | No code, no database tables                      |
| ⚠️ **Blocked**   | Cannot be built yet, and the blocker is not code |

**Three facts that shape every answer below.**

1. **It is live.** Real people's phone numbers, emergency contacts and
   medical notes are in the database. There is no practice copy.
2. **Three apps, one account pool.**
3. **Rules live in one place** (`@quagga/core`), not in hidden buttons.

Diagrams: [`00-architecture.md`](00-architecture.md).

---

## 1. Product purpose 🚧

**Requirement IDs:** 🚧 PURPOSE-001, PURPOSE-002 _(App Spec §1 — the only two tagged bullets; the rest of §1 is narrative)_

Built: identity, camps and rosters, the annual registration and its review
loop, questionnaires, bulletins and notifications, the supplier repository,
an audit trail, wrangler assignment, and an in-app bug reporter — several of
these (suppliers, the reporter, wranglers, bulletins) extend beyond what §1
itself names. Not built: the camp-operations modules — shifts, budgets,
tickets, layout.

**Deployment scope note:** the current build is single-organisation
(one seeded `groups.kind='org'` row), single-edition-at-a-time, and
AfrikaBurn-branded by construction (copy, export filenames). "AfrikaBurn or
similar participatory events" in the App Spec's own framing is aspirational
multi-tenancy that is not built.

## 2. Core modules — technical state 🚧

**Requirement IDs:** ✅ CORE-009 · 🚧 CORE-001, CORE-005, CORE-010 · ❌ CORE-003, CORE-004, CORE-007, CORE-011 · ⚠️ CORE-002, CORE-006, CORE-008 _(App Spec §2)_

| Module                                | State                                                                           | Doc                                                                                                                                              |
| ------------------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Camper onboarding                     | 🚧                                                                              | [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md)                                                                                 |
| Camper database / camp list           | ⚠️                                                                              | [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md), [`04-camps-directory-invites-roster.md`](04-camps-directory-invites-roster.md) |
| Shift management                      | ❌                                                                              | —                                                                                                                                                |
| Budget and financial tracking         | ❌                                                                              | [`20-payment-reference-tracking.md`](20-payment-reference-tracking.md)                                                                           |
| Work Access Pass allocation           | 🚧                                                                              | [`06-registration-and-review.md`](06-registration-and-review.md)                                                                                 |
| Ticket allocation                     | ⚠️                                                                              | —                                                                                                                                                |
| Tent placement under Bedouin tents    | ❌                                                                              | —                                                                                                                                                |
| Placement and layout design           | ⚠️                                                                              | [`08-placement-codes-and-erf.md`](08-placement-codes-and-erf.md)                                                                                 |
| Annual registration and submission    | ✅                                                                              | [`06-registration-and-review.md`](06-registration-and-review.md)                                                                                 |
| Previous-year records and duplication | ✅ _(was 🚧 — corrected 2026-09-11: carry-forward and comparison both shipped)_ | [`07-previous-year-carry-forward.md`](07-previous-year-carry-forward.md)                                                                         |
| Camp reporting and statistics         | ❌                                                                              | [`17-org-status-board.md`](17-org-status-board.md) is a distinct org-side board, not this                                                        |

## 3. Camper onboarding 🚧

**Requirement IDs:** ✅ ONBOARD-019, ONBOARD-020 _(corrected 2026-09-11 — camp-lead-authored blocking questionnaires and per-respondent completion tracking both work)_ · 🚧 ONBOARD-004, ONBOARD-005, ONBOARD-010, ONBOARD-014, ONBOARD-015, ONBOARD-017, ONBOARD-018, ONBOARD-021 · ❌ ONBOARD-001–ONBOARD-003, ONBOARD-006–ONBOARD-009, ONBOARD-011–ONBOARD-013, ONBOARD-016, ONBOARD-022–ONBOARD-028 _(App Spec §3)_

Full detail: [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md).

**Corrected 2026-09-11**: the previous claim that "camp-lead authorship of
onboarding content is not yet wired" was stale. `apps/web/app/(app)/camps/[slug]/questionnaires/new/page.tsx`
and `packages/core/src/questionnaire-authz.ts` show it is built. Document
upload (ONBOARD-017) also moved from ❌ to 🚧 — a respondent can upload a
file to a questionnaire field, though not as camp-published media.

## 4. Camper database and camp list ⚠️

**Requirement IDs:** ✅ CDB-027, CDB-035, CDB-037, CDB-038, CDB-040, CDB-041, CDB-043 · 🚧 CDB-031, CDB-032, CDB-039, CDB-042 · ❌ CDB-025, CDB-026, CDB-028, CDB-029, CDB-030, CDB-033, CDB-034, CDB-036 · ⚠️ CDB-001–CDB-024 _(App Spec §4)_

Full detail and the Decision 008 drift note: [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md).

**Corrected 2026-09-11**: CDB-035 (carry returning camper details forward)
moved ❌ → ✅ — shipped. CDB-031/CDB-032 (filter/search campers) moved
✅ → 🚧 — verified: nothing filters or searches _campers_; what exists
filters camps and searches org accounts by username/email. CDB-039 (masked
ID numbers) is 🚧 by convention here but is better read as "not built by
design" — see the drift note in the feature doc; masking is not partially
implemented, it is deliberately replaced by non-exposure.

## 4a. Camper communications

**Requirement IDs:** ❌ COMM-001, COMM-002, COMM-005, COMM-008–COMM-011, COMM-018, COMM-020 · 🚧 COMM-003, COMM-012, COMM-013–COMM-016 · ✅ COMM-004, COMM-006, COMM-007, COMM-017, COMM-019 _(App Spec §4a — added to the App Spec 2026-08-10; absent from earlier versions of this document, which is corrected here)_

- ✅ **COMM-004/005/007** (burner details, bio, home location on request):
  a privacy-gated public profile projection exists — see
  [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md).
- ✅ **COMM-006** (skills): captured on the bio and projected publicly when
  the burner opts in.
- ✅ **COMM-017/019** (camper-controlled visibility, changeable any time):
  per-field privacy flags, changeable at any time, with hard locks that
  cannot be overridden.
- 🚧 **COMM-003** (selecting a tile opens a shared profile): works from a
  camp roster row; there is no cross-camp people directory to select a tile
  from in the first place.
- 🚧 **COMM-012** (group communications): org → audience broadcasts exist
  (bulletins); no camp-level announcement channel — see
  [`11-bulletins-and-notifications.md`](11-bulletins-and-notifications.md).
- 🚧 **COMM-013–016** (group formation — shifts, functions, friends):
  custom project roles are the only grouping mechanism — see
  [`05-camp-roles-and-officers.md`](05-camp-roles-and-officers.md).
- ❌ **COMM-001/002** (photo-tile dashboard): blocked on there being no
  photo column on `burner_bios` at all.
- ❌ **COMM-008–011** (messaging, calling, video invites, scheduling),
  **COMM-018** (control over being contacted at all), **COMM-020**
  (cross-camp Village visibility): none of these exist; there is no contact
  channel built to control in the first place.

## 5. Camper statistics ❌

**Requirement IDs:** ❌ STATS-001–STATS-031 _(App Spec §5 — nothing built; distinct from the org-facing status board, [`17-org-status-board.md`](17-org-status-board.md))_

Nothing built for camps. Counts things that do not exist yet (shifts, fees,
tickets, passes).

## 6. Shift management ❌

**Requirement IDs:** ❌ SHIFT-001–SHIFT-029 _(App Spec §6 — nothing built)_

Nothing exists — no shifts, no sign-ups, no attendance.

## 7. Working budget 🚧

**Requirement IDs:** 🚧 BUDGET-001 (one optional integer, `s6ExpectedBudgetZar`) · ❌ BUDGET-002–BUDGET-062 _(App Spec §7)_

See [`20-payment-reference-tracking.md`](20-payment-reference-tracking.md).
No decision record exists at all for §7's broader scope (working budget
tool vs. permanently out of scope) — see the drift note there.

## 8. Camp fees and payment gateway ⚠️

**Requirement IDs:** ❌ PAY-001–PAY-021 _(App Spec §8)_

Full detail and the Decision 009 drift note: [`20-payment-reference-tracking.md`](20-payment-reference-tracking.md).
**Corrected 2026-09-11**: this document previously stated "payments are
recorded — staff reconcile EFT and cash manually." Verified false in the
present tense — `payments` has zero application readers or writers today;
the tracking logic is built and dormant, not active.

## 9. Work Access Pass allocation 🚧

**Requirement IDs:** 🚧 WAP-001 · ❌ WAP-002–WAP-017 _(App Spec §9)_

See [`06-registration-and-review.md`](06-registration-and-review.md) and
[`09-exports-and-scheduled-jobs.md`](09-exports-and-scheduled-jobs.md).
WAP-009 (export allocation lists): the placement CSV export carries a
_requested-count_ column per camp, which is not an allocation list — do not
cite the export against WAP-009.

## 10. Ticket allocation ⚠️

**Requirement IDs:** ❌ TICKET-001–TICKET-017 _(App Spec §10 — Quicket remains system of record; governed by Decision 010, proposed)_

Nothing built. See the drift note in [`../roadmap.md`](../roadmap.md) and
`AGENTS.md`'s product-positions section — this is a build stance pending
Decision 010, not a permanent exclusion.

## 11. Theme-camp layout tool ⚠️

**Requirement IDs:** ⚠️ LAYOUT-001–LAYOUT-043 _(App Spec §11 — governed by Decision 011, proposed)_

Camps upload a layout diagram (up to 4 files) and state text placement
preferences at registration. See
[`06-registration-and-review.md`](06-registration-and-review.md) and
[`08-placement-codes-and-erf.md`](08-placement-codes-and-erf.md) for the
drift note on the "no structured geo data exists" premise, which Decision
012's own record contradicts.

## 12. Private tent placement under Bedouin tents ❌

**Requirement IDs:** ❌ TENT-001–TENT-034 _(App Spec §12 — depends entirely on §11)_

Depends entirely on §11.

## 13. AfrikaBurn map and erf placement ⚠️

**Requirement IDs:** 🚧 ERF-017 (a staff-assigned free-text erf/camp-code handle now exists) · ❌ ERF-001–016 · 🚧 ERF-019–023 (the approve/reject/comment/revise loop already exists as the registration review mechanism, reusable once map data is integrated) _(App Spec §13 — governed by Decision 012, proposed)_

Full detail: [`08-placement-codes-and-erf.md`](08-placement-codes-and-erf.md).
**Corrected 2026-09-11**: a staff-assigned, org-only erf/camp-code handle
shipped in the registration-season release. It is not the interactive
map/erf system §13 describes, and the camp side cannot see its own erf at
all — but it is a step this document did not previously record.

## 14. Annual registration and placement submission ✅

**Requirement IDs:** ✅ REG-001, REG-002, REG-004, REG-005, REG-007, REG-011, REG-012, REG-014, REG-018, REG-021, REG-022–REG-028 · 🚧 REG-006, REG-029, REG-030 · ❌ REG-003, REG-008, REG-009, REG-010, REG-013, REG-015, REG-016, REG-017, REG-019, REG-020 _(App Spec §14)_

Full detail: [`06-registration-and-review.md`](06-registration-and-review.md).
**Corrected 2026-09-11**: REG-013/015/020 (power, fire, safety
documentation) moved 🚧 → ❌ — verified no field exists behind any of the
three; `apps/org/lib/queries.ts` hardcodes all three officer-trigger checks
to `false`. REG-029/030 (placement allocated, layout approved) moved
❌ → 🚧 — the staff-assigned erf (§13) is the nearest thing to a placement
status, though it is not a formal status and the camp cannot see it.
Also shipped and now documented: placement CSV export, registration
deadline reminders (built, unscheduled) — see
[`09-exports-and-scheduled-jobs.md`](09-exports-and-scheduled-jobs.md).

## 15. Previous-year submissions ✅

**Requirement IDs:** ✅ PREVYR-002, PREVYR-003, PREVYR-011, PREVYR-012, PREVYR-013 · 🚧 PREVYR-001, PREVYR-008, PREVYR-009, PREVYR-010, PREVYR-016, PREVYR-022, PREVYR-024, PREVYR-025 · ❌ PREVYR-004–007, PREVYR-014, PREVYR-015, PREVYR-017, PREVYR-019–021, PREVYR-023 _(App Spec §15)_

Full detail: [`07-previous-year-carry-forward.md`](07-previous-year-carry-forward.md).

**Corrected 2026-09-11 — this section was the most stale in the previous
version of this document.** It previously read "❌ PREVYR-002–010,
PREVYR-013–025 — nothing forward-carrying exists." Verified: registration
duplication, bio carry-forward, and a reviewer-side year-on-year comparison
all shipped in the registration-season release (before this correction).
The rollover rule (blank every Form-2 field, carry only Form-1) is a
deliberate design choice, not an oversight — see the drift note in the
feature doc.

## 16. Plug-and-play and turnkey prevention 🚧

**Requirement IDs:** ✅ PNP-003, PNP-005, PNP-006, PNP-007, PNP-040, PNP-041, PNP-042, PNP-047 · 🚧 PNP-002, PNP-039, PNP-043, PNP-046, PNP-048, PNP-049 · ❌ PNP-001, PNP-004, PNP-008–PNP-015, PNP-016–PNP-038, PNP-044, PNP-045 _(App Spec §16)_

Full detail: [`06-registration-and-review.md`](06-registration-and-review.md).
**Corrected 2026-09-11**: PNP-040/041/042 (review camper numbers, fees,
external services) and PNP-047 (request corrective measures) all moved
❌ → ✅ — all four appear on the org review screen and `request_changes`
requires a written reason. PNP-016–038 (23 named service/specialist
categories) reclassified 🚧 → ❌ — the built vocabulary is 8 generic
delivery categories; only "Transport" overlaps the spec's list. PNP-049
(cross-year comparison) is genuinely built now but gated on the
registration having a carry-forward source.

## 17. Village functionality ❌

**Requirement IDs:** ❌ VILLAGE-001–VILLAGE-015 _(App Spec §17 — nothing built)_

Not built. **Corrected 2026-09-11**: the previous claim that "the `groups`
schema's group-containing-groups shape is structural readiness" overstates
what exists — `groups` is a single flat table with no group-to-group
relation or parent column; a Village would need both a new `group_kind`
value and a new relation table, neither of which exists today.

## 18. Creative Project Mode 🚧

**Requirement IDs:** ✅ CREATIVE-001, CREATIVE-002, CREATIVE-009, CREATIVE-018 · 🚧 CREATIVE-005, CREATIVE-007 · ❌ CREATIVE-003, CREATIVE-004, CREATIVE-006, CREATIVE-010, CREATIVE-012, CREATIVE-013, CREATIVE-014, CREATIVE-015, CREATIVE-017, CREATIVE-019 · ⚠️ CREATIVE-008, CREATIVE-011, CREATIVE-016 _(App Spec §18)_

Full detail: [`19-creative-projects.md`](19-creative-projects.md).
**Corrected 2026-09-11**: CREATIVE-014 (Work Access Passes) and
CREATIVE-017 (safety documents) moved 🚧 → ❌ — projects have no WAP field
and no safety-document upload at all, contradicting this section's earlier
"arrives roughly free" framing; camps got carry-forward in the
registration-season release and creative projects did not (CREATIVE-019).

## 19. Permissions and security ✅

**Requirement IDs:** ✅ SEC-001, SEC-002, SEC-010, SEC-011, SEC-012, SEC-013, SEC-014, SEC-015, SEC-016, SEC-021 · 🚧 SEC-005, SEC-006, SEC-007, SEC-009, SEC-017, SEC-019, SEC-020, SEC-023 · ❌ SEC-003, SEC-004, SEC-008, SEC-018, SEC-022 _(App Spec §19)_

Full detail: [`01-auth-and-identity.md`](01-auth-and-identity.md),
[`02-accounts-and-account-security.md`](02-accounts-and-account-security.md),
[`05-camp-roles-and-officers.md`](05-camp-roles-and-officers.md),
[`14-audit-trail-and-medical-access.md`](14-audit-trail-and-medical-access.md),
[`16-org-permissions-and-system-panel.md`](16-org-permissions-and-system-panel.md).

**Corrected 2026-09-11**: SEC-009 (placement coordinator) moved ✅ → 🚧 —
no placement-coordinator role or concept exists in code; a role with that
label could be created as data, but nothing behind it is built, the same
state as SEC-005/006/007. SEC-018 (secure backups) moved 🚧 → ❌ — no
backup policy or code exists; the only "backup" is 2FA backup codes, an
unrelated feature. SEC-004 (Treasurer) and SEC-008 (Shift lead) reclassified
❌ → 🚧 for consistency with SEC-005/006/007, which sit on identical
evidence (a camp can create a custom-role label with that name; nothing
behind the label is built).

## 20. First development release ⚠️

**Requirement IDs:** ✅ RELEASE-001, RELEASE-002, RELEASE-012, RELEASE-013, RELEASE-022, RELEASE-031 · 🚧 RELEASE-003, RELEASE-008, RELEASE-009, RELEASE-021, RELEASE-033 · ⚠️ RELEASE-004, RELEASE-014, RELEASE-016 · ❌ RELEASE-005–RELEASE-007, RELEASE-010, RELEASE-011, RELEASE-015, RELEASE-017–RELEASE-020, RELEASE-023–RELEASE-032 (except 031), RELEASE-034 _(App Spec §20)_

The App Spec's Phase 1 was written before the current build existed.
**Corrected 2026-09-11**: RELEASE-013 (previous-year duplication) moved
❌ → ✅; RELEASE-031 (supplier management) and RELEASE-022 (organisation
review dashboard) moved ❌ → ✅/🚧 — `apps/suppliers` and the org review
console both exist, which directly contradicted the prior ❌ given this
same document's own §1 already listed the supplier repository as built.

`docs/roadmap.md`'s R0–R3 committed track functions as this repo's proposed
rebaseline of this section, tracked against **Decision 013 (rebaseline
first-release phase scope, proposed)** — it should be read as an input to
that decision, not as a settled replacement for §20.

## 21. Core development principle ✅

**Requirement IDs:** ✅ PRINCIPLE-001–PRINCIPLE-008 _(App Spec §21)_

Held, and visible in the technical choices: the platform records money
without holding it, publishes nothing it was not given permission to
publish, audits access to sensitive things, and asks people for their own
data rather than having administrators enter it for them. Where this
document disagrees with the App Spec — §4 and §8 most sharply — the
disagreement is tracked against **Decision 008** and **Decision 009**
(both proposed), not asserted here as a standing override of the App
Spec's own requirement text.
