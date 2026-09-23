# Auth and identity

| Field                  | Value                                                                                                                                                                                                             |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Category**           | Security                                                                                                                                                                                                          |
| **Doc status**         | Active                                                                                                                                                                                                            |
| **Normative language** | RFC 2119 / RFC 8174 applies                                                                                                                                                                                       |
| **Requirement IDs**    | Partial — `SEC-014`, `SEC-015`, `SEC-018`, `SEC-019` (most content — Better Auth architecture, the methods ladder, hardening checklist, threat model — is engineering detail with no direct App Spec counterpart) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                                                                                                                                                      |

Self-hosted Better Auth **1.6.25**, in `packages/auth`, mounted per app at
`/api/auth/[...all]`. One account pool, auth tables owned by `packages/db`
(migration 0013), 2FA/TOTP and passkeys since migration 0015, DB-backed rate
limiting. This is the security and compliance contract for the auth stack:
architecture, methods offered, hardening that must hold, and the threat
model. POPIA obligations and incident runbooks live in
[`../compliance-and-incident-response.md`](../compliance-and-incident-response.md).

## Implements (App Specification)

| App Spec §                   | IDs                                   | Status | Notes                                                                                                                                                                                                                        |
| ---------------------------- | ------------------------------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| §19 Permissions and security | SEC-014 (encryption)                  | ✅     | AES-256-GCM via `packages/db/src/crypto.ts`                                                                                                                                                                                  |
| §19                          | SEC-015 (multi-factor authentication) | ✅     | TOTP + encrypted backup codes + passkeys — exceeds the requirement, which only asks for MFA to exist                                                                                                                         |
| §19                          | SEC-018 (secure backups)              | ❌     | No backup policy, procedure or code exists in this repo. The only "backup" artefact is 2FA backup codes, a different thing. Database backup is Neon's responsibility (point-in-time recovery), undocumented here — see Drift |
| §19                          | SEC-019 (access expiration)           | 🚧     | Sessions and invites expire (`session.expiresAt`, `invites.expiresAt`, 30-day default). Org-role assignments and department membership do not expire                                                                         |

## Drift

> ⚠️ **SEC-018 — technical-spec-stale.** The pre-restructure `docs/technical-spec.md`
> marked SEC-018 (secure backups) 🚧 "Partial." Verified: there is no backup
> policy, runbook, or code anywhere in the repository. The only "backup" is
> 2FA backup codes — an unrelated feature that happens to share the word.
> Recommendation: reclassify as ⚠️ (blocked on an operational decision, not
> code) and add a one-paragraph note to `docs/deploy.md` stating that backups
> are Neon's point-in-time-recovery feature and that no additional restore
> procedure is documented.

## Architecture

### Topology — shared config, mounted per app

`@quagga/auth` exports one `betterAuth` config: `drizzleAdapter(db, {
provider: 'pg', schema })`, `emailAndPassword`, `socialProviders` (Google),
and plugins (`twoFactor`, `passkey`, `haveIBeenPwned`). Each app adds
`app/api/auth/[...all]/route.ts` via `toNextJsHandler(auth)` and calls
`auth.api.*` directly server-side. All three point the adapter at the same
Neon database — one account pool. Better Auth is stateless per-request (it
reads the DB), so running three copies against one database is the intended
shape, not a workaround.

The proxy shape ("one app hosts `/api/auth`, others point `baseURL` at it")
is deliberately not used — it would force cross-origin HTTP for every
server-side authz check and break the server-enforced predicate pattern
(`AGENTS.md`'s hard engineering rules).

All three Vercel projects share the identical `BETTER_AUTH_SECRET` — a
cookie signed by one app must verify in another. A drifted value silently
logs users out; this is the single highest-risk config item in the whole
design and there is no automated alert on it (see Observability below).

### Apex domain, cookies and sessions

Cross-subdomain SSO needs `advanced.crossSubDomainCookies = { enabled: true,
domain: '<apex>' }` plus `trustedOrigins`, and cannot work on `*.vercel.app`.
The apex is **env-driven** (`AUTH_APEX_DOMAIN`, resolved in
`packages/auth/src/env.ts`) with no built-in default — a deployment with no
apex configured gets host-only cookies and no cross-app SSO, never a
hardcoded fallback domain. See `resolveApexDomain`, `resolveCookieDomain`,
`resolveProductionOrigins` in that file.

Sessions are **database sessions** (Better Auth's default), not stateless
JWT — this is what gives the revocable active-session list and
revoke-one/others/all. A signed `session.cookieCache` (5-minute `maxAge`)
gives fast reads without giving up server-side revocation; the trade-off,
stated on the System panel, is that a revoked session can still be honoured
for up to that long because the check is a cookie signature, not a database
read.

### Schema ownership

Better Auth's core tables (`user`, `session`, `account`, `verification`,
plus `twoFactor` and `passkey`) live in `packages/db/src/schema.ts` —
`packages/db` stays the single schema owner. Better Auth's own `auth migrate`
CLI is never used (Kysely-only, would not touch a Drizzle project); tables
are generated via the Better Auth CLI, hand-placed into `schema.ts`, then
`db:generate` produces the append-only migration in the usual way.

**Better Auth's `user` table sits beside the app's own `users` table**,
joined by id, rather than the app absorbing Better Auth's shape — this was
the one near-irreversible decision in the original design work and it is
closed.

## Authentication methods ladder

**Password (15+ char, breach-checked) primary, with email verification and
password reset**, plus **TOTP with encrypted backup codes** as an opt-in
second factor and **passkeys** as an optional progressive-enhancement
accelerator. Passkey-first was deliberately not chosen, given a
mostly-Android, budget-device, high-fragmentation participant base where
conditional UI and cross-device hybrid sign-in have narrower support
boundaries than password + TOTP.

- **Passkeys** (`@better-auth/passkey`, migration 0015): `rpID` is scoped to
  the deployment's configured apex domain so one passkey works across
  app./org./suppliers. subdomains — this is the one near-irreversible passkey
  decision: a passkey scoped to a subdomain does not work on the others and
  cannot be widened without re-enrolling every user. Discoverable
  credentials (`residentKey: "required"`), `userVerification: "preferred"`.
  Additive only — never the only way in, so a lost passkey is never a
  lockout (recovery: password or a 2FA backup code).
- **TOTP / backup codes**: the `twoFactor` plugin's `backupCodeOptions` is
  set to `storeBackupCodes: "encrypted"` explicitly (the factory default is
  plaintext) — plaintext recovery codes in the database would be a
  POPIA and security failure. Plugin lockout at 10 failed codes / 15
  minutes on the `/two-factor/*` verification endpoints; this is not the
  same as sign-in lockout.
- **Recovery**: email reset links — single-use, short-lived,
  enumeration-safe; all sessions invalidated on reset
  (`revokeSessionsOnPasswordReset: true`, which defaults to `false` in
  Better Auth and is explicitly turned on here); notification sent on
  completion.

## Security hardening checklist

- **Rate limiting**: `storage: 'database'` — the default `memory` storage is
  per-Lambda on Vercel and effectively bypassable by spreading attempts
  across instances, so it is never used. `AUTH_RATE_LIMIT_WINDOW_SECONDS` /
  `AUTH_RATE_LIMIT_MAX` exist only to _raise_ the ceiling for a test
  deployment (the e2e suite's parallel workers all share `127.0.0.1`) and
  must never be set in production.
- **Breach blocklist**: `haveIBeenPwned` plugin, k-anonymity (first 5 SHA-1
  chars only leave the server), free, no key. Fails open on a HIBP outage,
  never fails open on a match.
- **Enumeration safety**: sign-in, sign-up and password reset all return
  generic messages. Sign-up is enumeration-safe only because
  `emailAndPassword.requireEmailVerification` is derived true whenever an
  email provider is configured.
- **CSRF / callbacks**: `trustedOrigins` is explicit absolute URLs only,
  never wildcards — the documented ATO bypass class
  (GHSA-vp58-j275-797x) targeted exactly a wildcard/scheme-less
  `callbackURL`, and staying patched (pinned to 1.6.25) is the control.
- **Security headers + CSP**: HSTS, `X-Content-Type-Options: nosniff`,
  `Referrer-Policy`, `X-Frame-Options: DENY`, and a per-request nonce CSP
  generated in Next's middleware layer.
- **CAPTCHA**: Cloudflare Turnstile on `/sign-up/email` (and, by the
  plugin's default, `/sign-in/email` and `/request-password-reset`).
- **`better-auth` is pinned to an exact version and never auto-bumped.** It
  has a track record of high-severity auth advisories
  (GHSA-vp58-j275-797x, GHSA-8jhw-6pjj-8723); a critical CVE is the one
  reason to move the pin, done deliberately with the gate re-greened, not
  via Dependabot (`.github/dependabot.yml` excludes it explicitly).
- **Encryption-at-rest**: AES-256-GCM is the primitive
  (`packages/db/src/crypto.ts`); the real exposure is key management — a
  single shared `PGCRYPTO_KEY` with no rotation path today. An
  envelope/versioned-key scheme (a key-id prefix on each ciphertext) would
  let a leaked key be rotated without a re-encryption outage; not built.

## Observability — not built

There is no metrics backend, no dashboard, and no alerting. Failures surface
as Vercel runtime logs and nothing watches them automatically. Concretely:
no failed-login-spike detector, no alert on a `BETTER_AUTH_SECRET` drift
(whose symptom is every session dying at once), no success-rate or
error-budget signal on any auth flow. This is a stated gap, not a described
plan — pick it up from `docs/roadmap.md` when it becomes real work.

## Threat model summary

The cross-cutting covered-vs-open matrix for the whole product (auth, privacy,
supply chain, secrets, repo process, observability) lives in
[`23-security-threat-model.md`](23-security-threat-model.md). Full actor and
control detail for authz/privacy also lives in the test suite and in code
comments (`packages/core/src/org-permissions.ts`,
`packages/core/src/privacy.ts`). Auth-stack headlines:

- **Opportunistic credential stuffing** is the highest-likelihood threat.
  Primary defence: the HIBP breach blocklist plus a 15-character minimum
  (arguably the single biggest lever), database-backed rate limiting, and
  2FA for privileged accounts.
- **One Postgres, many camps — isolation is 100% app-layer.** Every store
  query filters by `groupId`/`userId`; there is no database-level backstop
  (no row-level security). This is an accepted trade-off at the current
  scale, mitigated by a mandatory `requireMembership` funnel and adversarial
  cross-camp tests, not by RLS — Neon RLS gives nothing here because the
  app connects with an owner-equivalent role that bypasses RLS entirely;
  it would only earn its cost if an untrusted, non-server caller ever
  queried Postgres directly (the parked external `/v1` API, if built).
- **A compromised `god` (System manager) account** is the most severe
  single-account compromise: revoking sessions is not sufficient
  containment, because `GOD_EMAILS` grants god on first login — the
  affected email must also be removed from that list immediately, or a
  re-login silently re-grants god.

## What this deliberately does not build

- No stateless-JWT-only sessions (breaks revocation).
- No proxy/central-auth-server topology.
- No Postgres row-level security today (see above).
- No bundled local breach-password list (HIBP is free and current).
- No SMS 2FA (SIM-swap risk and per-message cost).
- No passkey-first or passkey-only sign-in.
- No device-held attestation keypairs yet — `profile_keys` exists but signs
  nothing; a server-held key cannot provide non-repudiation, so this waits
  for a per-device keypair design before any attestation flow ships.
- No custom cryptography — Better Auth, WebAuthn and TOTP standards only.
- No self-hosted secrets/HSM for the key-encryption key.

## Where this is enforced

`packages/auth` (config, env resolution), `packages/core/src/auth-capabilities.ts`
(the capability matrix — see [`02-accounts-and-account-security.md`](02-accounts-and-account-security.md)),
`packages/db/src/crypto.ts` (encryption). Tests:
`packages/auth/src/__tests__/*`, `apps/org/lib/__tests__/system-status.test.ts`.
