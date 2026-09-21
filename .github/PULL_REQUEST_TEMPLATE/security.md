<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
Scopes: web · org · suppliers · core · db · ui · auth · types · e2e · repo
Template: security — auth, sessions, privacy projection, authz predicates.
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

>  <!-- What Changed: auth/privacy/authz behaviour. ≤3 sentences AND ≤500 characters. -->
>  ### 🤖 What Changed
>
>  <!-- Predicate / audience: which @quagga/core predicate(s) or privacy class (HARD_LOCKED / SAFETY_VISIBLE), and who the audience is. UI hiding is never the security boundary. -->
>  ### Predicate / audience
>  **Predicate(s):**
>  **Privacy class:** none | hard-locked | safety-visible | other
>  **Audience:**
>
>  <!-- Blast Radius: pick apps/packages; one audience; one deploy timing. Keep scannable. -->
>  ### Blast Radius
>  **Apps:** web · org · suppliers
>  **Packages:** auth · core ·
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
>  <!-- Database: THIS PRODUCT IS DEPLOYED. "None." or migration detail. Never hand-write a migration. -->
>  ### Database
>  None.
>
>  <!-- Testing: auth, sessions, privacy projection, and invite round-trips need e2e:local — the unit gate does not run a browser. Use [x]/[ ] status lines. -->
>  ### Testing
>  **Gate:** [ ] `pnpm -w exec turbo run lint typecheck test build`
>  **E2E:** [ ] shard(s):
>  **Authz / privacy regression:** [ ] covered by:
>
>  <!-- Notes: decisions, tradeoffs, deliberately not done, follow-ups, known tech debt. Default "None." -->
>  ### Notes for the Reviewer
>  None.

<!-- ===== AGENT END ===== -->
