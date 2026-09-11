# Audit trail and medical access

| Field                  | Value                                          |
| ---------------------- | ---------------------------------------------- |
| **Category**           | Security                                       |
| **Doc status**         | Active                                         |
| **Normative language** | RFC 2119 / RFC 8174 applies                    |
| **Requirement IDs**    | Partial — `SEC-013, SEC-014, SEC-016, SEC-021` |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                   |

Medical notes are the strictest personal-data class in the system: never
public, visible only to a defined audience, and every disclosing read is
recorded. This document is the consent, access, and audit model for that
class, plus the general audit trail it sits inside.

## Implements (App Specification)

| App Spec §                   | IDs                                                                                                         | Status | Notes |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------- | ------ | ----- |
| §19 Permissions and security | SEC-013 (POPIA-compliant processing), SEC-014 (encryption), SEC-016 (audit logs), SEC-021 (consent records) | ✅     |       |

## Consent at the point of entry

Medical notes are never public, but are **visible** to the audience the
burner disclosed them to — AfrikaBurn already runs this model on paper (a
burner writes medical information on a form knowing the safety team and
their camp hold it). **The disclosure is the consent.** There is no reveal
ceremony (no reason prompt, no per-view notification) — friction at the
moment of an emergency read protects nobody.

**What stays absolutely locked, unchanged by any of this**: phone, both
emergency contacts, SA ID and passport remain hard-locked with no access
path of any kind (see
[`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md)).

**The consent control is the field's own label.** `MEDICAL_AUDIENCE_NOTE`
(`packages/core/src/bio.ts`) is the single string that states the audience,
rendered everywhere medical is captured or edited.

## Who may see it

Pure predicate `canViewMedicalNotes` (`packages/core/src/medical-access.ts`,
fail-closed):

- the owner (their own notes);
- **org staff** (`org_staff` / `god`) — the `engineer` rank is deliberately
  **not** in this set and must not be added: it is the console's IT rank,
  holds no care duty, and the org capability matrix refuses it personal
  information unconditionally;
- a **camp lead/admin**, but only for a member of a camp they lead (a lead
  of camp A is refused for a member of camp B). Custom project roles do
  not grant it — structural leads only.

## Detail views only

Notes render on a member's detail view and nowhere else — never in a list,
roster, card, or export. Both detail resolvers (`resolveMedicalNotesForViewer`
in `apps/web`, `getRosterMemberDetail` in `apps/org`) authorise **before**
querying, so a refusal never loads the ciphertext into render scope at all.
An earlier build briefly rendered a has/has-not signpost on the org roster;
it was removed, since whether a _named_ person has declared a health
condition is itself special-category-adjacent under POPIA, and the signpost
wrote no audit row for the census it exposed.

## Audit

Every disclosing read writes an `audit_events` row (`bio.medical.view` —
actor, subject, `meta.basis`, timestamp), written off the critical path via
Next's `after()` so the audit never blocks or slows an emergency read.
Reading your own notes, or reading an empty field, is not audited.

**The audit fails open, deliberately** — a dropped serverless instance or a
DB blip yields a silent, unlogged disclosure rather than blocking the read.
This is the accepted trade-off: an emergency medic read must not wait on a
log write.

**The trail is a record, not monitoring.** There is deliberately **no
volume threshold, no per-actor profiling, and no alerting** on this data. An
earlier build shipped an enumeration detector flagging heavy same-hour
reads; it was removed, because reading many members' notes in one sitting
_is_ what routine safety-preparation work looks like, and flagging it both
buries real signal in false positives and teaches the people most trusted
with this information that the tool watches them.

## The general audit trail (`/audit`)

`apps/org/lib/medical-audit.ts` — `getMedicalAccessLog` (a 30-day window,
capped) and `getAuditTrail` (the whole trail, chronological, no derived
judgement). Shown at `/audit` (any org rank). It shows **who looked at
whose notes, never the notes** — reading the trail itself is not a
disclosure and writes no audit row.

The medical panel specifically requires `read_personal_information` in the
**`audit` domain**, so an `engineer` is refused by their rank's carve-out
and a department-scoped lead is refused unless their department owns the
audit log — the log spans every camp, so a grant over one department is not
a grant over a console-wide census. Medical reads are excluded from the
org console's six-row glance/activity feed for the same reason (one camp's
worth of reads would otherwise crowd out every registration decision).

## Invariants and tests

`packages/core/src/__tests__/{medical-access,privacy}.test.ts`,
`apps/org/lib/__tests__/{medical-audit-surface,roster-privacy}.test.ts`.
