# Security threat model

| Field                  | Value                                                                                                                                                          |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Category**           | Security                                                                                                                                                       |
| **Doc status**         | Draft                                                                                                                                                          |
| **Normative language** | Descriptive only — this document reports covered vs open vectors; it does not itself impose new product requirements                                           |
| **Requirement IDs**    | Partial — `SEC-*` (cross-cutting register; per-feature detail lives in sibling Security docs and is not re-audited here for App Spec completeness)             |
| **Owner / Updated**    | Repo maintainers, 2026-09-20 (C6: Aikido Safe Chain)                                                                                                                       |

Cross-cutting threat register for the **live** product: what can go wrong,
what already stands in the way, and what is still open. Auth architecture and
account controls live in
[`01-auth-and-identity.md`](01-auth-and-identity.md) and
[`02-accounts-and-account-security.md`](02-accounts-and-account-security.md);
medical access and audit in
[`14-audit-trail-and-medical-access.md`](14-audit-trail-and-medical-access.md);
POPIA / incident runbooks in
[`../compliance-and-incident-response.md`](../compliance-and-incident-response.md);
compromised-package runbook in
[`../supply-chain-incident-response.md`](../supply-chain-incident-response.md);
contributor reporting and repository settings in
[`../../SECURITY.md`](../../SECURITY.md).

This file is the **matrix**, not a second source of truth for any one control.
When a row and a sibling doc disagree, the sibling feature doc wins on the
control; this matrix should be updated to match.

## Scope and out of scope

**In scope:** the three deployed apps (`web`, `org`, `suppliers`), the shared
packages they run (`@quagga/{auth,core,db,ui,types}`), the GitHub repository
and CI that ship them, and the Neon / Vercel / Resend / Blob operators they
depend on.

**Out of scope here (pointed, not ignored):**

- The Draft `/v1` API / SDK delegation surface — threat actors and controls
  are specified under [`../sdk/delegation/`](../sdk/README.md) and are
  **not built**. Rows that would only apply once that ships are marked
  **Deferred** below.
- Physical / on-site device compromise beyond what the apps can enforce.
- AfrikaBurn organisational process outside this repository (staff vetting,
  playa radio, Quicket).

## Coverage legend

These four labels are **local to this matrix**. They are not the
repo-wide ✅🚧❌⚠️ build glyphs (`../README.md` §status-symbol legend).

| Coverage        | Meaning                                                                                          |
| --------------- | ------------------------------------------------------------------------------------------------ |
| **Covered**     | A real control exists in code, config, or enforced process, and is the intended primary defence  |
| **Partial**     | A control exists, but a named gap remains (incomplete enforcement, no alert, policy not wired)   |
| **Open**        | No adequate control yet; residual risk is not deliberately accepted                              |
| **Accepted**    | Residual risk is known and consciously accepted at current scale (revisit when scale or surface changes) |
| **Deferred**    | Threat only becomes real when an unbuilt surface ships; tracked elsewhere                        |

Likelihood / impact are coarse (`L` / `M` / `H`) relative to this product —
real people, real PII, no staging — not a formal FAIR model.

## Actors

| Actor                         | Intent / capability                                                                 |
| ----------------------------- | ----------------------------------------------------------------------------------- |
| Internet stranger             | Credential stuffing, scraping, probing public surfaces                              |
| Authenticated burner          | Cross-camp reads, privilege confusion, invite abuse                                 |
| Camp lead / admin             | Over-reach within or across camps; bulk personal-data exposure                      |
| Org staff / `god`             | Highest console authority; misconfiguration or account takeover                     |
| Compromised dependency / CI   | Malicious package, poisoned Action, leaked workflow secret                          |
| Operator with env access      | Vercel / Neon / GitHub maintainer holding production secrets                        |
| Future integrator (`/v1`)     | Key + ticket abuse — **Deferred** until Decision 005 / SDK work ships               |

---

## Threat matrix

### A — Authentication and account takeover

| ID  | Threat                                      | L / I | Coverage  | Primary controls                                                                                         | Residual / open                                                                 |
| --- | ------------------------------------------- | ----- | --------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| A1  | Credential stuffing / password reuse        | H / H | Covered   | HIBP breach blocklist; ≥15-char passwords; DB-backed rate limits                                         | No failed-login spike alerting (see O1)                                         |
| A2  | Session theft (cookie / XSS)                | M / H | Partial   | DB sessions + revocation; short cookie cache; HttpOnly cookies                                           | No CSP/XSS threat doc here; cookie-cache window honours revoked sessions briefly |
| A3  | Account takeover without 2FA                | M / H | Partial   | TOTP + passkeys + backup codes available; lockout on 2FA verify                                          | 2FA not mandatory for all accounts; privileged-account policy is social         |
| A4  | User enumeration on auth endpoints          | M / L | Covered   | Generic messages on sign-in / sign-up / forgot-password                                                   | —                                                                               |
| A5  | SIM-swap via SMS 2FA                        | — / — | Accepted  | SMS 2FA deliberately not offered                                                                         | Authenticator / passkey only                                                    |
| A6  | `BETTER_AUTH_SECRET` drift across apps      | L / H | Open      | Manual shared secret across three Vercel projects                                                        | No automated drift alert; silent mass logout is the symptom                     |
| A7  | `god` re-grant after containment            | L / H | Partial   | Session revoke; `GOD_EMAILS` must also be edited                                                         | Easy to miss the env list during an incident                                    |

Detail: [`01-auth-and-identity.md`](01-auth-and-identity.md),
[`02-accounts-and-account-security.md`](02-accounts-and-account-security.md).

### B — Authorization, privacy, and personal data

| ID  | Threat                                           | L / I | Coverage  | Primary controls                                                                                                      | Residual / open                                                                 |
| --- | ------------------------------------------------ | ----- | --------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| B1  | Cross-camp data read (app-layer isolation only)  | M / H | Accepted  | `requireMembership` / group filters; adversarial cross-camp tests; no Postgres RLS (owner role would bypass it)       | One Postgres, many camps — isolation is 100% application code                   |
| B2  | Hard-locked PII in public projections            | M / H | Covered   | `HARD_LOCKED_PRIVATE_FIELDS` in `@quagga/core`; server predicates; no reveal path                                     | —                                                                               |
| B3  | Medical notes bulk / casual exposure            | M / H | Covered   | `canViewMedicalNotes`; detail-only; audience label as consent; encrypt at rest                                        | Audit write fails open (deliberate — see B4)                                    |
| B4  | Undetected medical disclosure (audit drop)       | L / M | Accepted  | `audit_events` via `after()`; emergency read must not block on log                                                    | Silent missed audit row possible under serverless/DB blip                       |
| B5  | Org staff over-collection / enumeration          | M / M | Accepted  | No volume/alerting on medical reads (monitoring ban); detail-only surfaces                                            | Relies on organisational trust + audit reconstruction after the fact            |
| B6  | UI hiding treated as the security boundary       | M / H | Covered   | Authz predicates live in `@quagga/core`, enforced server-side                                                         | Contributor discipline — see `SECURITY.md`                                      |
| B7  | ID / passport retention unbounded in practice    | M / M | Partial   | Encryption; retention rule in code (`id-retention.ts`)                                                                | Purge has **no scheduled caller** — ciphertext accumulates (SEC-020)            |
| B8  | Free-camp discovery by strangers                 | M / L | Covered   | Directory / type-ahead / profile visibility rules                                                                     | Repo-built rule; Decision Record still desirable before treating as permanent   |
| B9  | Org permission model self-escalation             | L / H | Covered   | `god` resolves all; `manage_accounts` refused by resolver; System panel gated                                         | Lockout tests in `org-role-lockout.test.ts`                                     |

Detail: [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md),
[`14-audit-trail-and-medical-access.md`](14-audit-trail-and-medical-access.md),
[`16-org-permissions-and-system-panel.md`](16-org-permissions-and-system-panel.md).

### C — Supply chain and build integrity

| ID  | Threat                                      | L / I | Coverage  | Primary controls                                                                                          | Residual / open                                                                 |
| --- | ------------------------------------------- | ----- | --------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| C1  | Malicious or compromised npm package        | M / H | Partial   | Committed `pnpm-lock.yaml`; CI `pnpm install --frozen-lockfile`; pinned `packageManager`; Aikido Safe Chain on CI + documented local install | Safe Chain only wraps installs that use its shim — a contributor who skips local setup is unprotected until CI |
| C2  | Auto-bump of high-risk auth dependency      | M / H | Covered   | `better-auth` exact pin `1.6.25`; Dependabot `ignore`; manual CVE watch                                   | Human patch latency on a critical GHSA                                          |
| C3  | Unreviewed dependency drift (general)       | M / M | Partial   | Weekly Dependabot (npm + Actions); minor/patch grouping; `react-slot` ignored                             | No severity-based merge gate (OSV / SCA fail-on-PR); auto-merge deliberately off |
| C4  | Compromised GitHub Action                   | L / H | Partial   | Dependabot for `github-actions`; workflow `permissions: contents: read` by default                        | Actions not pin-hashed; no separate Action allowlist                            |
| C5  | Lockfile / SBOM invisible to auditors       | L / L | Open      | Lockfile is the inventory today                                                                           | No SBOM artefact generated or retained in CI                                    |
| C6  | Typosquat / brand-new malicious publish     | L / H | Covered   | Aikido Safe Chain (malware intel + 48h minimum package age); `scripts/install-safe-chain.sh`; `.aikido`; CI `--ci` before every `pnpm install`; Dependabot `cooldown.default-days: 2` on npm + Actions; CI canary `scripts/verify-safe-chain.sh` (`safe-chain · malware canary` in `CI pass`) | Local protection requires one-time `./scripts/install-safe-chain.sh` + shell restart; Dependabot cooldown is days-not-hours and applies to the **direct** bump only — young transitives can still land in the lockfile and are blocked by Safe Chain on install |

Config: [`.github/dependabot.yml`](../../.github/dependabot.yml),
[`../../SECURITY.md`](../../SECURITY.md), `AGENTS.md` pin list,
[`../../scripts/install-safe-chain.sh`](../../scripts/install-safe-chain.sh),
[`../../scripts/verify-safe-chain.sh`](../../scripts/verify-safe-chain.sh)
(CI job `safe-chain · malware canary`),
[`.aikido`](../../.aikido).

### D — Secrets, keys, and configuration

| ID  | Threat                                         | L / I | Coverage  | Primary controls                                                                 | Residual / open                                              |
| --- | ---------------------------------------------- | ----- | --------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| D1  | Secret committed to the public repo            | M / H | Partial   | Contributor rule; GitHub secret scanning + push protection (recommended settings) | Branch protection / settings are maintainer-operated, not code |
| D2  | `PGCRYPTO_KEY` leak / no rotation              | L / H | Partial   | AES-256-GCM at rest; single shared key                                           | No envelope / key-id rotation path; POPIA has no crypto safe-harbour |
| D3  | Production probed as “staging”                 | H / H | Covered   | No staging by design; `SECURITY.md` + `AGENTS.md` forbid live testing; local `e2e:local` | Social / process control — cannot be enforced by the apps alone |
| D4  | Pooled DB URL used for advisory-locked migrate | L / H | Covered   | Migrator requires `DATABASE_URL_UNPOOLED`; aborts on pooler host                 | —                                                            |
| D5  | Env-less boot crash / secret required at build | L / M | Covered   | All three apps boot to graceful “not configured” without env                     | —                                                            |

### E — Repository process and change control

| ID  | Threat                                      | L / I | Coverage  | Primary controls                                                                 | Residual / open                                                                 |
| --- | ------------------------------------------- | ----- | --------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| E1  | Direct push / unreviewed merge to `main`    | M / H | Open      | Convention: branch + PR; `CODEOWNERS` file exists                                | Branch protection **not enabled** — CODEOWNERS is inert until it is             |
| E2  | Hand-written migration breaks generator / prod | M / H | Partial | Rule: edit `schema.ts`, `db:generate`, commit snapshot; deploy-time migrate      | Social enforcement; damage is cumulative if broken                              |
| E3  | CI permissions over-broad                   | L / M | Covered   | Default `contents: read` on workflows                                            | Individual jobs may elevate; review on change                                   |
| E4  | Public issue leaks PII from in-app reporter | M / M | Partial   | Pattern-based redaction; no reporter identity on issue                           | Redaction fails open; diagnose before quoting (`docs/triage.md`)                |

### F — Runtime observability and incident detection

| ID  | Threat                                      | L / I | Coverage  | Primary controls                    | Residual / open                                                                 |
| --- | ------------------------------------------- | ----- | --------- | ----------------------------------- | ------------------------------------------------------------------------------- |
| F1  | Auth abuse / secret drift unnoticed         | H / H | Open      | Vercel runtime logs only            | No metrics, dashboards, or alerting (`01-auth` §Observability)                  |
| F2  | Medical-access misuse as “monitoring”      | — / — | Accepted  | Explicitly **no** volume alerting   | Reconstruction via `audit_events` after an incident report                      |
| F3  | No documented DB restore runbook            | L / H | Open      | Neon PITR exists operationally      | SEC-018 — no backup/restore procedure in this repo                              |

### G — Surfaces not yet built

| ID  | Threat                                      | L / I | Coverage  | Primary controls (spec only)                                                      | Residual / open                                      |
| --- | ------------------------------------------- | ----- | --------- | --------------------------------------------------------------------------------- | ---------------------------------------------------- |
| G1  | `/v1` key used as a principal               | — / — | Deferred  | Ceiling ∩ live end-user ∩ consent; no caller-supplied subject id                  | Not built — Decision 005 / `docs/sdk/delegation/`    |
| G2  | Delegated medical read without audit UX     | — / — | Deferred  | Spec requires burner-facing audit reader before medical scope                     | Blocking prerequisite named in `SECURITY.md`         |
| G3  | Payment gateway / card data                 | — / — | Deferred  | Platform does not hold money today (Decision 009 proposed)                        | Out of threat surface until that Decision moves      |

---

## Summary — covered vs still open

### Covered (primary defence in place)

A1, A4, A5†, B2, B3, B6, B8, B9, C2, C6, D3, D4, D5, E3, F2†

† Accepted residual risk by design (no SMS 2FA; no medical-volume monitoring).

### Partial (control exists; named gap)

A2, A3, A7, B4†, B5†, B7, C1, C3, C4, D1, D2, E2, E4

† B4/B5 are also **Accepted** trade-offs; listed Partial because the residual is real.

### Open (needs work or a maintainer setting)

| ID  | One-line gap                                              | Likely next step                                              |
| --- | --------------------------------------------------------- | ------------------------------------------------------------- |
| A6  | No `BETTER_AUTH_SECRET` drift detection                   | Alert or boot-time cross-app check                            |
| C5  | No SBOM in CI                                             | Generate CycloneDX/SPDX from the lockfile on `main` builds    |
| E1  | Branch protection off → CODEOWNERS inert                  | Enable as in `SECURITY.md` §Repository settings               |
| F1  | No auth/ops alerting                                      | Minimal failed-login + secret-drift signals                   |
| F3  | SEC-018 restore procedure undocumented                    | Short Neon PITR note in `docs/deploy.md`                      |

Plus the **Open** half of Partial rows that matter most in production: **B7**
(ID purge caller), **C3** (SCA severity gate beyond Dependabot + Safe Chain).

### Deferred

G1–G3 — do not build controls in the live apps “just in case”; implement with
the surface that creates the threat.

---

## Relationship to other docs

| Concern                         | Authoritative doc                                                                 |
| ------------------------------- | --------------------------------------------------------------------------------- |
| Auth stack & methods            | [`01-auth-and-identity.md`](01-auth-and-identity.md)                              |
| Account self-service            | [`02-accounts-and-account-security.md`](02-accounts-and-account-security.md)       |
| Medical + audit                 | [`14-audit-trail-and-medical-access.md`](14-audit-trail-and-medical-access.md)     |
| Org capabilities / lockout      | [`16-org-permissions-and-system-panel.md`](16-org-permissions-and-system-panel.md) |
| POPIA + incident response       | [`../compliance-and-incident-response.md`](../compliance-and-incident-response.md) |
| Compromised package runbook     | [`../supply-chain-incident-response.md`](../supply-chain-incident-response.md)     |
| Reporting & repo settings       | [`../../SECURITY.md`](../../SECURITY.md)                                          |
| `/v1` threat → control matrix   | [`../sdk/delegation/03-security-measures.md`](../sdk/delegation/03-security-measures.md) (Draft, unbuilt) |

## How to update this matrix

1. When a control ships or a gap closes, change the row’s **Coverage** and
   shrink **Residual / open** — do not leave stale “Open” rows.
2. When a new surface ships (especially anything under `/v1`), add rows or
   move Deferred → Open/Partial/Covered in the same PR as the feature.
3. Do not use this file to invent product policy. Product positions stay in
   the App Spec / Decision Records; this file only tracks engineering risk
   against what is built.

## Implements (App Specification)

| App Spec §                   | IDs                          | Status | Notes                                                                 |
| ---------------------------- | ---------------------------- | ------ | --------------------------------------------------------------------- |
| §19 Permissions and security | SEC-013–SEC-021 (as relevant)| 🚧     | Cross-cutting register; per-ID status remains in sibling feature docs |
