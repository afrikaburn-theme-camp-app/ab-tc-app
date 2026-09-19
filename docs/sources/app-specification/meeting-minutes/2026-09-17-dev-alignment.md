# 2026-09-17 Dev alignment catch-up

## Source
- Meeting: Theme Camp App catch-up — 17 September 2026 (~51 min).
- Attendees (from the Gemini export): Graeme Allan, Beyers Nel, Finlay Kettlewell, Rohan Shackleford, Ruchir Thakore. Michael Hazell was expected; did not join.
- Recorded via Gemini notes (quick notes + full notes). The summary below is curated from that export.
- Transcript wording is **not** authoritative spec language. Speaker attribution in the Gemini export is noisy in places.

## Terminology
In related AfrikaBurn meetings the Theme Camp App was sometimes called "Ryan's app". Ryan James Noble has left the team and forked independently. New writing in this corpus uses **Theme Camp App** (Quagga Portal).

The **Container App** is a standalone existing app, separate from the Theme Camp App. It manages everything to do with a camp's shipping containers — buying one, ordering one, having it moved, having it placed on site, moving it offsite to storage — and is not limited to placement. Integration concerns with it are in scope; its internals are not.

## Meeting Purpose

Align the working group after Ryan's departure, report org engagement progress (acting EDO / Tim Doyle), and agree near-term priorities while capacity is limited.

## Key Takeaways

- Graeme met AfrikaBurn's acting EDO (production manager Christie / Christy — **verify** spelling) who supported incremental progress and indicated access to a GIS layer for containers and camp placement. That report does **not** by itself clear Decision 012's formal-grant gate.
- Tim Doyle (participant relations manager, formerly ITC) shared org framework material and described timing as good for alignment. He suggested inviting Scheepers ("Skippy") — former ITC architect, now in Amsterdam — to join the group.
- Ryan has fully separated: forked the repo and builds independently. Beyers partitioned his prior work into this team's codebase. Parallel contribution remains optional, not a dependency.
- Finlay argued prioritizing compulsory / org-linked processes (registrations, GIS, plug-and-play financial planning) over non-compulsory internal camp tools (tent planning, shift allocations).
- Graeme restated a large-camp accountability idea: camps over ~30 people (he also said "or maybe 20") or over ~R100k should submit working budgets via the app, plus POPIA sign-offs per member. Surfaced, unratified — does not change `PNP-009` (>20) without a separate decision.
- Codebase shape restated: three portals sharing a core backend (camp leads, suppliers, AfrikaBurn admin).
- Participants agreed to reconvene in about three weeks after reviewing specifications and the financial plan.

## Aligned (as of the meeting)

- Graeme will schedule a meeting with Havon (**verify** spelling) from AfrikaBurn IT, via Tim Doyle, to understand org architecture and explore integration.

## Topics

### AfrikaBurn engagement and GIS

- Graeme reported meetings with the acting EDO (production manager Christie/Christy) and with Tim Doyle.
- Acting EDO: support in baby steps; access to a layer of GIS assistance for moving containers and placing camps was indicated (second-hand report; formal grant still outstanding — Decision 012).
- Tim Doyle: new title participant relations; formerly ran ITC; shared framework material for what AfrikaBurn is developing; suggested reaching out to Scheepers ("Skippy").

### Ryan's departure and repository posture

- Beyers: Ryan headed technical direction as a passion project; resisted group direction on payment gateways and architecture; intends to build his own vision; not pliable to working-group steering. The team forked / partitioned the existing work for continued use.
- Graeme: Ryan prefers working alone (health recovery noted as context); remains willing to try integrating requested features into *his* fork if asked. Parallel paths are acceptable; no obligation either way.
- Beyers noted Pride Musvaire had been interested previously and was deterred by Ryan's behaviour; with Ryan outside the picture, Pride may rejoin.

### Priorities: compulsory vs internal

- Finlay: with org planning cycles spinning up, prioritize compulsory or org-linked work — theme-camp registration, GIS, plug-and-play financial planning — and defer non-compulsory internal tools (tent planning, shift allocations) until later as bolt-ons.
- Rohan: upweight friction points that are uniform across camps (e.g. WAP); uniform authentication / single sign-on matters if camps build adjacent tools.
- Graeme: camp financials, WAP allocation, hire-tent occupancy vs onboarding lists, and templated operational roles / shifts remain high-value from a camp-ops view; also wants camp-leads-forum participation for community mandates.

### Plug-and-play / financial transparency (unratified)

- Graeme: rather than treating all camps as bad actors, require large camps (over 30 people — or maybe 20 — or budget over ~R100k) to place working budgets in front of the org via the app, plus POPIA sign-offs for members. Hard evidence over optics.
- Corpus baseline remains `PNP-009` (>20 participants). The 30-person figure is a surfaced-unratified candidate only.

### Container Project, village materials, capacity

- Finlay: will drive the Container Project from an existing user-stories-focused specification; needs a developer or code reviewer (not vibe-coded alone into production).
- Rohan: will package existing village project materials into a consumable specification; capacity limited for the next ~2–3 months.
- Ruchir: product rollout ~5 October; little capacity for ~3–4 weeks; will review Graeme's financial plan when ready.
- Graeme: Mad Hatters village (~eight–nine joining camps) needs the Container Project working; longer personal timeline toward a 2028 anniversary show.

### Codebase structure

- Beyers: three portals, shared core backend — theme-camp leads (incl. onboarding), suppliers, AfrikaBurn administration panel (categories, etc.). Originally framed for eventual org handover; org is also building its own systems, so adoption of the admin portal remains an open question.

## Next Steps (as of the meeting)

These were operational follow-ups at the time of the meeting. This corpus no longer tracks tasks; they are recorded here only as historical context.

- Graeme: contact Scheepers ("Skippy"); arrange meeting with Havon via Tim Doyle; engage org on integration alignment; share GitHub / docs once Finlay packages URLs.
- Finlay: draft questions for the org; lead Container Project from the existing user-stories spec; prepare URLs / technical docs for stakeholder briefing (incl. Scheepers).
- Rohan: review codebase / existing specs; package village materials into a shareable specification; share project link with Graeme.
- Ruchir: review Graeme's financial plan when capacity allows.
- Group: reconvene in ~three weeks.
