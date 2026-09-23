<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
Scopes: web · org · suppliers · core · db · ui · auth · types · e2e · repo
Template: security — auth, sessions, privacy projection, authz predicates.
Prove: the server boundary (UI hiding is never the security boundary).
App Spec: Implements OR Exempt only — delete the unused line. No Modifies (use docs).
Agent: one continuous blockquote after Summary. One 🤖 only, on the first heading.
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
>  <!-- App Spec: Implements = usually SEC-* plus any feature prefixes touched;
>       Exempt = e.g. emergency pin / routine hygiene (say which + why).
>       Fill EXACTLY ONE — delete the other line. -->
>  ### App Spec
>  **Implements:**
>  **Exempt:**
>
>  <!-- Boundary: pick one primary. -->
>  ### Boundary
>  server-predicate | session | projection | audit
>
>  <!-- Predicate / audience LOAD-BEARING. UI hiding is never the security boundary. -->
>  ### Predicate / audience
>  **Predicate(s):**
>  **Privacy class:** none | hard-locked | safety-visible | other
>  **Audience:**
>
>  <!-- Threat framing: one sentence. -->
>  ### What a malicious peer cannot do after this
>
>  <!-- Blast Radius: pick apps/packages; one audience; one deploy timing. -->
>  ### Blast Radius
>  **Apps:** web · org · suppliers
>  **Packages:** auth · core ·
>  **Audience:** none | camp leads | burners | org staff
>  **Deploy:** docs-only | next deploy | user-reachable before review
>
>  <!-- Risk Matrix: Privacy and Authz are REQUIRED (do not omit). Others optional — delete unused lines.
>       Levels — Privacy: none|camp|org|public-path; Authz: none|UI-only|server-predicate;
>       Data durability: none|additive-migration|destructive; Behaviour change: none|internal|user-visible;
>       Rollback: easy|migrate-forward|hard. -->
>  ### Risk Matrix
>  **Privacy:**
>  **Authz:**
>  **Data durability:**
>  **Behaviour change:**
>  **Rollback:**
>
>  <!-- Database: "None." or migration detail. Never hand-write a migration. -->
>  ### Database
>  None.
>
>  <!-- Testing: sessions, privacy projection, invite round-trips need e2e:local — the unit gate does not run a browser. -->
>  ### Testing
>  **Gate:** [ ] `pnpm -w exec turbo run lint typecheck test build`
>  **E2E:** [ ] shard(s): (required for sessions / privacy / invite)
>  **Authz / privacy regression:** [ ] covered by:
>
>  <!-- Notes: decisions, tradeoffs, follow-ups, known tech debt. Default "None." -->
>  ### Notes for the Reviewer
>  None.

<!-- ===== AGENT END ===== -->
