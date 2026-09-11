# Primary sources

Most of this tree is scraped or extracted ground truth: AfrikaBurn's own
published pages, and the source scope documents this product was specified from.
**Cite those rather than guessing event facts.**

For those verbatim mirrors, nothing is edited to match the product. Where a page
says "burner name", or describes a process we implemented differently, that is
the source speaking and it stays. Correcting a source to agree with the build
destroys the only record of what was actually asked for.

## Exception — App Specification (Superhuman sync; pull-dominant)

[`app-specification/`](app-specification/README.md) is **not** a frozen scrape.
It is the local working copy of the product App Specification corpus. **Content
normally flows Superhuman → git** (audit + pull). Pushing back is only for light
editing, formatting, cleanup, or notetaking (e.g. new meeting notes or group
discussions that add information or affect a decision). It used to live in the
standalone `ab-app-docs` repo; **this directory is now the only home**.

See that folder's `README.md` for sync direction, token setup
(`SUPERHUMAN_TOKEN`), commands, and conventions (`AGENTS.md` inside the folder).

## What else is here

### [`quaggapedia/`](quaggapedia/INDEX.md) — the official event wiki

A full point-in-time mirror (22 July 2026) of AfrikaBurn's wiki: **68 canonical
pages and 21 binaries** — supplier depot rules, SOOP sound levels, WAP and ticket
rules, the DMV process, LNT, fire and generator rules, the event and sound maps,
and the STAR onboarding PDF.

Captured through the wiki's open MediaWiki API: 123 main-namespace pages
enumerated, language variants and junk filtered out, then fetched in parallel and
converted to markdown with provenance frontmatter. **The wiki will drift** —
re-run the same process to refresh rather than hand-patching a page.

### [`afrikaburn-org/`](afrikaburn-org/INDEX.md) — the public site

726 pages mirrored 24 July 2026.

### The scope documents

Text extractions of Finlay Kettlewell's Master Brief and five scope documents —
the **concrete scope** — plus Graham's Quagga Portal platform document, which is
**ideation topics only**. One example contact was redacted.

Where the two visions differ and what was chosen from each is recorded in
[`../synthesis.md`](../synthesis.md).
