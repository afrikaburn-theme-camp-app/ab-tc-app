<!--
TITLE: Conventional Commits with a workspace scope — see CONTRIBUTING.md.
    type(scope): imperative subject, lowercase, no full stop, <=72 chars
Scopes: web · org · suppliers · core · db · ui · auth · types · e2e · repo
Template: docs — specs / process, no runtime behaviour.
Prove: either change the product north star (Modifies) or document against it.
App Spec: Modifies (default for App Spec / decisions / meeting notes) OR Implements OR Exempt —
  fill EXACTLY ONE, delete the other two. Never mix Implements and Modifies.
No Database section — migration in the diff → use the database template.
Agent: one continuous blockquote after Summary. One 🤖 only, on the first heading.
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
>  <!-- App Spec (docs/sources/app-specification/app-specification.md):
>       Modifies — App Spec / meeting notes / decisions: list PREFIX-NNN (added|changed|removed). Preferred for App Spec PRs.
>       Implements — technical-spec / process docs citing existing PREFIX-NNN IDs.
>       Exempt — process / repo-hygiene docs with no product requirement impact.
>       Fill EXACTLY ONE — delete the other two lines. Never mix Implements and Modifies. -->
>  ### App Spec
>  **Modifies:**
>  **Implements:**
>  **Exempt:**
>
>  <!-- Corpus: pick the primary home of the change. -->
>  ### Corpus
>  app-specification | technical-spec | engineering-decisions | process (CONTRIBUTING/AGENTS) | other
>
>  <!-- Change Record: required when Mode = Modifies. -->
>  ### Change Record
>  **Entry:** (app-spec-change-record.md name / N/A — decision-only / N/A — not Modifies)
>
>  <!-- Paths under docs/ (or process files). Deploy is docs-only. -->
>  ### Blast Radius
>  **Paths:**
>  **Deploy:** docs-only
>
>  <!-- Reader impact replaces the full Risk Matrix for docs. -->
>  ### Reader impact
>  none | contributors | maintainers | working-group
>
>  <!-- Testing: no runtime behaviour expected. -->
>  ### Testing
>  **Docs review:** [ ] accuracy / broken links
>  **Gate (optional):** [ ] `pnpm -w exec turbo run lint typecheck test build`
>
>  <!-- Notes: decisions, tradeoffs, follow-ups, known tech debt. Default "None." -->
>  ### Notes for the Reviewer
>  None.

<!-- ===== AGENT END ===== -->
