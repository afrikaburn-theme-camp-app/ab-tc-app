<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
Scopes: web · org · suppliers · core · db · ui · auth · types · e2e · repo
Template: docs — specs / process, no runtime behaviour.
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

>  <!-- What Changed: which docs changed and the reader-facing effect. ≤3 sentences AND ≤500 characters. -->
>  ### 🤖 What Changed
>
>  <!-- Blast Radius: usually docs-only / audience none. Keep scannable. -->
>  ### Blast Radius
>  **Apps:** none
>  **Packages:** none (or list doc paths under repo)
>  **Audience:** none | maintainers | contributors
>  **Deploy:** docs-only
>
>  <!-- Risk Matrix: omit any dimension that does not apply (delete the line). Do not write "n/a" or explain why omitted. Docs-only PRs often only need Behaviour change and/or Rollback. -->
>  ### Risk Matrix
>  **Privacy:**
>  **Authz:**
>  **Data durability:**
>  **Behaviour change:**
>  **Rollback:**
>
>  <!-- Database: must be None. for this template. If not, use the database template instead. -->
>  ### Database
>  None.
>
>  <!-- Testing: N/A is fine when there is no runtime behaviour. Say what you checked. Use [x]/[ ] status lines. -->
>  ### Testing
>  **Docs review:** [ ] accuracy / broken links
>  **Gate (optional):** [ ] `pnpm -w exec turbo run lint typecheck test build`
>
>  <!-- Notes: decisions, tradeoffs, deliberately not done, follow-ups, known tech debt. Default "None." -->
>  ### Notes for the Reviewer
>  None.

<!-- ===== AGENT END ===== -->
