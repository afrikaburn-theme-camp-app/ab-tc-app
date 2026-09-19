---
id: decision-010
title: Decide ticketing scope (Quicket system-of-record versus camp-side ticket allocation module)
date: 2026-07-29
author: Beyers Nel
status: proposed
type: decision
related:
  - ../app-specification.md
tags:
  - ticketing
  - integration
---

# Decision 010: Decide ticketing scope (Quicket system-of-record versus camp-side ticket allocation module)
Date: 2026-07-29
Owner: Beyers Nel
Status: proposed

## Context
Ticket Allocation and Ticket Status is at risk. Spec requires camp-side ticket allocation tooling; MVP currently has no ticket module and assumes Quicket remains authoritative.

## Decision to make
- Option A: no ticket module; keep Quicket as sole source and store status only if needed.
- Option B: implement internal camp-side ticket allocation/status module without issuing tickets.
- Option C: implement integration-only sync layer against ticketing provider data.

## Consequences to evaluate
- Duplication risk versus operational utility.
- Integration reliability and support burden.
- Impact on WAP and registration consistency.

## Follow-up
- Ticketing research remains an input before acceptance. Not tracked in this corpus.

## Update 2026-09-10 — Graeme (direct messages)
Source: [2026-09-10 Graeme — Payment and Portal Vision Clarification](../meeting-minutes/2026-09-10-graeme-payment-and-portal-vision-messages.md)

- Graeme's bigger-picture vision is a single portal login where a person can access their Burner profile, **buy tickets**, create/join a Creative Group or Theme Camp, register projects, manage members, and organise containers/gas/other services — all as plug-in modules of one platform.
- This implies ticket *purchasing* happening inside the portal, which sits in tension with the MVP's current assumption that Quicket remains the sole system-of-record and the spec's stance that the platform "should not issue official tickets itself unless formally integrated" (Section 10).
- Not clear from the message whether Graeme means the portal fronts/embeds a Quicket checkout (Option C-style integration) or genuinely issues/sells tickets itself (a stronger version of Option B) — needs clarifying with him directly before this changes the option set below.
- No decision made on this basis yet; recorded as additional context for whoever resolves this decision.
