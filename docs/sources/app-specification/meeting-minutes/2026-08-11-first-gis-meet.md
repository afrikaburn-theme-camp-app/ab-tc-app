# 2026-08-11 First GIS meeting

## Source
- Meeting: participant theme camp i.t/ai solution, discussion — 11 August 2026 (~31 min).
- Attendees: Graeme Allan, Kshetra Govindasamy. Tim Doyle was expected; did not join.
- Recorded via Fathom. The summary below is interpreted from that transcript.
- Transcript wording is **not** authoritative spec language. Speaker attribution in the Fathom export is noisy in places.

## Terminology
In the meeting the Theme Camp App was referred to as "Ryan's app". Ryan James Noble has left the team. New writing in this corpus uses **Theme Camp App** (Quagga Portal).

## Meeting Purpose

To explore integrating a theme camp's custom app with the org's GIS system.

## Key Takeaways

- Graeme's team is building an app ecosystem to automate camp admin (placement, budgeting, shift lists), aiming to solve major org-side bottlenecks like late placement (3 weeks pre-event) and poor communication (e.g., gas protocol changes).
- The app's core feature—a spatial placement tool—requires integration with the org's new GIS system, which Kshetra confirmed is accurate to within a meter, making the integration technically viable.
- The integration will use open-source standards (Postgres, Leaflet) and a shared GitHub repo to ensure compatibility and foster collaboration under the "Each One Teach One" principle.
- Graeme proposed using the app to enforce accountability for large camps (>20 people or >R100k budget) by requiring budget/roster submissions, a method to counter the "plug-and-play" culture.

## Topics

### Theme Camp Challenges & Proposed Solution

- Problem: The org's slow processes create major operational challenges for theme camps.
    - Late Placement: Camps receive final placement only ~3 weeks before the event, preventing effective collaboration and causing on-site space issues.
    - Poor Communication: Critical protocol changes are not communicated, creating safety risks and operational failures (e.g., 30 gas bottles unusable due to unannounced piping changes).
    - Admin Burden: Camp leads spend up to 4 months/year on manual admin.
- Solution: An app ecosystem to automate camp operations and improve org-camp communication.
    - Core Features: Placement tool, budgeting, shift lists, onboarding, payment gateways.
    - Placement Tool: Enables camps to design ideal layouts and submit them as GIS data, allowing the org to quickly place the entire configuration.

### Org's GIS System & Integration Path

- Org's GIS System:
    - Accuracy: Confirmed accurate to within a meter, making it suitable for precise placement.
    - Status: A new, standalone system built over 2–3 years, replacing old Photoshop/Premiere Pro workflows.
    - Data: Contains ground-truthed time-series data for streets, boundaries, and past camp layouts.
- Integration Path:
    - Standards: Use open-source, international standards (Postgres, Superbase, Leaflet) to ensure compatibility.
    - Workflow: Camp app → Submits GIS data (e.g., GeoJSON) → Org places block → Org sends back final coordinates.
    - Collaboration: Use a shared GitHub repo to foster joint development and align with the "Each One Teach One" philosophy.

### Addressing "Plug-and-Play" Culture

- Context: Widespread concern about "plug-and-play" camps undermining community values.
- Proposal: Use the app to enforce accountability for large camps (>20 people or >R100k budget).
    - Requirement: Mandate budget and roster submissions.
    - Enforcement: Enable random checks (e.g., phone calls) to verify roster accuracy.
    - Rationale: This creates a high barrier to entry for bad actors, making compliance the easier path.

## Next Steps (as of the meeting)

These were operational follow-ups at the time of the meeting. This corpus no longer tracks tasks; they are recorded here only as historical context.

- Kshetra: discuss the proposal with Hevon and Roger; email Graeme technical specs for the org's GIS system.
- Graeme: forward those specs to the camp's development team; schedule a follow-up with Kshetra, Hevon, Tim, and Brad.
