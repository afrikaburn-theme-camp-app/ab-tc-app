---
id: decision-014
title: Define governance, licensing, and data-liability thresholds for scaling beyond a personal-repo Proof of Concept
date: 2026-08-05
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - ../task-assignment.md
  - ../meeting-minutes/2026_08_06 Tech team onboarding.md
  - decision-005-proposed-backend-first-platform-api-mcp-sdk-no-community-plugins.md
tags:
  - governance
  - risk
  - legal
  - process
---

# Decision 014: Define governance, licensing, and data-liability thresholds for scaling beyond a personal-repo Proof of Concept
Date: 2026-08-05
Owner: Beyers Nel
Status: proposed
Related: [App Specification](../app-specification.md), [Task Assignment](../task-assignment.md), [Tech team onboarding meeting minutes](../meeting-minutes/2026_08_06%20Tech%20team%20onboarding.md), [Decision 005](decision-005-proposed-backend-first-platform-api-mcp-sdk-no-community-plugins.md)

## Context

Pride Musvaire raised repo-governance concerns in the group chat (2026-08-04 09:57): moving off a personal GitHub repo to an Organisation account with multiple admins, shared tooling accounts, and stronger review/testing practices. Ryan James Noble's response (2026-08-04 10:04) was that the team is "critically not at a point where we need shared org accounts, multiple reviewers" — current safeguards (main branch protection, 1 required approver, required status checks consolidated under `ci-pass`, CodeRabbit review on a free tier) are proportionate to today's Proof-of-Concept stage.

Both positions are reasonable for their respective view of the project's current stage. The open question isn't whether today's setup is adequate — it's **at what point it stops being adequate**, and what specifically must happen when that point arrives. Three concrete risk areas were identified:

1. **Repository and ownership structure** — currently a personal GitHub repo owned by one individual (Ryan James Noble), with collaborator-level access for others. No formal legal entity or shared institutional ownership exists. **Update (2026-08-06 tech team onboarding):** Ryan James Noble restated the same position directly to the wider team: an actual GitHub Organisation gets set up "once we get some input from AfrikaBurn," and the personal-repo setup is deliberate for now specifically because "migrating is just annoying." This is a second, independent confirmation of the trigger described in Option A2 below — still Ryan's own working assumption, not a ratified team decision.
2. **Licensing** — no license has been chosen or applied to the codebase. Undefined licensing leaves contribution terms, reuse rights, and AfrikaBurn's own rights to the software ambiguous. See the confirmation under Section B — the open question about *intent* has since been resolved.
3. **Data-breach liability** — the spec already mandates POPIA-compliant handling, encryption, and access controls for camper PII (Section 4 / `CDB-*`, and Section 19 / `SEC-*`, the latter tracked as ✅ implemented), but nothing defines *who is accountable* — legally, financially, or operationally — if a breach occurs. The project is currently a Proof of Concept holding only test/dummy data, which is precisely why this hasn't been forced yet. **Update (2026-08-06 tech team onboarding):** Ryan James Noble referred to the shared production database (used by all three apps) as something that "has people's ... passport numbers in it," in the context of needing more security due diligence as data volume grows. The transcript doesn't make clear whether this describes real data already present or an anticipated future state — see Follow-up, this needs to be confirmed directly, since it bears on whether Option C1 has already been tripped.

No target end-state ownership structure has been decided — whether AfrikaBurn eventually absorbs the project as official tooling, an independent entity forms around the core volunteer team, or it stays informal indefinitely — and this decision record does not attempt to pick one. Its purpose is narrower: **define the thresholds that should force that choice to be made**, so it doesn't get made by default through inertia, or worse, mid-incident.

## Decision to make

For each risk area, the team needs to agree on both **a trigger** (the event/threshold that forces action) and **an owner** (who is accountable for acting once triggered). Candidate triggers below are offered as options, not a recommendation — none has been ruled on.

### A. Repository and ownership structure
- Option A1: Trigger = first real (non-test) personal data stored in any environment reachable outside the core dev group.
- Option A2: Trigger = AfrikaBurn formally endorses or adopts the platform as official tooling (an organisational commitment, not just awareness of the side project).
- Option A3: Trigger = contributor count exceeds a set number outside the current core group, or the project takes on a second maintainer capable of unilateral merge access.
- Option A4: Combination — whichever of A1–A3 happens first.

### B. Licensing
- Option B1: Trigger = first external (non-core-team) contribution is accepted — accepting a PR with no stated license creates ambiguous IP terms for that contributor.
- Option B2: Trigger = the same event chosen for Section A, since a license is close to meaningless without a settled owner to hold or grant it.
- Option B3: Defer explicitly — treat licensing as blocked on Section A's ownership question rather than deciding it independently.

**Note:** the repo already carries a `LICENSE` file (FSL-1.1-ALv2, converting to Apache 2.0 two years after each release). Whether this was a deliberate choice or default boilerplate left over from repo setup has not been confirmed with Ryan James Noble — this should be challenged and either affirmed or replaced as part of resolving this section, not treated as already decided.

**Update (2026-08-06 tech team onboarding):** this is now confirmed — it was a deliberate choice, not boilerplate. Ryan James Noble stated the license was set up so that "companies can't take this to just go make a product," i.e. specifically to block corporate co-option while the project is small. He also flagged it as a provisional choice he's open to revisiting ("we can change that later... most people use MIT and just YOLO"). This resolves the *intent* question above, but not Options B1–B3 — those are still about *when* a considered (not default-reversed) licensing decision should be forced, and by whom, given AfrikaBurn's own rights are still unaddressed.

### C. Data-breach liability and accountability
- Option C1: Trigger = first real camper/member PII is stored anywhere outside the core dev team's own test environments (mirrors A1, but tracked as its own gate — liability can and should be assigned before ownership is fully formalised).
- Option C2: Trigger = first production deployment used by an actual camp during a live registration cycle.
- Option C3: Require an explicit accountable contact and a basic incident-response plan to exist *before* C1 or C2 occurs — i.e. the trigger is "before," not "at."

## Consequences to evaluate

- **Over-formalising too early:** multiple approvers, org-account overhead, and legal review cycles could slow a small volunteer team down before there is anything real to protect.
- **Under-formalising too late:** if real PII or a live camp registration arrives before governance catches up, there is currently no defined owner for breach response, no license terms for external contributors, and no institutional entity behind the repository.
- **This is not a substitute for legal advice.** POPIA obligations and data-breach liability ultimately require input from AfrikaBurn's own legal/compliance function or independent counsel. This decision record can define *when* to seek that input — it cannot resolve the liability question itself, and no option above should be treated as legally sufficient on its own.
- **Interaction with Decision 005:** an unclear license could chill the exact external-contribution model (SDK/template + pull requests, no community plugins) that Decision 005 anticipates.
- Pride's related suggestions from the same discussion — shared tooling accounts, an architecture diagram, e2e test coverage — are process-maturity improvements, not governance/liability triggers in themselves; they're tracked in [Task Assignment](../task-assignment.md) rather than folded into this decision.

## Follow-up

- Actions: agree on triggers for A, B, and C (or adopt the combination option under A); assign an interim accountable contact for data-handling questions even before a formal owner structure exists, since real-PII risk is data-triggered, not date-triggered.
- Before any real camper PII is stored (Option A1/C1), get actual legal/compliance input on data-breach liability and POPIA obligations — this should not be resolved by engineering judgement alone.
- **New:** confirm with Ryan James Noble whether the shared database currently holds any real passport numbers/PII (per the 2026-08-06 onboarding session) or only test/dummy data consistent with PoC status — this directly determines whether Option C1's trigger has already been crossed and should be treated as urgent given the ambiguity.
- Review date: revisit at the next milestone that plausibly trips any trigger above — e.g. before the next live registration cycle opens, or if AfrikaBurn signals formal adoption.
