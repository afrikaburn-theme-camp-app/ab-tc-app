# Build Spec — the engineering contract

| Field                  | Value                                                                                                                                                 |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Category**           | Engineering Spec                                                                                                                                      |
| **Doc status**         | Active                                                                                                                                                |
| **Normative language** | RFC 2119 / RFC 8174 applies                                                                                                                           |
| **Requirement IDs**    | Partial — `CORE-*`, `CDB-*` (the engineering contract implements requirements scattered across many App Spec sections; not individually audited here) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                                                                                          |

The engineering contract: hard constraints, monorepo layout, environment
variables, the frozen schema, seeding rules, and what is explicitly not
built. The **App Specification** (external, authoritative — see
[`README.md`](README.md)) governs what the product should do; where any
other document in this repo conflicts with this file on engineering HOW,
this file wins; `GOVERNANCE.md` and `CONTRIBUTING.md` govern process.

**Feature-specific content that used to live here has moved to
[`docs/technical-spec/`](technical-spec/README.md)** — routes, the org
permissions model and System panel, Burner Bio v3 fields, camp categories,
the org stats dashboard, and notifications/bulletins each now have their
own doc there, cross-referenced from this file where the schema still
lives. What remains here is the residue: constraints and facts that don't
belong to one feature.

## Hard constraints

1. **Migrations are generated offline, committed append-only, and applied by the
   build at deploy time** (AGENTS.md §1 states this at length). `db:generate` produces the file offline from `schema.ts`; every app's
   `build` then runs `db:migrate:deploy` before `next build`. That runner takes a
   Postgres session advisory lock on the **unpooled** connection (`DATABASE_URL_UNPOOLED`)
   so three concurrent Vercel builds serialise, and it **aborts rather than falling
   back to a pooled URL** — session advisory locks do not hold on PgBouncer. It also
   **bootstraps reference data when `editions` is empty**, so a fresh database comes up
   usable; it is a bootstrap, not a sync, and never re-asserts rows over an organiser's
   edits. A migration MUST NOT be hand-edited, regenerated, or applied by a
   person against production.
2. Package namespace **`@quagga/`**. Node ≥ 22, pnpm 10, Turborepo.
3. Stack: Next.js 16 App Router, React 19, Tailwind v4, shadcn/ui, Drizzle + Neon (HTTP driver in handlers, pooled for scripts), **self-hosted Better Auth 1.6.25** mounted per app from `@quagga/auth` at `/api/auth/[...all]` (managed Neon Auth was removed — migration 0013), Resend for email, Vercel Blob for uploads.
4. Apps MUST boot without env/DB to a landing page (graceful "not configured" state); DB-backed routes MAY error clearly but MUST NOT crash the build.
5. Schema below is **frozen** — feature agents MUST NOT add/alter tables. `packages/db/src/schema.ts` is the single source of truth; migrations are generated, append-only, never hand-edited.
6. TypeScript strict; Zod validation at every boundary; no `any` in committed code. Vitest for core logic. CI gate: `pnpm turbo run lint typecheck test build`.
   6b. **Prebuilt components SHOULD be preferred over hand-rolling.** For any solved UI problem (phone inputs, date pickers, comboboxes, OTP fields…), use an existing package — preferably from the shadcn ecosystem/registry — and restyle it to our tokens. Hand-rolling complex, already-solved components is a defect. Bio field spec: years-attended is a multi-select of specific years (2007–2026, 2020/21 disabled "no burn"); phone uses an international phone input with country selector; emergency contacts are TWO (on-site + off-site), each with separate name and number fields, all hard-locked private.
7. UI: **"Tankwa Night"** — brand colours sampled from the afrikaburn.org Elementor kit. Dark-mode-first app shell dressed in AfrikaBurn's real brand colours; light supported via a `.light` class on `<html>`.
   - **Brand ramp** (raw, usable directly as e.g. `text-ab-teal`): teal `#2D7696`, teal-deep `#235C75`, apricot `#F4B672`, peach `#FFBC7D`, sage `#B6D090`, olive `#7D9953`, charcoal `#333333`, warm white `#FFFAF2`.
   - **Dark semantic tokens (default):** background `#17191B`, foreground `#F4F0E8`, card/popover `#1F2326`, muted `#262B2F`, muted-foreground `#ADB6B3`, border/input `#323A3F`, primary `#2D7696` (fg `#F4F0E8`), secondary `#26333B` (fg `#DCE8ED`), accent `#F4B672` (fg `#17191B`), ring `#2D7696`, destructive `#C24438` (fg `#F4F0E8`), success `#B6D090` (fg `#17191B`), warning `#F4B672` (fg `#17191B`). `--radius` `0.5rem`.
   - **Light (`.light`):** background `#FFFAF2`, foreground `#333333`, card/popover `#FFFFFF`, muted `#F1E9DB`, muted-foreground `#6E6558`, border/input `#E5DBC9`, primary `#2D7696` (fg `#FFFAF2`), secondary `#EAF0F3` (fg `#235C75`), accent `#F4B672` (fg `#333333`), ring `#2D7696`, destructive `#B23A2E`, success `#7D9953` (fg `#1F2A12`), warning `#D98A2B` (fg `#332006`) — dark foregrounds on the mid-tone fills because white text fails WCAG AA on them.
   - **`.org-accent` skin** (org app applies it on `<html>` alongside the theme): primary → `#F4B672` (fg `#17191B`), ring → `#F4B672`; in `.light.org-accent` primary → `#D98A2B` (fg `#332006`, dark for AA) — so the console's interactive colour is apricot, the participant app's teal.
   - **Status mapping:** approved → success (sage), changes_requested → warning (apricot), rejected → destructive, submitted/under_review → primary (teal), draft → muted/outline.
   - **Typography:** Montserrat via `next/font/google` (weights 500/600/700/800, `--font-brand`, display swap). Body 500; `@layer base` treats `h1,h2` as 800 UPPERCASE (`letter-spacing 0.01em`) and `h3` as 700.
   - **Identity motif:** `QuiltBand` — a repeating band of brand-triad diamonds on each app-shell header top edge, spanning the **full page width edge-to-edge**, plus landing/auth dividers. **The real AfrikaBurn logo and San-hand emblem are approved for use** (assets in `design/brand/`): nav carries the 282×40 wordmark banner; favicons MAY adopt the emblem (current original diamond favicons remain until swapped). Photography of identifiable people MUST NOT be used.
   - Non-corporate, warm, no lorem ipsum anywhere — realistic copy.

## Monorepo layout

```
apps/
  web/        participant app   (port 3000, teal)
  org/        org/admin console (port 3001, apricot) — separate deployment, own auth gate
  suppliers/  supplier portal   (port 3002, sage)   — separate deployment
packages/
  auth/   self-hosted Better Auth config, mounted by all three apps (@quagga/auth)
  ui/     shared shadcn components + tailwind tokens (@quagga/ui)
  db/     drizzle schema + append-only migrations + the deploy migrator (@quagga/db)
  core/   shared domain logic + every authz predicate (@quagga/core)
  types/  zod schemas + shared types (@quagga/types)
  eslint-config/  typescript-config/
e2e/      Playwright persona suite (@quagga/e2e) — run by `pnpm e2e:local`, never by the unit gate
```

**Local stack.** `docker-compose.local.yml` runs Postgres 16 plus _two_ Neon proxies
(SQL-over-HTTP and WebSocket) because `@neondatabase/serverless` uses both protocols
and no single proxy implements them. `NEON_LOCAL_PROXY=1` points both drivers at it.
`pnpm e2e:local` brings that up from cold, migrates, seeds, boots all three apps and
runs the persona suite.

## Environment variables (`.env.example` at root; all OPTIONAL for boot)

`DATABASE_URL`, `DATABASE_URL_UNPOOLED`, `BETTER_AUTH_SECRET` (self-hosted Better
Auth — identical on all three apps), `BETTER_AUTH_URL` (per app),
`BETTER_AUTH_REQUIRE_EMAIL_VERIFICATION` (OPTIONAL override),
`AUTH_RATE_LIMIT_WINDOW_SECONDS` / `AUTH_RATE_LIMIT_MAX` (OPTIONAL — RAISE the limiter's
ceiling for a test deployment; leave unset in production), `GOOGLE_CLIENT_ID`,
`GOOGLE_CLIENT_SECRET`, `RESEND_API_KEY`, `GOD_EMAILS` (comma list — grants god on
first login to a VERIFIED address), `BLOB_READ_WRITE_TOKEN`, `PGCRYPTO_KEY`. Update
turbo.json `globalEnv` in the same change. **The org console's `/system`
page reports the resolved state of every one of these** — set or unset, and what follows —
without ever printing a value.

## Schema (frozen)

- `users` — auth join (`auth_user_id`), email, created_at, `sanitized_at` tombstone,
  and **`username`** (migration 0016). Minimal; no role columns.

  **The username is the burner's one public handle**: account-level, optional, 3–20
  chars, unique on `lower(username)`. It is an alias, never a root identity. It does
  NOT live on `burner_bios.display_name` — bios are per-edition, so a handle there
  would let one person hold a different name every year and "unique" would mean
  nothing. All rules live once in `@quagga/core` `username.ts`: charset, the reserved
  list (`admin`/`afrikaburn` MUST NOT be claimed, and a route segment MUST NOT be shadowed), and the
  neutral `UNNAMED_BURNER` fallback — which is never a legal name and never an email,
  since both are private by default and either as a fallback would be a privacy
  incident.

  Consequently **`isBioComplete` keys on `burner_bios.completed_at`** — the burner
  reached the end of the flow and saved — not on any name. Completion is an act, not
  a filled field; no field inside the bio is REQUIRED. _(Marked PROVISIONAL at its
  definition: if a real identity anchor is ever wanted, it is the legal name, since
  the ID/passport exist to match a person to their ticket. Do not invent a third
  field.)_

- `burner_bios` — user × edition. Field set based on an earlier single-camp implementation's burner profile pattern[^1] + `privacy_flags` jsonb (per-field public/private). **Always-private fields** (`id_number`, `passport_number`, phone, emergency contact, medical): enforced in `@quagga/core` — flags for these MUST NOT be set public, ever. pgcrypto-encrypt id/passport **and medical** columns. Two classes (see `docs/technical-spec/03-burner-bio-and-profiles.md` §Privacy classes): the first four are _hard-locked_ with no access path; **medical is _safety-visible_** — MUST NOT be public, but MAY be visible to the burner's own camp leads and org staff on a member DETAIL view (consented at entry via the field's label, audited on read, MUST NOT appear in lists or exports).
- `profile_keys` — user_id, public_key, encrypted_private_key, created_at. Generated server-side at onboarding; used for nothing yet except future QR attestations.
- `groups` — kind enum (`org|theme_camp|artwork|mutant_vehicle`), name, `name_normalized` (unique per kind, case/space/punct-insensitive), description (60-word limit for camps), joinability enum (`open|invite_only`), `visibility` reserved column (default `default`), created_by. Exactly one seeded `org` row ("AfrikaBurn").
- `memberships` — user × group, role enum (`god|org_staff|lead|admin|member|engineer`), unique(user, group). The three ORG ranks (`god|org_staff|engineer`) are only valid on the org group, and on it the enum is **the console DOOR, not the rights** (see `docs/technical-spec/16-org-permissions-and-system-panel.md`). **`god` is presented throughout the UI as "System manager"** — the stored value stays `god` deliberately (renaming it would migrate live rows and re-cut the GOD_EMAILS bootstrap for a label) — and is the anti-lockout ANCHOR. _(Migration 0017's free-text `department` label + `department_lead` flag were DROPPED by 0018: departments are rows now, and two department vocabularies would be the parallel source of truth org roles v1 exists to remove.)_
- `org_departments` — org departments as DATA (0018): `key` (stable slug), name, normalized name, description, sort. Created by a System manager; creating one seeds its permanent LEAD + MEMBER roles, deleting one cascades them away.
- `org_roles` — the org mirror of `project_roles` (0018): `key`, nullable `department_id` (cascade), name + normalized name, `kind` (`system` = seeded/undeletable/rights-editable, `custom` = fully the System manager's), curated `color`, `permissions` jsonb over the org capability vocabulary, sort. Unique on `key` and on normalized name.
- `org_role_assignments` — membership × role, composite PK (0018), mirroring `member_role_assignments`. Cascades off the membership, so removing console access releases every role with it.
- `invites` — group_id, token, kind (`member|lead_transfer`), created_by, expires_at, used_by, used_at. One-time.
- `editions` — name, year, start_date, end_date, is_active. Seed: **AfrikaBurn 2027, 2027-04-26 → 2027-05-02, active**.
- `registrations` — group × edition, status enum (`draft|submitted|under_review|changes_requested|approved|rejected|withdrawn`), plus typed columns for the six sections per Finlay's field list in `docs/sources/scope-theme-camp-registration.txt` (identity/contact, LNT incl. lead contact, participation & gifting, size & logistics incl. layout upload URLs (max 4), sound & placement prefs, suppliers & commerce), `submitted_at`, `decided_at`. **A camp is "registered" for an edition iff an approved registration row exists** — that predicate lives in `@quagga/core` (`isRegistered`), and entitlements derive from it.
- `section_reviews` — registration_id, section key enum (six values), status (`open|resolved`), comment, reviewer_id.
- `questionnaire_definitions`, `questionnaire_responses`, `questionnaire_activations`, `required_actions` — ported 1:1 from that reference pattern (keys map to code-side registry; Burner Bio dispatches through this). See `docs/technical-spec/10-questionnaire-engine.md`.
- `suppliers` — name, `code` (`SUP-2027-0416`, stored not derived), services, contact,
  website, category, `returning`, `standing` enum (`good|watch|suspended`), optional
  `user_id` account link, imported_at. _(`vetting_status` and `source` were killed —
  see `docs/technical-spec/12-suppliers.md` — and no longer exist; do not reintroduce them.)_
- `supplier_declarations` — registration_id × supplier_id, note.
- `payments` — subject_type + subject_id (polymorphic by string key), amount_cents nullable, currency default ZAR, reference (human-readable, e.g. `QP-2027-MAH-001`), status enum (`pending|reconciled|waived`), details jsonb, recorded_by. **No processing, ever.**
- `audit_events` — actor_id, action, subject, meta jsonb. Written on: elevation, approval/rejection, payment reconciliation.

## Seeds (`packages/db/src/seed.ts`, runnable script, idempotent)

**Law: seeds contain ONLY org-owned reference/catalog data. Every
burner, camp, membership, registration and questionnaire response — in every
environment, including the kickoff demo — is created live through the app.** There are
no seeded accounts. This supersedes the earlier seed set (Mad Hatters, Camp 404, six
fictional camps, fictional burners, payment references), which is deleted: seeded leads
carried placeholder `authUserId = seed:<email>` strings and could never sign in, so
every "sign in as the seeded owner" path was a dead end.

**Seeded:** org group "AfrikaBurn" (no memberships — staff elevate live via
`GOD_EMAILS`) · the two seeded ORG ROLES (Org staff, Engineer), insert-if-missing so a
System manager's own edits to their rights survive every later deploy — no departments and
no role ASSIGNMENTS, which are live acts · edition AfrikaBurn 2027 · the 8 canonical camp categories for that
edition · suppliers imported from the AB public sheet (CSV export of Google Sheet
`1XU2gAt5E9GczVHZWpcD0_CsEeE--iX9aWmnWd19bgMI`; committed as JSON snapshot so seeding
works offline) with their per-edition onboarding step maps and `user_id` **null**, so a
real supplier can self-register and claim the row by email overlap · one org-authored
questionnaire **template** (definition only — no activation, no audience, no responses).

**MUST NOT be seeded:** users, burner bios, `theme_camp`/`artwork`/`mutant_vehicle` groups,
memberships, invites, registrations, supplier declarations, section reviews,
questionnaire activations/required actions/responses, notifications, bulletins, audit
events, supplier notes, payments.

An empty directory, registrations queue and status board on a fresh database are the
**correct** first-boot state. Close that gap with honest empty states — a seeded row MUST NOT be used.

## Core logic that MUST have vitest coverage (`packages/core`)

`isRegistered` entitlement predicate · registration submit-gate (all six complete) ·
60-word counter · name normalization + similarity (trigram) · privacy hard-lock
enforcement · registration + review state machines (legal transitions only) · payment
reference generator · supplier CSV→JSON import parser.

## Explicitly NOT built

Containers (hint tile only) · attestation QR flows (only `profile_keys` generation) ·
payment processing/checkout · water/ice/gas · placement maps · PWA/offline · Inngest ·
Storybook.

_(Carry-forward between editions **is** built — see
`docs/technical-spec/07-previous-year-carry-forward.md`. It was on this list
when there was only a single seeded edition; that changed.)_

_(pen.dev **is** used — `design/ab-initial-app.pen` is the design source of truth. It
was on this list when the list meant "no design tooling"; that changed.)_

## Platform/database separation

The question was whether the database and accounts should move to a separate owning
"platform" unit. **They did not need to.** `packages/db` is the single owner of schema
and migrations for all three apps, and `packages/auth` is the single owner of the
account system — one self-hosted Better Auth instance, one shared account pool, SSO
across the apex. That is the shape the separation was after, reached without a
separate deployable.

Still binding: **no per-app migration tooling.** `packages/db` migrates, everything
else imports the client and types. The research trail is in
the executed plan in
`docs/technical-spec/01-auth-and-identity.md`.

[^1]: The questionnaire spine and workspace conventions in this document were originally ported from an earlier single-camp implementation of the same ideas.
