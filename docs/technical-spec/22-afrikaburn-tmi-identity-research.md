# AfrikaBurn TMI Identity research

| Field                  | Value                                                              |
| ---------------------- | ------------------------------------------------------------------ |
| **Category**           | Planning                                                           |
| **Doc status**         | Draft                                                              |
| **Normative language** | Descriptive only                                                   |
| **Requirement IDs**    | N/A — external-identity research, not spec-derived                 |
| **Owner / Updated**    | Beyers Nel, 2026-09-19                                             |

Research notes on AfrikaBurn's production identity platform (**TMI Identity**),
as shared into the Theme Camp App WhatsApp Group Chat (2026-09-17) by Graeme
Allan (relaying org material). This is **not** a built-feature spec and is
**not** an engineering HOW decision yet.

Operational product implications live in App Spec
[Decision 002](https://github.com/afrikaburn-theme-camp-app/ab-tc-app/blob/main/docs/sources/app-specification/decisions-record/decision-002-proposed-architecture-integration-strategy-open-pending-org-feedback.md)
(architecture / org-integration posture — still `proposed`). The Theme Camp
App's current auth stack is documented in
[`01-auth-and-identity.md`](01-auth-and-identity.md) (Better Auth) and is
separate from this research until an integration path is agreed.

## What TMI Identity is (as described)

- AfrikaBurn's **production identity platform**: one AfrikaBurn account across
  TMI and future connected applications.
- Stated stack components:
  - **Keycloak** for authentication and single sign-on
  - Existing AfrikaBurn **LDAP** directory as the authoritative source of
    participant identities and passwords (Keycloak treats LDAP as
    **read-only**)
  - **PostgreSQL** for TMI's own identity data
  - Transactional email via **Amazon SES**
  - AfrikaBurn-branded login experiences
- Stated hardening posture: disables uncontrolled registration and password
  reset; avoids broad container or Internet access; private administration;
  tightly restricted network access.
- Sign-in surface named: `login.afrikaburn.net`.

## Intended integration boundary (for external apps)

Per the org description shared in chat:

- Applications **must not** integrate directly with LDAP, PostgreSQL, or the
  Keycloak database.
- The standards-based boundary is **OIDC / OAuth 2.0**: the application becomes
  a Keycloak client; users sign in at `login.afrikaburn.net`; the application
  receives signed identity / access tokens.
- Any language/framework with a competent OpenID Connect client library can
  participate.
- The named conversation for anyone building against AfrikaBurn's backend is
  with **Havon** (org IT — spelling **verify**), Graeme Allan, and the
  developer responsible for that application.

## Related repositories (as named)

| Repo | Role (as described) |
| ---- | ------------------- |
| [AfrikaBurn/TMI](https://github.com/AfrikaBurn/TMI) | Conceptual modular community-building platform ("Tribe Mobilization Infrastructure"; described as made before AI). |
| `AfrikaBurn/TMI-Identity` | Core identity module; described as **live and running**, **private**, and shareable only after an **NDA** (security-sensitive). |

Do not assume public access to `TMI-Identity`. Do not scrape or republish its
internals here.

## Implications for the Theme Camp App (research only)

- A plausible org-alignment path is: Theme Camp App (or a dedicated auth
  bridge) as an **OIDC client** of TMI Identity, rather than inventing a
  parallel "Login with AfrikaBurn" identity store.
- That does **not** decide whether Better Auth remains the Theme Camp App's
  session layer, becomes a bridge, or is replaced — that is an engineering
  HOW decision for later (`docs/engineering-decisions/`), after org
  confirmation.
- Until Havon (and related IT) alignment happens, Decision 002 stays
  `proposed`. This document records what the org says exists; it does not
  ratify adoption.

## Sources

- WhatsApp Group Chat (2026-09-17) — Graeme Allan, posting AfrikaBurn TMI /
  TMI Identity descriptions and integration guidance.
- Related operational discussion: [2026-09-17 dev alignment](../sources/app-specification/meeting-minutes/2026-09-17-dev-alignment.md)
  (Havon meeting to be scheduled via Tim Doyle).

## Open questions

- Formal confirmation from Havon / AfrikaBurn IT that the chat description is
  current and accurate for third-party clients.
- NDA / access process for `TMI-Identity` if the Theme Camp App team needs more
  than the public OIDC boundary description.
- How Theme Camp App accounts (Better Auth today) map to AfrikaBurn LDAP /
  TMI identities (link, migrate, or dual-run).
- Spelling / exact role of **Havon** (**verify**).
