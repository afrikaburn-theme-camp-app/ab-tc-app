# 2026-09-22 Ruchir — Camp finance proposal

## Source
- Theme Camp App WhatsApp group, 2026-09-22 (Ruchir Thakore) and follow-ups 2026-09-23 (Beyers Nel, Ruchir).
- Interpreted summary below; not verbatim. Product implications recorded under [Decision 009](../decisions-record/decision-009-proposed-payment-direction-tracking-vs-gateway.md).

## Summary

Ruchir asked the group to validate a first camp-finance slice before schema work lands in `@quagga/db`.

### Direction
- Build day-to-day camp money tools in `ab-tc-app` (Quagga): living budget (plan vs approved vs actual); camp dues with unique payment references, bank CSV / manual EFT matching, and instalments; expense submit + approve + reimbursements; open books for members.
- Track who owes / paid / spent — do **not** hold or move money.
- If a camp, village, or org needs proper entity books (NGO / tax), export or later connect something like Xero rather than building full accounting in-app.
- Whether card / payment-provider checkout is ever added remains an open team call — not part of this first slice.
- He reported a local spike (payment refs + CSV matching + tests in `@quagga/core` / `@quagga/types`) with no live `@quagga/db` schema changes yet.

### Assumptions offered for validation
1. Camp finance lives in `ab-tc-app`, with logic in `@quagga/core` / `@quagga/types` and screens in the participant app — same repo, normal review process.
2. Budget, dues, and expense tables go in `@quagga/db` (with a short design note first) — not a new package or repo.
3. First version is camp screens only, with hooks for village/org later (no village shared-cost screens yet).
4. First version is tracking + bank matching only — not a payment provider inside the app.
5. Ops tracking in Quagga; proper books in Xero (or similar) later if needed.
6. For AfrikaBurn org / plug-and-play checks, expose simple totals (budgeted, spent, dues billed/collected, fee, headcount, open reimbursements) and whether dues collected cross roughly R100k — summaries, not everyone’s private ledger lines.

### Open questions he raised
1. OK to write a short design note and then extend `@quagga/db` for camp finance on a feature branch now, or wait on the payments debate and/or org compatibility chat?
2. Who owns the village app / shared-cost side, and what shared IDs should camp finance hang off?
3. For org top-line numbers — what is needed on day one vs later?

### Follow-up in chat
- Beyers (2026-09-23): supportive; no need to wait on the payment-gate decision for this tracking work; needed more context on village (2) and org totals (3).
- Ruchir (same day): will proceed with design note + `@quagga/db` tables on a feature branch; clarified village as a later “shared line” hook without village screens in v1; restated the draft org summary list until the org compatibility chat confirms day-one needs.
- Graeme was flagged as best positioned for village / org direction; no recorded Graeme answer in this thread yet.

## Related
- [Decision 009](../decisions-record/decision-009-proposed-payment-direction-tracking-vs-gateway.md)
- [App Specification §7 Working Budget](../app-specification.md#7-working-budget-and-financial-tracking-)
