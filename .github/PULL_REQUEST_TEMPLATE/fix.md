<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
Scopes: web · org · suppliers · core · db · ui · auth · types · e2e · repo
Template: fix — correcting broken behaviour.
Agent: one continuous blockquote after Summary. One 🤖 only, on the first heading:
>  ### 🤖 Title Text
>  Other text
-->

<!-- ===== HUMAN START: Summary ===== -->
## Summary

<!-- Fill: why we are doing this. Reasoning only — not what changed. No length cap. Plain Markdown. -->

<!-- ===== HUMAN END: Summary ===== -->

<!-- ===== AGENT START ===== -->
<!-- One continuous blockquote below. One 🤖 only — on the first ### line. Do not open a second quote. -->

>  <!-- What Changed: what was broken and what the fix does. ≤3 sentences AND ≤500 characters. -->
>  ### 🤖 What Changed
>
>  <!-- Regression proof: the test, query, or e2e that fails without this change and passes with it. -->
>  ### Regression proof
>
>  <!-- Blast Radius: pick apps/packages; one audience; one deploy timing. Keep scannable. -->
>  ### Blast Radius
>  **Apps:** web · org · suppliers
>  **Packages:**
>  **Audience:** none | camp leads | burners | org staff
>  **Deploy:** docs-only | next deploy | user-reachable before review
>
>  <!-- Risk Matrix levels — Privacy: none|camp|org|public-path; Authz: none|UI-only|server-predicate; Data durability: none|additive-migration|destructive; Behaviour change: none|internal|user-visible; Rollback: easy|migrate-forward|hard. When filling: omit any dimension that does not apply (delete the line). Do not write "n/a" or explain why omitted. -->
>  ### Risk Matrix
>  **Privacy:**
>  **Authz:**
>  **Data durability:**
>  **Behaviour change:**
>  **Rollback:**
>
>  <!-- Database: THIS PRODUCT IS DEPLOYED. "None." or migration number, additive?, backfill/UPDATE touches. Never hand-write a migration. -->
>  ### Database
>  None.
>
>  <!-- Testing: what ran and what it proved. Name the regression proof above. Use [x]/[ ] status lines — task lists do not render in blockquotes. -->
>  ### Testing
>  **Gate:** [ ] `pnpm -w exec turbo run lint typecheck test build`
>  **E2E:** [ ] shard(s):
>
>  <!-- Notes: decisions, tradeoffs, deliberately not done, follow-ups, known tech debt. Default "None." -->
>  ### Notes for the Reviewer
>  None.

<!-- ===== AGENT END ===== -->
