# Governance

How this project makes decisions, who holds what authority, and how that
changes over time. `CODE_OF_CONDUCT.md` governs behaviour; `CONTRIBUTING.md`
governs the day-to-day process of making a change; this file governs the
process itself and who is accountable for it.

## What this project is

The AfrikaBurn Theme Camp App ("Quagga Portal") is a volunteer-built,
open-source project. It is not official AfrikaBurn tooling unless and until
AfrikaBurn's organisation says so — see App Specification Decision 014
(governance, licensing and data-liability thresholds), which is still
`proposed` in the authoritative corpus at
`docs/sources/app-specification/decisions-record/`.

## Two kinds of decision

| Decision               | What it covers                            | Where it is recorded                                                                                                                                                                  | Who decides                  |
| ---------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| **Product (WHAT/WHY)** | What the app should do, for whom, and why | The App Specification and its Decision Records, synced from Superhuman to `docs/sources/app-specification/decisions-record/` (read-only in this repo — edit on Superhuman, then pull) | The AfrikaBurn working group |
| **Engineering (HOW)**  | How the product decision gets built       | `docs/decisions/` in this repo                                                                                                                                                        | The maintainers              |

**Nothing in this repository may assert a product position that opposes an
accepted App Specification section or Decision Record.** Where the repo's
current build gets ahead of an unaccepted (`proposed`) Decision Record — which
happens; shipping software sometimes has to pick a stance before the working
group has ratified one — that stance is described as the _current build
stance_, not as settled law, and it is expected to change if the Decision
Record resolves differently. `docs/technical-spec/` tracks these cases as
drift, with a pointer to the governing record.

## The neutrality rule

This is a shared, multi-camp platform. Camp names may appear as realistic
test fixtures and demo cast — that keeps the data pipeline honest — but **no
feature, default, or product decision may exist for the sole benefit of one
camp.** A camp getting a feature because it happens to be a convenient test
fixture is fine; a camp getting a feature because someone who works on the
project happens to run that camp is not, and should be flagged in review.

## Roles

- **Contributors** — anyone opening an issue or a pull request. No approval
  needed to become one.
- **Maintainers** — listed in `MAINTAINERS.md`. Review and merge pull
  requests, triage issues, and hold (or delegate) the infrastructure accounts
  below. Added or removed by consensus among existing maintainers.
- **Code owners** — `.github/CODEOWNERS`. A subset of maintainers whose
  review is required on the paths listed there. Currently root files,
  `.github/` and `LICENSE`; expected to widen (migrations, `packages/auth`,
  `packages/core`) as the maintainer team grows past one person.
- **Design owners** — approve changes to `design/ab-initial-app.pen` (see
  `AGENTS.md` §The design canvas). Named in `MAINTAINERS.md` once more than
  one exists; today the same as the maintainers.
- **The AfrikaBurn working group** — owns product decisions on Superhuman,
  independent of who maintains this repository.

## Branch protection

**Deliberately not enabled yet.** It turns on — required status check
(`CI pass`) plus code-owner review — once the open-source migration PR
sequence has landed and the repository is genuinely ready for outside
contribution. Until then, the branch-and-pull-request rule in `AGENTS.md`
and `CONTRIBUTING.md` is a convention the tooling does not enforce; follow it
anyway.

## Infrastructure and secret custody

The following are currently held by a single person and are expected to move
to organisation-owned accounts as part of the broader migration (tracked
separately from the code changes in this repository, since transferring an
account is not a pull request):

- Vercel projects (three apps) and their environment variables
- The Neon Postgres project and its API credentials
- The Resend account and sending domain
- The Vercel Blob store
- The Google OAuth client
- `BETTER_AUTH_SECRET` and `PGCRYPTO_KEY` (the latter encrypts SA ID/passport
  columns — losing it makes that ciphertext permanently unreadable)
- The in-app reporter's GitHub credential (moving to an org-owned machine
  user or GitHub App — see `MAINTAINERS.md`)
- The Superhuman/Coda workspace sync token for the App Specification corpus

**Rule going forward: at least two maintainers must be able to recover each
of the above**, and custody changes on maintainer departure. Record who holds
what in `MAINTAINERS.md`, not in code comments or chat history.

## Licensing

See the [Licence section of `README.md`](README.md#licence) and `LICENSE`
itself. The licence text and copyright notice are not changed by this
migration; changing the copyright holder is a product/legal decision for the
working group (App Specification Decision 014), not an engineering one.

**Footnote for legal review, not legal advice:** commits made between
23 and 27 July 2026 (`git log -- LICENSE`) were briefly published under MIT
before the switch to FSL-1.1-ALv2 — that grant is irrevocable for those
specific historical snapshots, independent of the licence any later commit
carries.

## Changing this document

`GOVERNANCE.md` changes by the same pull-request process as code, reviewed by
existing maintainers. Material changes (adding/removing a maintainer role,
changing the branch-protection policy, changing licensing terms) should be
called out explicitly in the pull request description.
