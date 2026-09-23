<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
Scopes: web · org · suppliers · core · db · ui · auth · types · e2e · repo
Template: feature — new user-visible behaviour.
Prove: product alignment (Implements) and who is affected.
App Spec: Implements only. Wrong template if Exempt or Modifies (use chore/fix or docs).
Agent: one continuous blockquote after Summary. One 🤖 only, on the first heading.
-->

<!-- ===== HUMAN START: Summary ===== -->
## Summary

<!-- Fill: why we are doing this. Reasoning only — not what changed. No length cap. Plain Markdown. -->

<!-- ===== HUMAN END: Summary ===== -->

<!-- ===== AGENT START ===== -->
<!-- One continuous blockquote below. One 🤖 only — on the first ### line. Do not open a second quote. -->

>  <!-- What Changed: capability the user gains — not files touched. ≤3 sentences AND ≤500 characters. -->
>  ### 🤖 What Changed
>
>  <!-- App Spec: cite PREFIX-NNN IDs this change delivers against
>       (docs/sources/app-specification/app-specification.md). Implements only. -->
>  ### App Spec
>  **Implements:**
>
>  <!-- Surfaces: which apps/consoles and primary audience. -->
>  ### Surfaces
>  **Apps:** web · org · suppliers
>  **Audience:** camp leads | burners | org staff | suppliers
>
>  <!-- Blast Radius: packages touched; one deploy timing. Keep scannable. -->
>  ### Blast Radius
>  **Packages:**
>  **Deploy:** next deploy | user-reachable before review
>
>  <!-- Risk Matrix — Privacy: none|camp|org|public-path; Authz: none|UI-only|server-predicate; Data durability: none|additive-migration|destructive; Behaviour change: none|internal|user-visible; Rollback: easy|migrate-forward|hard. Omit any dimension that does not apply (delete the line). Do not write "n/a". -->
>  ### Risk Matrix
>  **Privacy:**
>  **Authz:**
>  **Data durability:**
>  **Behaviour change:**
>  **Rollback:**
>
>  <!-- Database: "None." or use the database template when schema.ts / a migration is in the diff. Never hand-write a migration. -->
>  ### Database
>  None.
>
>  <!-- Testing: Gate alone is not enough for behavioural change. Use [x]/[ ] status lines. -->
>  ### Testing
>  **Gate:** [ ] `pnpm -w exec turbo run lint typecheck test build`
>  **E2E:** [ ] shard(s):
>
>  <!-- Deliberately not in this PR: one short line of scope honesty. -->
>  ### Deliberately not in this PR
>
>  <!-- Notes: decisions, tradeoffs, follow-ups, known tech debt. Default "None." -->
>  ### Notes for the Reviewer
>  None.

<!-- ===== AGENT END ===== -->
