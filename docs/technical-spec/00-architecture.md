# Architecture

| Field                  | Value                                                                                                         |
| ---------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Category**           | Architecture                                                                                                  |
| **Doc status**         | Active                                                                                                        |
| **Normative language** | Descriptive only                                                                                              |
| **Requirement IDs**    | Partial — `SEC-*`, `CORE-*` (cross-cutting system reference; most content has no direct App Spec counterpart) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                                                  |

Three Next apps, one Postgres, one account pool. This describes what is
deployed today. Where it conflicts with [`../build-spec.md`](../build-spec.md),
the build spec wins — it is the engineering contract; this is the map. Full
precedence chain: [`../README.md`](../README.md#direction-of-information-travel).

## System

```mermaid
flowchart TB
    subgraph apps["Three front doors · Vercel"]
        web["apps/web<br/>participant"]
        org["apps/org<br/>organiser console"]
        sup["apps/suppliers<br/>supplier portal"]
    end

    subgraph pkgs["Shared workspace packages"]
        core["@quagga/core<br/>domain rules"]
        auth["@quagga/auth<br/>Better Auth 1.6.25"]
        db["@quagga/db<br/>schema · migrations"]
        ui["@quagga/ui<br/>components"]
    end

    neon[("Neon Postgres<br/>44 tables · 30 migrations")]

    subgraph ext["External services — all optional"]
        resend["Resend<br/>email"]
        gh["GitHub Issues<br/>in-app reporter"]
        claude["Anthropic<br/>report structuring"]
        groq["Groq Whisper<br/>dictation"]
        blob["Vercel Blob<br/>uploads"]
    end

    web & org & sup --> core & auth & db & ui
    auth --> neon
    db --> neon
    web --> resend & blob
    org --> resend
    web & org & sup --> gh
    gh -.-> claude
    web & org & sup -.-> groq

    classDef app fill:#2D7696,stroke:#235C75,color:#fff
    classDef pkg fill:#26333B,stroke:#323A3F,color:#F4F0E8
    classDef extern fill:#F4B672,stroke:#D98A2B,color:#332006
    class web,org,sup app
    class core,auth,db,ui pkg
    class resend,gh,claude,groq,blob extern
```

**Every external service is optional and degrades in the open.** No
`RESEND_API_KEY` and email is skipped; no `GITHUB_TOKEN` and the reporter is
not offered; no `ANTHROPIC_API_KEY` and reports file from a plain template;
no `GROQ_API_KEY` and dictation is hidden. The apps boot and serve without
any of them — the env-less boot rule in [`../../AGENTS.md`](../../AGENTS.md).

## Package dependencies

Strictly one-directional. An app may import anything; nothing imports an app.

```mermaid
flowchart LR
    types["@quagga/types"] --> core["@quagga/core"]
    types --> db["@quagga/db"]
    types --> ui["@quagga/ui"]
    types --> auth["@quagga/auth"]
    core --> db
    core --> ui
    core --> auth
    db --> auth
    core & db & ui & auth --> apps["apps/web · apps/org · apps/suppliers"]
```

| Rule                                                   | Why                                                                                                                                           |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `@quagga/core` never imports `@quagga/db`              | Domain rules stay pure and testable — no database needed to run the unit suite.                                                               |
| `@quagga/core/report-server` is a separate export path | It reads `GITHUB_TOKEN` and pulls the Anthropic SDK. Re-exporting it from the barrel would ship the filing machinery to every browser bundle. |

## A request

No middleware. Every app resolves its own session in a server component and
decides what the visitor may see.

```mermaid
sequenceDiagram
    participant B as Browser
    participant L as Route-group layout
    participant S as lib/session.ts
    participant A as auth package
    participant D as Neon

    B->>L: GET /some/page
    L->>S: resolve session
    S->>A: read cookie
    A->>D: session lookup
    D-->>A: user or null
    A-->>S: authenticated user
    S->>D: role / membership / gate reads
    D-->>S: viewer state
    alt refused
        S-->>L: gate state
        L-->>B: full-screen gate, no page body
    else allowed
        L-->>B: chrome + page
    end
```

Each app's gate answers a different question:

| App              | Gate                                                | Refusal                                         |
| ---------------- | --------------------------------------------------- | ----------------------------------------------- |
| `apps/web`       | Is onboarding complete? Any blocking questionnaire? | Blocking flow replaces the page                 |
| `apps/org`       | Does this account hold an org role?                 | `GateScreen` — "restricted to AfrikaBurn staff" |
| `apps/suppliers` | Has this verified email claimed a listing?          | `GateScreen` — unlinked account                 |

Pages re-guard before reading. Hiding a control is never the security boundary.

## Data

44 tables in one database, owned by `packages/db`. Migrations are append-only
and run on deploy (`db:migrate:deploy && next build`) — **against production,
with no staging step.**

```mermaid
erDiagram
    users ||--o| burnerBios : "profile"
    users ||--o{ memberships : "joins"
    groups ||--o{ memberships : "roster"
    groups ||--o{ invites : "issues"
    groups ||--|| registrations : "submits"
    registrations ||--o{ sectionReviews : "reviewed in"
    sectionReviews ||--o{ sectionReviewReplies : "replied to"
    registrations ||--o| wranglerAssignments : "shepherded by"
    users ||--o{ orgRoleAssignments : "staff"
    orgDepartments ||--o{ orgRoles : "defines"
    questionnaireDefinitions ||--o{ questionnaireActivations : "sent as"
    questionnaireActivations ||--o{ questionnaireResponses : "answered"
    suppliers ||--o{ supplierDocuments : "uploads"
    suppliers ||--o| supplierOnboarding : "progresses"
    users ||--o{ notifications : "receives"
    bulletins ||--o{ notifications : "fans out to"
    users ||--o{ auditEvents : "recorded in"
```

Four clusters: **identity** (users, sessions, 2FA, passkeys, bios, deletion
and email-change requests), **camps** (groups, memberships, invites, roles,
registrations, reviews, wranglers), **programme** (questionnaires, bulletins,
notifications, categories), **suppliers** (listings, onboarding, documents,
declarations). `auditEvents` spans all four.

## Constraints worth knowing before changing anything

- **The deployment is live**, with real participants' phone numbers,
  emergency contacts and medical notes in it. There is no staging database.
- **Migrations are append-only.** An applied migration cannot be edited, only
  corrected by another one. `packages/db/migrations/` is CODEOWNERS-gated.
- **Sessions are per-app.** One account pool, but cookies do not cross
  `*.vercel.app` — the Public Suffix List forbids it. Shared sign-on needs a
  configured apex; see [`01-auth-and-identity.md`](01-auth-and-identity.md).
- **There is no public API.** Every route handler under `apps/*/app/api/` is
  better-auth, blob upload, the in-app reporter, or a scheduled job — all
  data access is server actions and server components behind cookie
  sessions. An external, key-authenticated `/v1` surface is specified as a
  **Draft** in [`../sdk/`](../sdk/README.md) and **is not built**, pending
  App Specification Decision 005 (proposed); when it lands it is the first
  inbound authenticated arrow on the diagram above.
- **Personal data has classes**, enforced in `@quagga/core`: some Bio fields
  can never be public, medical notes require recorded consent, and reads of
  them are audited. A copy of one of those predicates outside `core` is the
  same risk as changing the original.

## UI component tiers (design canvas → `@quagga/ui`)

Derived from the design canvas via the `design/qa` audit tooling. Prebuilt
components are preferred over hand-rolling (shadcn ecosystem/registry first,
restyled to the "Tankwa Night" tokens) — hand-rolling an already-solved
problem is treated as a defect.

**Tier 1 — form controls** (highest instance counts): Select, Field
(label+control+help+error), Textarea with word count, Checkbox/Radio, Switch
(with a privacy variant — ON·PUBLIC / OFF·PRIVATE / hard-locked ALWAYS
PRIVATE), Input (password variant with a strength meter), phone input
(country selector), toggle group / year chips.

**Tier 2 — display & feedback**: Button (9 variants incl. an org accent),
Badge (status-enum variants), Avatar (initials fallback only), AppShell
(+ the full-width `QuiltBand` header motif, + `NotificationBell`), Toast,
Tooltip/Breadcrumb/Tabs/Pagination/dense Table/Skeletons/EmptyState,
`GateScreen` (the blocking-questionnaire gate and the org wall), the
6-section registration Wizard.

**Tier 3 — notifications/bulletins**: `NotificationBell`, `NotificationItem`,
`BulletinCard`, `PinnedBulletinBanner`, a markdown editor (minimal-tiptap) for
bulletin compose, `AudienceSelect` (shared with the questionnaire builder).

Build order: tokens → Tier 1 + Button/Badge → AppShell + NotificationBell →
Tier 2 → Tier 3 → pages.

## Page → design-canvas frame map

Every page has a desktop frame and a mobile-360 sibling in
`design/ab-initial-app.pen`. `design/qa/audit.py --sections <frameId>` emits
a frame's component manifest. The frame IDs themselves are canvas-internal
identifiers and change as the canvas is edited — see `design/pen-lessons.md`
for the current map rather than duplicating a list here that would go stale
the next time a frame is added or renamed. This doc records the _mapping
convention_ (one desktop frame + one mobile-360 sibling per route, named
after the route) rather than the frame IDs themselves.
