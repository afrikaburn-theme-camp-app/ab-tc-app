<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
Scopes: web · org · suppliers · core · db · ui · auth · types · e2e · repo
Template: fix — correcting broken behaviour.
Prove: the bug is real and cannot return silently (Regression proof).
App Spec: Implements OR Exempt only — delete the unused line. No Modifies (use docs).
Agent: one continuous blockquote after Summary. One 🤖 only, on the first heading.
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
>  <!-- App Spec: Implements = PREFIX-NNN the broken behaviour belongs to;
>       Exempt = routine/emergency fix / maintenance (say which + why).
>       Fill EXACTLY ONE — delete the other line. -->
>  ### App Spec
>  **Implements:**
>  **Exempt:**
>
>  <!-- Severity: pick one. -->
>  ### Severity
>  user-blocking | wrong-data | cosmetic | tooling-only
>
>  <!-- Regression proof LOAD-BEARING: the test, query, or e2e that fails without this change and passes with it. -->
>  ### Regression proof
>
>  <!-- Reproduced on main: yes/no + how. Stops "my branch flake" PRs. -->
>  ### Reproduced on main
>  **Yes / no:**
>  **How:**
>
>  <!-- Blast Radius: pick apps/packages; one audience; one deploy timing. -->
>  ### Blast Radius
>  **Apps:** web · org · suppliers
>  **Packages:**
>  **Audience:** none | camp leads | burners | org staff
>  **Deploy:** docs-only | next deploy | user-reachable before review
>
>  <!-- Risk Matrix — slim for fixes. Privacy / Authz / Behaviour change / Rollback.
>       Omit unused lines. Migration in the diff → use the database template instead. -->
>  ### Risk Matrix
>  **Privacy:**
>  **Authz:**
>  **Behaviour change:**
>  **Rollback:**
>
>  <!-- Database: "None." Migration → database template. Never hand-write a migration. -->
>  ### Database
>  None.
>
>  <!-- Testing: name the regression artifact above. Use [x]/[ ] status lines. -->
>  ### Testing
>  **Gate:** [ ] `pnpm -w exec turbo run lint typecheck test build`
>  **E2E:** [ ] shard(s):
>  **Regression named above:** [ ] covered by:
>
>  <!-- Notes: decisions, tradeoffs, follow-ups, known tech debt. Default "None." -->
>  ### Notes for the Reviewer
>  None.

<!-- ===== AGENT END ===== -->
