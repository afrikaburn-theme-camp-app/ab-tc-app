<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
    e.g. fix(web): exclude sanitized accounts from the anti-lockout counts
Scopes are workspace names without the @quagga/ prefix: web · org · suppliers ·
core · db · ui · auth · types · e2e · repo. Several: fix(web,org): … · none: repo.
Add ! before the colon for a breaking change: feat(db)!: …

This file is a ROUTER only. Pick a typed template below (or via gh):
  gh pr create --body-file .github/PULL_REQUEST_TEMPLATE/<type>.md
The typed template is the fill-in source of truth (App Spec modes, sections).
-->

## Pick a PR template

GitHub does not offer a PR template chooser. Click the type that matches this
change — the compare page reloads with that body. Then fill **Summary** yourself;
leave the single agent blockquote after it for the agent (see CONTRIBUTING.md).

- [Feature](?expand=1&template=feature.md) — new user-visible behaviour · prove **Implements** + who is affected
- [Fix](?expand=1&template=fix.md) — correcting broken behaviour · prove the bug is real (**Regression proof**)
- [Database](?expand=1&template=database.md) — `schema.ts` / generated migration · prove production-safe migrate path
- [Security](?expand=1&template=security.md) — auth, sessions, privacy, authz · prove the **server** boundary
- [Docs](?expand=1&template=docs.md) — specs / process · prove **Modifies** (north star) or document against it
- [Chore](?expand=1&template=chore.md) — deps, CI, tooling · prove behaviour is unchanged (**Exempt**)

If none fit, use **Feature** or **Chore** and say so under Notes for the Reviewer.
