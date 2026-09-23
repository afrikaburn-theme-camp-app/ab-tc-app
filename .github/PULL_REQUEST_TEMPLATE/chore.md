<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
Scopes: web · org · suppliers · core · db · ui · auth · types · e2e · repo
Template: chore — deps, CI, tooling, non-behaviour refactors.
Prove: this is not a sneaky behaviour change.
App Spec: Exempt only. Need Implements → feature/fix. Need Modifies → docs.
Agent: one continuous blockquote after Summary. One 🤖 only, on the first heading.
-->

<!-- ===== HUMAN START: Summary ===== -->
## Summary

<!-- Fill: why we are doing this. Reasoning only — not what changed. No length cap. Plain Markdown. -->

<!-- ===== HUMAN END: Summary ===== -->

<!-- ===== AGENT START ===== -->
<!-- One continuous blockquote below. One 🤖 only — on the first ### line. Do not open a second quote. -->

>  <!-- What Changed: tooling/deps/CI/refactor. ≤3 sentences AND ≤500 characters. If behaviour changed, use feature or fix instead. -->
>  ### 🤖 What Changed
>
>  <!-- App Spec: Exempt only — name which + why (maintenance / update / repo hygiene). -->
>  ### App Spec
>  **Exempt:**
>
>  <!-- Kind: pick one. -->
>  ### Kind
>  deps | CI | tooling | refactor | repo-hygiene
>
>  <!-- Pin / advisory: fill for deps PRs (e.g. better-auth must stay pinned). Else delete this section. -->
>  ### Pin / advisory
>  **Touched pins:** none /
>
>  <!-- Behaviour unchanged LOAD-BEARING for chores. accidental-risk → run E2E and say so under Testing. -->
>  ### Behaviour unchanged
>  affirmed | accidental-risk
>
>  <!-- Blast Radius: packages/tooling touched. Audience is none for chores. -->
>  ### Blast Radius
>  **Packages / tooling:**
>  **Audience:** none
>  **Deploy:** docs-only | next deploy
>
>  <!-- Database: must be None. Migration → use the database template. -->
>  ### Database
>  None.
>
>  <!-- Testing: Gate required. E2E default none unless Behaviour unchanged = accidental-risk. -->
>  ### Testing
>  **Gate:** [ ] `pnpm -w exec turbo run lint typecheck test build`
>  **E2E:** [ ] shard(s): none / …
>
>  <!-- Notes: decisions, tradeoffs, follow-ups, known tech debt. Default "None." -->
>  ### Notes for the Reviewer
>  None.

<!-- ===== AGENT END ===== -->
