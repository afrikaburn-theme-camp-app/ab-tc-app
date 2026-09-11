# Compliance (POPIA) and incident response

| Field                  | Value                                                         |
| ---------------------- | ------------------------------------------------------------- |
| **Category**           | Operational                                                   |
| **Doc status**         | Active                                                        |
| **Normative language** | RFC 2119 / RFC 8174 applies                                   |
| **Requirement IDs**    | N/A — operational/legal compliance guidance, not spec-derived |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                  |

_Grounded in cited South African legal commentary, not legal advice — have
someone with a POPIA mandate review this before relying on it for a real
incident._ This is the operational half of the auth/identity contract; the
architecture, methods and threat model live in
[`technical-spec/01-auth-and-identity.md`](technical-spec/01-auth-and-identity.md).

## Lawful basis

Auth and safety PII (phone, emergency contacts) must not be grounded on
**consent** as the primary lawful basis. Use POPIA s11(1)(b) (necessary to
carry out the participation agreement) and s11(1)(d)/(f) (legitimate
interest — emergency contacts and medical notes exist for on-playa safety).
Reserve explicit consent for the genuinely discretionary sharing flow that
is already isolated in the design: the accepted-officer registration that
shares a phone with the org.

## ID / passport numbers

Collected under a named purpose (on-site identity verification against the
ticket), encrypted, and bounded-retention by rule (s14) — see
[`technical-spec/02-accounts-and-account-security.md`](technical-spec/02-accounts-and-account-security.md)
for the retention rule's current status (written, not yet scheduled). Must
not be a login identifier or a cross-system linking key.

## Medical notes — special personal information

`burner_bios.medical_notes` is special personal information (health) under
POPIA s26/27. Consent at the point of entry (the field's own label states
who will read it and why); encrypted at rest; never public, never in a list
or export, visible only on a member detail view, audited on every read. Full
model: [`technical-spec/14-audit-trail-and-medical-access.md`](technical-spec/14-audit-trail-and-medical-access.md).

## Encryption and key management

AES-256-GCM is comfortably sufficient under POPIA s19 (no specific
algorithm mandated). The real exposure is key management: a single shared
`PGCRYPTO_KEY` with no rotation path today. POPIA has **no encryption
safe-harbour** (unlike GDPR) — encrypted-then-leaked ID data may still
require notification. Treat encryption as risk-reduction, not an exemption.

## Breach notification — POPIA s22

- **Trigger**: reasonable grounds to believe an unauthorised person
  accessed or acquired personal information. There is **no materiality
  threshold** — even one leaked record triggers it.
- **Who**: notify the Information Regulator **and** each affected data
  subject, unless the subject cannot be identified.
- **Timing**: "as soon as reasonably possible after discovery." POPIA does
  **not** set a 72-hour clock (that is GDPR) — do not state 72 hours as a
  legal requirement.
- **Form**: use the Regulator's official Security Compromise notification
  template (mandatory since 12 Aug 2022).

## Data-subject rights vs. the deletion design

The 14-day-grace + sanitization deletion design maps to POPIA Condition 8
(ss23–25): access (a self-service export is not yet built), correction
(covered by the profile edit flow), deletion (sanitization satisfies
erasure — nulling personal columns is "no personal information remains,"
not merely "the row remains"). A manual erasure path for someone who cannot
log in (an email request) is not yet built; s24/25 rights are not
conditional on self-service.

## Accountability artefacts

POPIA applies to non-profits in full; there is no automatic exemption.
Before real data lands, an organisation in this position should stand up:
a Records of Processing register (per-field lawful basis, purpose,
retention, sharing), a registered Information Officer with the Information
Regulator, and a published PAIA/POPIA manual. Whether these exist for
AfrikaBurn's organisation is outside this repository's visibility.

## Retention

POPIA s14 requires not keeping personal information longer than necessary,
with no fixed statutory number for security logs. A defined,
documented retention window (6–12 months is a commonly cited default for
security-investigation logs) plus a purge job, aligned with the
sanitization-on-deletion model, is the recommended shape — not yet fully
implemented (see the ID-retention gap above).

## Public-repo disclosure

`SECURITY.md` at the repo root documents the vulnerability-reporting path.
A `/.well-known/security.txt` (RFC 9116) has not been added — worth doing
once a stable apex domain exists.

## Incident runbooks

**Suspected credential stuffing**: confirm the signal (failed-login spike),
tighten rate-limit/backoff, force password reset + revoke-all-sessions for
affected accounts, verify no `god`/`org_staff` account was hit, re-enforce
the breach blocklist for suspected accounts.

**Leaked `BETTER_AUTH_SECRET`**: rotate in Vercel env for all three apps
simultaneously (a global forced re-login).

**Leaked `PGCRYPTO_KEY` — the severe case**: every stored ID/passport
ciphertext is decryptable. Generate a new key, re-encrypt all rows. Without
key-versioning (not yet built), old and new ciphertext cannot be told apart
during rotation. Treat a leaked key as a likely reportable s22 event even
without proven exfiltration, since confidentiality can no longer be
assured.

**Compromised `god` (System manager) account**: revoke-all-sessions and
force a password reset immediately, **and** remove the affected email from
the `GOD_EMAILS` env list — session revocation alone does not contain this,
since `GOD_EMAILS` re-grants god on the next verified login. Audit
`audit_events` for actions taken while compromised and reverse unauthorised
grants.

**Accidental PII exposure**: contain (take down/limit the exposing surface),
scope (which fields, which subjects — any hard-locked field escalates
severity), preserve evidence before rotating anything, run the s22
assessment, request removal if publicly cached.

## Kill switch — not yet built

On Vercel serverless there is no long-lived process to signal, so any kill
switch must be state the request path reads on every invocation (a DB row
or edge config), not an in-memory toggle. Not built today: a global
read-only/maintenance flag, a per-capability disable reusing the existing
`AUTH_CAPABILITIES` pattern, and an emergency revoke-all-sessions broadcast
beyond rotating `BETTER_AUTH_SECRET` directly.

## Monthly report and audit logging

A one-page monthly digest (auth health, incidents, data-subject requests,
access/authz review, secrets/dependency status, compliance posture) is
recommended practice, not built as an automated artefact. Auth-event
logging into `audit_events` (sign-in success/failure, lockout, password
change, session revoke, 2FA enable/disable) is likewise not fully wired —
today `audit_events` is written on elevation/approval/payment/medical-access
events, not on every auth event listed here.
