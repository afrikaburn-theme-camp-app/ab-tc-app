# Engineering decisions (HOW)

This folder records **engineering** decisions: how we implement the product —
stack choices, subsystem design, delivery tactics.

It is **not** the operational / product decision log.

| Concern | Where it lives |
| --- | --- |
| **WHAT we build and WHY** (operational / working-group) | [`docs/sources/app-specification/decisions-record/`](../sources/app-specification/decisions-record.md) — Superhuman-synced App Spec corpus |
| **HOW we get there** (engineering) | **Here** (`docs/engineering-decisions/`) |

Do not duplicate operational decisions into this folder. Link up to the App Spec
decision when an engineering choice implements or is constrained by one.

**Numbering note:** engineering decisions here are prefixed `ENG-` in their
own id/front-matter (starting at `ENG-014`, since the first one recorded was
numbered before this convention existed) specifically to avoid colliding
with the App Specification's own, independent "Decision NNN" numbering —
e.g. this folder's `ENG-014` is unrelated to the App Spec's "Decision 014"
(governance, licensing and data-liability thresholds). The two number
spaces are never the same decision.

## Index

| ID                                                                | Title                                                               | Status   |
| ----------------------------------------------------------------- | ------------------------------------------------------------------- | -------- |
| [ENG-014](decision-014-questionnaire-engine-over-google-forms.md) | Registration intake: our own questionnaire engine, not Google Forms | Accepted |
