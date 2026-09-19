# Technical spec — index

| Field                  | Value                        |
| ---------------------- | ---------------------------- |
| **Category**           | Product                      |
| **Doc status**         | Active                       |
| **Normative language** | Descriptive only             |
| **Requirement IDs**    | N/A — index only             |
| **Owner / Updated**    | Repo maintainers, 2026-09-11 |

Downstream of the **App Specification** (`../sources/app-specification/`).
Everything here describes what is **built**, organized by feature rather
than by App Spec section — [`app-spec-coverage.md`](app-spec-coverage.md)
is the section-by-section mirror; this index is the feature-by-feature
map. Not everything in the App Spec is built, and not everything built has
its own document here yet — a doc exists for every feature that is
actually shipped. See [`../README.md`](../README.md) for the documentation
conventions every file here follows (metadata header, status glyphs,
Requirement-ID citation format).

## Feature index

| Doc                                                                                | Feature                                        | App Spec §/IDs    | Drift?                                  |
| ---------------------------------------------------------------------------------- | ---------------------------------------------- | ----------------- | --------------------------------------- |
| [`app-spec-coverage.md`](app-spec-coverage.md)                                     | Full App Spec mirror                           | all               | —                                       |
| [`00-architecture.md`](00-architecture.md)                                         | System architecture, packages, UI components   | `SEC-*`, `CORE-*` | —                                       |
| [`01-auth-and-identity.md`](01-auth-and-identity.md)                               | Auth platform (Better Auth), threat model      | §19 partial       | SEC-018 corrected                       |
| [`02-accounts-and-account-security.md`](02-accounts-and-account-security.md)       | Account self-service, security events          | §19, §4 partial   | SEC-020 partial (ID purge unscheduled)  |
| [`03-burner-bio-and-profiles.md`](03-burner-bio-and-profiles.md)                   | Onboarding, self-owned profile                 | §3, §4            | **Yes — Decision 008 (proposed)**       |
| [`04-camps-directory-invites-roster.md`](04-camps-directory-invites-roster.md)     | Camps, directory, invites                      | §4a partial       | —                                       |
| [`05-camp-roles-and-officers.md`](05-camp-roles-and-officers.md)                   | Custom roles, officer roles                    | §19 partial       | —                                       |
| [`06-registration-and-review.md`](06-registration-and-review.md)                   | Registration wizard + review loop              | §14, §16          | REG-013/015/020 corrected               |
| [`07-previous-year-carry-forward.md`](07-previous-year-carry-forward.md)           | Carry-forward and comparison                   | §15               | Rollover rule undecided                 |
| [`08-placement-codes-and-erf.md`](08-placement-codes-and-erf.md)                   | Staff-assigned erf/camp code                   | §11, §13          | **Yes — Decisions 011/012 (proposed)**  |
| [`09-exports-and-scheduled-jobs.md`](09-exports-and-scheduled-jobs.md)             | CSV export, deadline reminders, deletion sweep | §14 partial       | —                                       |
| [`10-questionnaire-engine.md`](10-questionnaire-engine.md)                         | Questionnaire builder + notification gates     | repo-extends-spec | —                                       |
| [`11-bulletins-and-notifications.md`](11-bulletins-and-notifications.md)           | Bulletins, notifications                       | §4a partial       | —                                       |
| [`12-suppliers.md`](12-suppliers.md)                                               | Supplier portal + org standing                 | §14, §16 partial  | —                                       |
| [`13-wranglers.md`](13-wranglers.md)                                               | Wrangler assignment                            | §19 partial       | —                                       |
| [`14-audit-trail-and-medical-access.md`](14-audit-trail-and-medical-access.md)     | Medical-notes consent, audit trail             | §19               | —                                       |
| [`15-camp-categories.md`](15-camp-categories.md)                                   | Directory taxonomy                             | repo-extends-spec | —                                       |
| [`16-org-permissions-and-system-panel.md`](16-org-permissions-and-system-panel.md) | Org roles v1, `/system`                        | §19 partial       | —                                       |
| [`17-org-status-board.md`](17-org-status-board.md)                                 | Org console landing page                       | repo-extends-spec | —                                       |
| [`18-in-app-reporter.md`](18-in-app-reporter.md)                                   | Bug reporter                                   | repo-extends-spec | Reporter identity — see `GOVERNANCE.md` |
| [`19-creative-projects.md`](19-creative-projects.md)                               | Artworks, mutant vehicles                      | §18               | —                                       |
| [`20-payment-reference-tracking.md`](20-payment-reference-tracking.md)             | Payment reference tracking                     | §8                | **Yes — Decision 009 (proposed)**       |
| [`21-gis-spatial-data-research.md`](21-gis-spatial-data-research.md)               | GIS / spatial-data research (not built)        | — (research)      | Decisions 011, 012, 016 (proposed)      |
| [`22-afrikaburn-tmi-identity-research.md`](22-afrikaburn-tmi-identity-research.md) | AfrikaBurn TMI Identity research (not built)   | — (research)      | Decision 002 (proposed)                 |

## Drift register (summary)

A feature doc's Drift section is the source of truth; this table just
points at the ones that carry one:

| Where       | App Spec area                                          | Governing Decision Record                                                         |
| ----------- | ------------------------------------------------------ | --------------------------------------------------------------------------------- |
| §03         | Self-owned Burner Bio vs. admin-managed camper records | Decision 008 (proposed)                                                           |
| §06/§14/§16 | REG-013/015/020 previously overstated                  | (correction only, no decision needed)                                             |
| §08         | Placement/layout tooling deferred                      | Decisions 011, 012, 016 (proposed)                                                |
| §20         | No payment gateway                                     | Decision 009 (proposed)                                                           |
| —           | Ticketing stays with Quicket                           | Decision 010 (proposed)                                                           |
| —           | First demonstrable slice (App Spec §1/§20)             | Decision 004 (accepted, not yet honoured) vs. Decision 013 (rebaseline, proposed) |

Product positions elsewhere in this repo (`AGENTS.md`, `docs/roadmap.md`)
should cite these same records rather than asserting a scope decision on
their own authority — see `GOVERNANCE.md`.

## Building a new doc here

Every built feature not yet listed above gets its own file, using this
template:

```markdown
# <Feature>

<metadata header — see ../README.md>

## Implements (App Specification)

| App Spec § | IDs | Status | Notes |

## Drift

> ⚠️ (only if the repo's position opposes an unaccepted Decision Record
> or an accepted one it doesn't honour)

## How it is built

## Flow

## Invariants and tests
```

Not every App Spec requirement needs a doc — only what is actually built.
An unbuilt requirement is tracked in [`app-spec-coverage.md`](app-spec-coverage.md)
alone.
