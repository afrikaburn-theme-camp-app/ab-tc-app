# Camp roles and officers

| Field                  | Value                                                  |
| ---------------------- | ------------------------------------------------------ |
| **Category**           | Product                                                |
| **Doc status**         | Active                                                 |
| **Normative language** | Descriptive only                                       |
| **Requirement IDs**    | Partial — `SEC-001, SEC-002, SEC-005–SEC-010, SEC-012` |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                           |

Beyond the structural `lead`/`admin`/`member` roles, a camp can define its
own **custom roles** (organisational labels) and is assigned **officer
roles** by AfrikaBurn when its registration data triggers one (e.g. a
declared sound level requiring a Sound Officer).

## Implements (App Specification)

| App Spec §                   | IDs                                                                          | Status | Notes                                                                                                                   |
| ---------------------------- | ---------------------------------------------------------------------------- | ------ | ----------------------------------------------------------------------------------------------------------------------- |
| §19 Permissions and security | SEC-001 (camp lead), SEC-002 (camp administrator), SEC-010 (camper)          | ✅     |                                                                                                                         |
| §19                          | SEC-005 (build captain), SEC-006 (strike captain), SEC-007 (functional lead) | 🚧     | A camp can create the custom-role label; there is no build/strike-specific semantics attached to it beyond the label    |
| §19                          | SEC-003 (Village lead)                                                       | ❌     | Villages are not built — see [`19-creative-projects.md`](19-creative-projects.md)                                       |
| §19                          | SEC-004 (Treasurer), SEC-008 (Shift lead)                                    | 🚧     | Same evidence as SEC-005–007 (a custom-role label); glyph should be consistent with those three, not marked differently |

## Custom project roles

Structural roles (`lead | admin | member`) govern permissions and are
unchanged. On top, each project (camp, artwork or mutant vehicle — the
mechanism is shared, see [`19-creative-projects.md`](19-creative-projects.md))
can define **custom roles**: labels used for organisation and questionnaire
audiences. A member can hold multiple custom roles.

- Schema: `project_roles` (group_id, name, is_default, sort, kind, color,
  emoji, `permissions` jsonb), `member_role_assignments`
  (membership_id × project_role_id).
- **Role kinds** (`captain | baseline | default | custom`):

  | Kind                           | Rename     | Permissions              | Delete        | Assignment                                                      |
  | ------------------------------ | ---------- | ------------------------ | ------------- | --------------------------------------------------------------- |
  | `captain`                      | alias only | locked to all privileges | never         | normal                                                          |
  | `baseline` (seeded "Burner")   | alias only | editable                 | never         | implicit — every member holds it, derived, cannot be unassigned |
  | `default` (seeded "Team lead") | yes        | editable                 | never         | normal                                                          |
  | `custom`                       | yes        | editable                 | yes (cascade) | normal                                                          |

- **Privileges** a role can carry: `view_member_details`,
  `manage_questionnaires` (scoped to configured audience roles, with an
  optional `may_block` flag), `assign_roles`, `manage_roles`,
  `manage_members`. No camp privilege ever overrides a burner's own privacy
  flags or the hard-locked bio fields.
- **Structural roles are the permission backstop**: `lead`/`admin` hold
  every permission irrevocably, so no permission edit can ever strand a
  camp — the anti-lockout invariant.
- Cap 20 roles per project; deleting a custom role is a confirm-with-count
  cascade (assignments removed, memberships untouched).

## Officer roles — org-defined, condition-triggered

Officer roles are a distinct `officer` role kind: an org-defined catalogue
per edition, each with a stable key (an org-wide targeting anchor — the
display name/emoji/color may be aliased by the camp, the key never
changes) and a trigger condition over the camp's registration data:

| Key                   | Seeded as         | Trigger                                    |
| --------------------- | ----------------- | ------------------------------------------ |
| `lnt_officer`         | LNT Lead ♻️       | always required                            |
| `safety_officer`      | Safety Officer ⛑️ | always recommended                         |
| `fire_safety_officer` | Safety Baron 🔥   | always required for registered camps       |
| `sound_officer`       | Sound Officer 🔊  | required when the declared sound level ≥ 2 |
| `safety_monitor`      | Safety Monitor 🛡️ | recommended                                |

Requirement is soft-enforced — an unassigned required officer shows as an
outstanding-officers count badge on the camp's settings page and on the
review screen; it does not block registration submission or approval.

**Officer assignment is a consent moment, not an appointment.** Assigning
someone as an officer discloses their phone number to AfrikaBurn for that
function — since phone is otherwise hard-locked private, acceptance requires
the member's explicit consent, with copy stating what is shared and why.
Declining leaves the slot unassigned. `officerContactVisibleToOrg` is the
sole gate for this disclosure, and it is false for any pending or declined
assignment.

Officers cannot be aliased (the org-facing vocabulary stays uniform across
camps, unlike custom-role labels). Free camps: officers are entirely
optional — triggers apply only to camps with an in-flight or approved
registration.

## Surfaces

`/camps/[slug]/settings/roles` — a dedicated, full-page settings screen
(not a sidebar or popover): three sections in order — Officers, Core Roles,
Custom Roles — each role row expandable (accordion), one expanded at a
time. The members list keeps only quick operations: role chips + a
multi-select quick-assign + a link to the settings screen.

## Invariants and tests

Anti-lockout (`isPermissionBackstop`), the escalation clause
(`roleGrantsElevatedPrivileges`), and officer-consent gating
(`officerContactVisibleToOrg`) are covered in
`packages/core/src/__tests__/{project-permissions,project-roles,officers}.test.ts`.
