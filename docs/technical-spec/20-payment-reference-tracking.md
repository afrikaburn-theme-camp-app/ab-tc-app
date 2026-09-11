# Payment reference tracking

| Field                  | Value                              |
| ---------------------- | ---------------------------------- |
| **Category**           | Product                            |
| **Doc status**         | Active                             |
| **Normative language** | Descriptive only                   |
| **Requirement IDs**    | ❌ `PAY-001–PAY-021` (App Spec §8) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11       |

The platform does not currently run a payment gateway or take custody of
money. What exists is reference tracking: recording that a payment
happened, for whom, without processing it.

## Implements (App Specification)

| App Spec §                       | IDs         | Status | Notes                                                                                                         |
| -------------------------------- | ----------- | ------ | ------------------------------------------------------------------------------------------------------------- |
| §8 Camp fees and payment gateway | PAY-001–021 | ❌     | No gateway, no card handling, no payouts. See Drift for why this is a current build stance, not settled scope |

## Drift

> ⚠️ **DRIFT — opposes-with-proposed-decision, App Spec §8.** The App Spec
> describes a payment gateway. The build's current position — no gateway,
> ever, only reference tracking — is stated in several places (`AGENTS.md`,
> `docs/roadmap.md`) as though settled. The governing App Specification
> Decision Record, **Decision 009 (payment direction tracking vs.
> gateway)**, is `proposed`, not accepted, and a 2026-09-10 update to that
> record proposes a contrary option (per-module bring-your-own-gateway).
> Treat "no gateway" as this build's current stance pending Decision 009,
> not as a closed question. Separately: `payments` (the table) has **zero
> application code reading or writing it** — the reference-tracking logic
> in `packages/core/src/payment-tracking.ts` is pure, tested, and currently
> uncalled from any route or server action. Do not describe payments as
> "recorded" in the present tense; describe the mechanism as built and
> dormant.

## How it is built

- `payments` table: polymorphic `subject_type`/`subject_id`, nullable
  `amount_cents`, `reference` (human-readable, e.g. `QP-2027-MAH-001`),
  `status` (`pending | reconciled | waived`). No processing path exists —
  `assertRecordableAmount` refuses negative amounts on the stated grounds
  that "a platform which never took money cannot give any back."
- Two reference-code families: `QP-{year}-{camp}-{seq}` for an
  AfrikaBurn-side logistics fee, and `MAH-M017`-style per-membership codes
  for a camp's own EFT reconciliation against its own bank account —
  `packages/core/src/member-ref-code.ts`. Both are records, never
  transactions.
- `PaymentDetailsBlock` (`packages/ui`) is the only UI surface, and it is
  not wired into any registration flow today.

## Invariants and tests

`packages/core/src/__tests__/{payment-tracking,payment-reference,member-ref-code}.test.ts` —
these assert the reference-generation and status rules in isolation; there
is no integration test exercising a live route, because none calls this
code yet.
