# Accounts and account security

| Field                  | Value                                                                                   |
| ---------------------- | --------------------------------------------------------------------------------------- |
| **Category**           | Security                                                                                |
| **Doc status**         | Active                                                                                  |
| **Normative language** | RFC 2119 / RFC 8174 applies                                                             |
| **Requirement IDs**    | Partial — `SEC-*` (as-built account/security feature; POPIA specifics for App Spec §19) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                            |

The account-management suite across all three apps: self-service password,
email, 2FA, passkey and session management, plus deletion. Grounded in NIST
SP 800-63B-4 and OWASP authentication guidance.

## Implements (App Specification)

| App Spec §                   | IDs                                                                     | Status  | Notes                                                                                                                              |
| ---------------------------- | ----------------------------------------------------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| §19 Permissions and security | SEC-013 (POPIA-compliant processing), SEC-020 (data-retention controls) | ✅ / 🚧 | Lawful purpose documented on the schema; account deletion is scheduled, ID-document purge is written but has no caller (see Drift) |
| §4 Camper database           | CDB-002 (contact details self-managed)                                  | ✅      | Extends the self-owned Burner Bio model — see [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md)                     |

## Drift

> ⚠️ **SEC-020 — partial, correctly.** Account deletion is scheduled (14-day
> grace, `apps/web/vercel.json` cron). ID/passport purge
> (`packages/core/src/id-retention.ts`) is a pure, tested rule with **no
> caller anywhere in the codebase** — nothing invokes `buildIdPurgePatch()`
> on a schedule, so ID ciphertext accumulates one row per user per edition
> with no automated removal. This is a known, deliberately accepted gap
> (`docs/roadmap.md` records the reasoning) rather than an oversight — but it
> means "bounded retention" is a rule that exists in code, not a behaviour
> the running system exhibits yet.

## What we run

**Self-hosted Better Auth**, pinned to 1.6.25 exactly — see
[`01-auth-and-identity.md`](01-auth-and-identity.md) for the architecture.
`better-auth` must not be auto-bumped.

### Capability matrix

The machine-readable authority is `AUTH_CAPABILITIES` in
`packages/core/src/auth-capabilities.ts`; `assertCapability()` is the
fail-closed gate. Every key is currently `supported`:

| Capability             | Backed by                                                                                         |
| ---------------------- | ------------------------------------------------------------------------------------------------- |
| Password change        | `auth.api.changePassword`                                                                         |
| Password reset         | `auth.api.requestPasswordReset` / `resetPassword`; a reset ends every session                     |
| Email verification     | `auth.api.sendVerificationEmail` / `verifyEmail`                                                  |
| Session list / revoke  | `auth.api.listSessions` / `revokeSession(s)` / `revokeOtherSessions`                              |
| Linked sign-in methods | `auth.api.listUserAccounts` + `accountInfo`; unlinking the last method is refused                 |
| Email change           | `auth.api.changeEmail`, plus a 48h revocation window and POPIA state machine on top               |
| 2FA / TOTP             | the `twoFactor` plugin; lockout at 10 fails / 15 min                                              |
| Backup codes           | inside the `twoFactor` plugin, stored **encrypted**; ten single-use codes shown once, regenerable |
| Passkeys               | `@better-auth/passkey`, `rpID` scoped to the configured apex                                      |
| Account deletion       | 14-day grace + sweeper — sanitizes app rows **and** hard-deletes the Better Auth identity         |

Password-reset mail and the email-change confirmation both need
`RESEND_API_KEY` — without it, the capability is supported but delivery is
not configured, and the System panel reports which is the case. **The rule
this preserves: code must not fake an unsupported capability** — an
unavailable surface renders an honest "not available yet" state and its
action fails closed, never a silent no-op that looks like success.

## Security principles

- **Passwords**: minimum 15 characters, accept ≥64; no composition rules, no
  forced rotation; length-based strength feedback; breach blocklist check on
  set.
- **Rate limiting & lockout**: DB-backed throttling in `@quagga/auth`; the
  `twoFactor` plugin's own account lockout guards the verify endpoints.
- **No user enumeration**: sign-in, sign-up and forgot-password all return
  generic messages.
- **2FA**: TOTP via authenticator apps + one-time backup codes. SMS
  explicitly excluded. Passkeys shipped alongside it; both are additive to
  password/Google, never the only way in.
- **Recovery**: email reset links — single-use, short-lived,
  enumeration-safe; all sessions invalidated on reset; notification sent on
  completion.
- **Email change**: confirm via the new address, notify the old address
  with a revocation link, changes revocable for 48h.
- **Sessions**: visible active-session list (device, approximate location,
  last seen); revoke one or all.
- **Security notifications** (Resend): password changed, 2FA
  enabled/disabled, email change requested/completed, deletion requested.
- **Deletion**: re-auth to request (password or 2FA) → 14-day grace period
  (cancelable by simply signing in) → **sanitization, not row deletion**:
  personal fields are erased/anonymized to a stub so memberships,
  responses and audit history keep referential integrity, satisfying POPIA
  erasure. Constraints: a sole camp lead must transfer leadership first;
  a supplier account with in-flight onboarding warns the org; a `god`
  account cannot self-delete while it is the only one.

## Surfaces (built in `apps/web`; 2FA/passkey pieces shared from `@quagga/ui`)

- **`/account` — Manage My Account**: username, email (change flow above),
  linked sign-in methods (password, Google, passkeys list).
- **`/account/security` — Security**: 2FA setup (QR enrol → verify → backup
  codes shown once → regenerate), active sessions with revoke, recent
  security events feed.
- **`/account/delete` — Delete My Account**: consequences list, re-auth,
  grace-period explanation, final confirm.
- **Forgot password**: request page + reset page (both apps' auth areas).

## ID document — lawful purpose and bounded retention

SA ID / passport on `burner_bios` are collected for one documented purpose:
**on-site identity verification against the ticket at the gate**. Always
private (hard-locked, never public), AES-256-GCM encrypted at rest, used for
nothing else — the lawful basis that makes the collection POPIA-defensible.

The retention rule (`packages/core/src/id-retention.ts`) ages an edition's ID
data out `ID_RETENTION_GRACE_DAYS` (30) after its end date, and
`identifyPurgeableIdBios` computes which rows qualify. As noted in Drift
above, nothing schedules the purge yet.

## Security events log

`/account/security`'s feed reads a real append-only `security_events` table
(migration 0014), not the `notifications` table. Every already-firing
account action records an event thinly and best-effort
(`recordSecurityEvent` — a failed insert never breaks or rolls back the
primary action): password changed, password reset completed,
single-session revoke, sign-out-everywhere, email change
requested/confirmed/revoked, deletion requested/cancelled. The captured
IP/user-agent is personal data, so `security_events` is one of the
sanitization-purged tables (erased with the account).

## Structural decisions

1. **The account routes sit outside each app's own gate**, in their own
   route group — the only requirement is a signed-in identity.
2. **Deletion has one implementation, on `apps/web`.** The other two apps
   carry a Delete tab that states what that app loses and deep-links across.
3. **Email change is offered on `apps/web` only**, for the same reason.
4. **The sweeper never runs unauthenticated and never in a build** —
   `POST /api/account/deletion-sweep` refuses without `ACCOUNT_SWEEP_SECRET`.

## Where these rules live

Schema: migrations 0011 (deletion and email-change requests,
`users.sanitized_at`), 0013 (Better Auth tables), 0014 (`security_events`),
0015 (2FA, backup codes, passkeys). Rules: `@quagga/core`
(`auth-capabilities`, `account-security`, `account-sanitization`,
`id-retention`). Presentation: `@quagga/ui` account components, shared by
all three apps.
