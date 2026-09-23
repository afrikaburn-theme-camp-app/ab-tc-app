<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
Scopes: web · org · suppliers · core · db · ui · auth · types · e2e · repo
Template: database — any schema.ts change / generated migration.
Prove: production-safe migration (live product — next deploy applies it).
App Spec: Implements OR Exempt only — delete the unused line. No Modifies (use docs).
Agent: one continuous blockquote after Summary. One 🤖 only, on the first heading.
-->

<!-- ===== HUMAN START: Summary ===== -->
## Summary

<!-- Fill: why we are doing this. Reasoning only — not what changed. No length cap. Plain Markdown. -->

<!-- ===== HUMAN END: Summary ===== -->

<!-- ===== AGENT START ===== -->
<!-- One continuous blockquote below. One 🤖 only — on the first ### line. Do not open a second quote. -->

>  <!-- What Changed: schema/migration in user terms. ≤3 sentences AND ≤500 characters. -->
>  ### 🤖 What Changed
>
>  <!-- App Spec: Implements = PREFIX-NNN this schema enables;
>       Exempt = hygiene index / generator repair / maintenance.
>       Fill EXACTLY ONE — delete the other line. -->
>  ### App Spec
>  **Implements:**
>  **Exempt:**
>
>  <!-- Generator path LOAD-BEARING. Never hand-write a migration.
>       Edit schema.ts → db:generate → commit SQL + meta/NNNN_snapshot.json. -->
>  ### Generator path
>  **schema.ts → db:generate → SQL + snapshot:** [ ] affirmed
>
>  <!-- Database LOAD-BEARING. THIS PRODUCT IS DEPLOYED. -->
>  ### Database
>  **Migration:**
>  **Additive:**
>  **Backfill / UPDATE:**
>  **Irreversible:**
>  **Snapshot committed:** yes / no
>
>  <!-- Blast Radius: apps that read the tables. Deploy is next deploy (no docs-only). -->
>  ### Blast Radius
>  **Apps:** web · org · suppliers
>  **Packages:** db ·
>  **Deploy:** next deploy | user-reachable before review
>
>  <!-- Risk Matrix — slim for migrations: Privacy (new columns?), Data durability, Rollback.
>       Omit unused lines. Behaviour ships in the same PR → say so under Notes (or prefer feature template). -->
>  ### Risk Matrix
>  **Privacy:**
>  **Data durability:**
>  **Rollback:**
>
>  <!-- Testing: prove the queries the app actually runs (incl. ON CONFLICT upserts), not only that the constraint exists. -->
>  ### Testing
>  **Gate:** [ ] `pnpm -w exec turbo run lint typecheck test build`
>  **Migration locally:** [ ] how:
>  **App queries (incl. ON CONFLICT):** [ ] covered by:
>  **E2E:** [ ] shard(s): none / … (only if behaviour also changes)
>
>  <!-- Notes: decisions, tradeoffs, follow-ups, known tech debt. Default "None." -->
>  ### Notes for the Reviewer
>  None.

<!-- ===== AGENT END ===== -->
