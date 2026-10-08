# 2026-09-19 Scheepers — Project abstraction notes

## Source
- Theme Camp App WhatsApp group, 2026-09-19 (Scheepers de Bruin / “Skippy”), shortly after onboarding orientation.
- Interpreted summary below; product implications for Creative Project Mode and shared modules are not yet a Decision Record.

## Summary

Scheepers reviewed the App Spec against prior AfrikaBurn ITC / TMI thinking and offered a normalisation insight: most “project” types at the Burn share structural requirements, with differences mainly in content/templates.

### Shared project types (overlap)
He named Theme Camps, Artworks, Support Camps, Mutant vehicles, Performances, Workshops, and Events as variants of a common project idea, with only minor differences between them.

### Shared submodules (examples)
- A standard **participant** submodule across project types (roles such as Creator, lead, member, volunteer).
- A standard **placement** submodule for everything except Events.
- A standard **layout** submodule for everything except (debatably) Mutant vehicles.
- Other modules identified in past project-registration runs: fire safety, fuel storage, volunteers, shifts, fundraising, sound.

### Implication
Requirements listed specifically under theme camps (budgeting, placement, volunteer management, etc.) often apply to all project types. An artwork and a theme camp may share the same budget-management requirement with different budget templates.

### Gaps he did not see in the specs
- Project management
- Resource / inventory management
- (Later, for bigger events:) incident logging and management

### Broader framing
He restated the Tribe Mobilisation Infrastructure (TMI) idea: the toolset ops need to organise AfrikaBurn is the same toolset villages and creative projects need to organise themselves — any community, project, or event.

## Related
- [App Specification §18 Creative Project Mode](../app-specification.md#18-creative-project-mode-)
- [Decision 002](../decisions-record/decision-002-proposed-architecture-integration-strategy-open-pending-org-feedback.md) (TMI Identity / org integration track)
- AfrikaBurn TMI (conceptual): https://github.com/AfrikaBurn/TMI
