# Requirements

This directory is the **primary source** for product requirements for the
AfrikaBurn Theme Camp App (Quagga Portal). It lives entirely in this monorepo.
There is no external collaborative surface and no sync tooling in the active
workflow.

> **Authoritative file:** [`requirements.md`](requirements.md)
>
> Downstream: feature specifications under
> [`../specifications/`](../specifications/README.md), then implementation.
> See [`../README.md`](../README.md) for the full precedence chain.

## When Requirements may change

Requirements change only when the working group records new meetings,
discussions, and/or decisions that affect what the product should do. Edit
`requirements.md` (and Decision Records as needed) in a pull request; append
the Change Record when `requirements.md` itself changes. Do not invent product
behaviour in code or in a Specification without a corresponding Requirements
source.

## Layout

| Path | Role |
| ---- | ---- |
| `requirements.md` | Current product/feature requirements baseline (`PREFIX-NNN` IDs) |
| `requirements-change-record.md` | Append-only log of changes to `requirements.md` only |
| `requirement-index.md` | Index of every requirement ID |
| `decisions-record.md` + `decisions-record/` | Product decisions (WHAT/WHY) — not engineering HOW |
| `member-list.md`, `links.md` | People and references |
| `meeting-minutes/` | Working-group notes |
| `AGENTS.md` | Conventions for editing **this** corpus |

## Relationship to Specifications and engineering docs

- **Requirements** (this folder) = what / for whom / why.
- **Specifications** ([`../specifications/`](../specifications/README.md)) =
  how a change will work, written from Requirements and reviewed by engineers
  before build.
- **`docs/technical-spec/`** = legacy as-built record; migrates into
  Specifications once the Product Owner/Designer defines the format.
- **`docs/engineering-decisions/`** = engineering HOW.

Sibling folders under [`../sources/`](../sources/README.md) remain verbatim
one-way mirrors — never edited to match the product.

## Contribution

See [`AGENTS.md`](AGENTS.md) for the contribution workflow, metadata standard,
and change-record / decision templates.
