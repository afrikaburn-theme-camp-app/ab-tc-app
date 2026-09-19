---
id: decision-009
title: Decide payment direction (tracking only versus integrated payment processing)
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
  - ../meeting-minutes/2026-09-10-graeme-payment-and-portal-vision-messages.md
  - ../meeting-minutes/2026-09-17-dev-alignment.md
tags:
  - payments
  - compliance
---

# Decision 009: Decide payment direction (tracking only versus integrated payment processing)
Date: 2026-07-29
Owner: Beyers Nel
Status: proposed

## Context
Camp Fees and Payment Gateway is at risk. Spec mandates a payment gateway; MVP direction records payment references/status and avoids processing funds.

## Decision to make
- Option A: tracking-only platform scope (no fund handling).
- Option B: integrate payment gateway for defined flows.
- Option C: phased model (tracking-only first, gateway after explicit AfrikaBurn approval and compliance readiness).
- Option D: per-module/per-camp connector architecture (bring-your-own-gateway) — platform standardises the onboarding+payment-status workflow but never itself processes funds for any flow, including camp dues (see 2026-09-10 update below).

## Consequences to evaluate
- Regulatory/compliance burden.
- Financial operations risk and support load.
- Impact on budgeting and camp-fee workflows.

## Follow-up
- If gateway approved, define provider shortlist and compliance checklist before implementation.

## Update 2026-07-29 — MVP codebase observation
- The MVP deliberately never holds or processes money — it records payment references and reconciliation status only.
- A gateway would only be considered if AfrikaBurn requests one, and for AfrikaBurn-side fees rather than camp dues.
- This is an observation of current build behaviour, not a resolution of the decision — the spec's requirement (Section 8) still calls for an integrated gateway covering camp dues among other things.

## Update 2026-09-10 — Graeme (direct messages)
Source: [2026-09-10 Graeme — Payment and Portal Vision Clarification](../meeting-minutes/2026-09-10-graeme-payment-and-portal-vision-messages.md)

- Graeme's position: the platform does not need to build or operate payment gateways itself. It needs to support gateways being **embedded or connected per app/module**, so a camp can bring its own payment provider or banking system.
- This differs from both the spec's current wording (a single platform-provided gateway, Section 8) and the MVP's tracking-only stance (above) — it's a third option: a connector/bring-your-own-gateway architecture, with camp dues potentially still gateway-processed, just not by AB Org's own gateway.
- Flags that inbound international payments (overseas → South Africa) are difficult, and that gateway options that work well internationally need investigating. Not yet actioned — raised as future research, no owner assigned.
- Once a gateway is connected to a module, that module should track the whole onboarding-and-payment lifecycle together: who has registered, who has completed what, who has paid, who owes what, what payment maps to which service, and where each person is in the process. Frames this combined onboarding+payment visibility (not the gateway itself) as the real value.
- Ties into his broader one-portal vision (Container Project, Gas Project, and other services as modules of one platform): a camp/project connects its own gateway, and the relevant module manages the workflow around it (onboarding, payment requests, status, member allocation) without AB Org necessarily receiving or controlling the money.
- This input is the basis for Option D, above.

## Update 2026-09-19 — Dev alignment catch-up
Source: [2026-09-17 dev alignment](../meeting-minutes/2026-09-17-dev-alignment.md)

- Graeme restated camp financial tracking as a near-term priority (working budgets visible to the org for large camps; POPIA sign-offs per member), framed as plug-and-play mitigation rather than as a payment-gateway choice.
- That accountability threshold is recorded under §16 / `PNP-*` as a surfaced-unratified candidate (see also the 2026-09-19 §16 context note). It does **not** resolve Options A–D here. Status stays **proposed**.
