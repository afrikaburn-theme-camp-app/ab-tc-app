# GIS / spatial-data research

| Field                  | Value                                                              |
| ---------------------- | ------------------------------------------------------------------ |
| **Category**           | Planning                                                           |
| **Doc status**         | Draft                                                              |
| **Normative language** | Descriptive only                                                   |
| **Requirement IDs**    | N/A — external-GIS research, not spec-derived                      |
| **Owner / Updated**    | Beyers Nel, 2026-09-19                                             |

Research notes from the two GIS meetings with AfrikaBurn spatial planning
([2026-08-11](../sources/app-specification/meeting-minutes/2026-08-11-first-gis-meet.md),
[2026-09-09](../sources/app-specification/meeting-minutes/2026-09-09-second-gis-meet.md)).
This is **not** a built-feature spec. Operational decisions live in App Spec
Decision Records 011, 012, and 016. Engineering HOW, when it exists, will
live in [`../engineering-decisions/`](../engineering-decisions/README.md).

The **Container App** is a standalone existing app, separate from the Theme
Camp App. It manages everything to do with a camp's shipping containers:
buying one, ordering one, having it moved, having it placed on site, and
moving it offsite to storage — it is **not limited to placement**. This
document records only **integration concerns** with it (2027: the
container-placement slice) and with AfrikaBurn's GIS. Its internals are out
of scope.

## Org GIS landscape

- AfrikaBurn has spent 2–3 years migrating mapping off Photoshop / Premiere
  Pro onto a standalone GIS. Kshetra Govindasamy owns the mapping workstream.
- The working desktop environment is **QGIS**. Data is being moved from AWS
  onto a **local on-prem Postgres server at the AfrikaBurn office**, with
  per-layer user security (Kshetra, Havon, Roger, Tim on the org side).
- Layers already collected: town infrastructure, theme-camp and art
  placements, drainage, contours, high-resolution imagery. Theme-camp
  boundaries will shift somewhat this cycle.
- Accuracy claimed "within a meter". On-the-ground GPS (QField) is "fit for
  purpose" but not survey-grade — Roger's caution: the tool is a planning
  aid, not a complete fix-all once you are on the dust.

## Agreed access model (as of 2026-09-09)

- The Theme Camp App team is to receive **read-only access to specific
  vector layers**, starting with theme-camp boundaries.
- Writes do **not** go back into the org's GIS directly. Layouts / updates
  are sent to AfrikaBurn for **manual re-integration**. The org stays
  system of record so their layers are not corrupted.
- "Maybe not an API for now" — simple access first, scale later. This GIS
  access thread is **not** the Theme Camp App's platform API / MCP (Decision
  005).
- Roger committed to granting access within 1–2 weeks of 2026-09-09. Access
  has **not** been formally granted as of this writing; Decision 012 stays
  `proposed` until it is.

## Data provenance

- **Elevation is a DEM from drone photogrammetry, not LIDAR.** Corrected
  twice on the record (Roger). AIS (Integrated Aerial Solutions) flies an
  overlapping image grid; photogrammetry reconstructs 3D. Small undulations;
  better than broad contours, still a fairly rough model.
- Drainage lines are algorithmically derived from the DEM (lowest points).
  Checked on the ground during the 2026 event and described as pretty good;
  they still shift and need updating.
- High-res imagery covering the site is on the order of **16 GB** for a
  single image. Spatial planning has been requesting a high-end local
  machine to work these rasters in real time; not yet received as of the
  meeting.
- Sand dunes / habitability: currently a next-cycle layer. Imagery analysis
  is not enough — sites need walking. Dunes were described as pretty stable
  at the last site visit (rooting systems holding them); grass is expected
  to disappear in another year or two and the dunes to go back to sand.
  Time-series imagery is planned this season to capture land shift.
- QField is the org's mobile capture tool for ground-truthing.

## Integration workflow (direction, not a contract)

From the Aug-11 meeting, the intended round-trip:

1. Camp designs a preferred layout and submits it as GIS data (GeoJSON-class
   standardised geospatial formats were named).
2. Org places the block.
3. Org sends final coordinates back.

From the Sep-9 meeting, the 2027 container-placement slice:

1. Camp receives its allocated boundary as a vector file.
2. Camp places preset objects (rectangles for containers, circles, lines)
   inside that boundary.
3. Tool generates a layout plan for submission.

Frontend libraries in the Leaflet / OpenStreetMap class were named as
compatible options. Backend storage on the org side is Postgres (Supabase
was mentioned in August as a likely combination; September described a
local on-prem Postgres instead — treat the hosting as unsettled, the
format as Postgres/PostGIS-class).

A shared open-source GitHub repo was proposed in August under "Each One
Teach One". Not yet stood up.

## Implications for `LAYOUT-*` / `ERF-*`

- DPW is to supply final shapes and sizes for containers and other
  infrastructure. Kshetra also has access to Pretoria GIS engineers with
  preset vector libraries. Those may become the **authoritative
  object-geometry source** for the objects in App Spec §11 (`LAYOUT-001–043`)
  rather than the Theme Camp App inventing them.
- Theme-camp boundary vectors are the input the layout / container tools
  need; the rest of the org GIS (imagery, DEM, drainage) is context, not a
  2027 deliverable.
- Block sizes are irregular (examples given earlier: 120 m × 60 m,
  95 m × 60 m, some as small as 50 m). Layouts have to sit at true scale
  inside an assigned block, often sharing it with other camps.
- Cross-module erf propagation (once allocated, push the erf number to gas /
  water / wood / container logistics) remains an open ambiguity on App Spec
  §13 — see Decision 012 related notes, not this research.

## Open items (not tracked as tasks here)

- Formal grant of the read-only vector-layer access (Decision 012 gate).
- IT-team meeting on auth / architecture alignment — the org is building
  its own internal systems in parallel.
- Formal proposal to Lexi (Placements Lead) that the 2027 tool saves time
  without disrupting her workflow. Allocations currently land around
  30 January.
- DPW final container / infrastructure specs.
- Privacy review before any adoption (Roger: Yvonne, Tim, Lexi — "how there
  isn't any kind of conflict of interest around the privacy issues").

## Out of scope

- Internals of the standalone Container App.
- Building a Theme Camp App layout CAD (Decision 011, still proposed).
- Treating GIS-server access as the platform API (Decision 005).
