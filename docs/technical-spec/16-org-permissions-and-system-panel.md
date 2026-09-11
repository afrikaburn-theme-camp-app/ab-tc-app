# Org permissions and the System panel

| Field                  | Value                                                                                                       |
| ---------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Category**           | Security                                                                                                    |
| **Doc status**         | Active                                                                                                      |
| **Normative language** | RFC 2119 / RFC 8174 applies                                                                                 |
| **Requirement IDs**    | Partial — `SEC-011, SEC-019` (App Spec §19; the department/domain permission model itself extends the spec) |
| **Owner / Updated**    | Repo maintainers, 2026-09-11                                                                                |

Console access is a **door**, not the rights: any org rank clears the gate,
but what an account may actually do is the resolved union of the org
**roles** assigned to it — data a System manager creates, not hardcoded
ranks. The model deliberately mirrors camp Roles v2 (one mental model, two
surfaces).

## Implements (App Specification)

| App Spec §                   | IDs                                          | Status | Notes                                                                              |
| ---------------------------- | -------------------------------------------- | ------ | ---------------------------------------------------------------------------------- |
| §19 Permissions and security | SEC-011 (organisation reviewer)              | ✅     |                                                                                    |
| §19                          | SEC-019 (access expiration)                  | 🚧     | Sessions and invites expire; org-role assignments and department membership do not |
| —                            | The department/domain permission model below | —      | Extends the App Spec; no section names this design                                 |

## The three ranks

| Rank                              | Reach                                                       | Depth                                                                                   |
| --------------------------------- | ----------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `org_staff`                       | The departments whose roles they hold (org-wide roles: all) | Whatever their roles grant                                                              |
| `engineer`                        | Every department, always — the console's IT rank            | Must **not** resolve `read_personal_information` or `delete`, whatever role it is given |
| `god` (rendered "System manager") | Everything                                                  | Everything, whatever any row says — the anti-lockout anchor                             |

The engineer tier is **not a superset of `org_staff`**: broader reach,
deliberately narrower depth. Given identical roles, an `org_staff` account
can read a phone number and destroy a supplier where an engineer cannot,
anywhere — an engineer who genuinely needs personal information must be
given the `org_staff` door instead, because an engineer's universal reach
with no depth ceiling would otherwise be one role assignment away from
every burner's details in every department at once.

## Departments, domains, roles

- **`org_departments`** — created by a System manager, never hardcoded.
  Creating one seeds its permanent Lead and Member roles; deleting one
  cascades them away.
- **`org_department_domains`** — _what_ each department owns. A department
  owns domain **keys** (subject areas: `registrations`, `suppliers`,
  `supplier_documents`, `questionnaires`, `bulletins`, `camp_categories`,
  `accounts`, `audit`) rather than tagged rows; an entity's department is
  whichever department owns the domain it lives in. `domain` is the
  primary key, so exactly one department owns each; a domain nobody owns
  is reachable only by an org-wide role.
- **`org_roles`** — key, label, `kind` (`system` = seeded, undeletable,
  rights-editable; `custom` = fully the System manager's own, editable and
  deletable), colour, a `permissions` JSONB object, optional
  `department_id`.
- **`org_role_assignments`** — membership × role; a person holds zero or
  more.

The two seeded system roles ("Engineer," "Org staff") carry exactly the
rights the old hardcoded ranks carried, so the change of mechanism was not
also a change of access — but they are now **defaults of a row, not law**:

| capability                                     | Engineer (seeded)        | Org staff (seeded)       | System manager |
| ---------------------------------------------- | ------------------------ | ------------------------ | -------------- |
| `read` — the whole console                     | ✅                       | ✅                       | ✅             |
| `read_personal_information`                    | ❌                       | ✅                       | ✅             |
| `write` — reviews, standings, bulletins, sends | ✅                       | ✅                       | ✅             |
| `delete` — destructive removals                | ❌                       | ✅                       | ✅             |
| `manage_camp_categories`                       | ❌                       | ❌                       | ✅             |
| `manage_accounts` — grant access, assign roles | ❌ (must not be granted) | ❌ (must not be granted) | ✅             |
| `read_system` — the System panel               | ✅                       | ❌                       | ✅             |

A System manager may edit any of those ticks, subject to the engineer
carve-out above; every edit is audited (`org.role.update`, before/after).

## Department scoping

A role scoped to a department grants its capabilities only for what that
department **owns**. Three distinct questions, three functions — using the
wrong one is the hazard: `orgCan` ("may they, anywhere?"), `orgCanIn(actor,
cap, departmentId)` ("may they, in this department?"), and
`orgCanInDomain(actor, cap, domain)` — what guards and queries actually
call, keyed on the screen, not on a department id a System manager could
change.

**Two capabilities are department-scoped**
(`DEPARTMENT_SCOPED_CAPABILITIES`): `delete` (the one destruction cannot
undo) and `read_personal_information` (the reason this scoping exists at
all — a Suppliers-department lead reads supply-related contacts and is
refused a theme camp's members). `read`/`write` are deliberately **not**
scoped — ordinary console work mostly is not filed under a department, and
confining it would make a departmental role look granted while doing
nothing.

**Personal information is enforced at the query, per domain, never in the
UI.** Every org query returning a person resolves
`canReadPersonalInformationIn(actor, domain)` before its `select`. A
refused caller's payload contains no medical notes, phone numbers,
emergency contacts, ID/passport, legal names or email addresses — not even
as an unrendered field. Consequences: account search matches on username
only for such a caller (an email match would be a lookup oracle), and the
medical-access audit panel is withheld whole for the same reason (see
[`14-audit-trail-and-medical-access.md`](14-audit-trail-and-medical-access.md)).

## Four rails that keep editable rights survivable

1. **`memberships.role = 'god'` is the anchor.** A System manager resolves
   every capability whatever the role rows say, even with zero roles or a
   role granting nothing. The `GOD_EMAILS` bootstrap still works against an
   empty `org_roles` table.
2. **The sole System manager cannot be removed or demoted.** Untouchable
   from the accounts panel in either direction; `god` is not in the
   grantable set.
3. **Only a System manager manages departments, roles or assignments** —
   guarded on the `god` anchor, never on a capability (this is the surface
   that edits capabilities). `manage_accounts` is refused to every role by
   the resolver itself, so even a hand-written row cannot escalate.
4. **Fail closed.** An account with the console door and no roles clears
   the gate and resolves nothing — stated in the UI rather than left to be
   discovered.

Named lockout tests: `apps/org/lib/__tests__/org-role-lockout.test.ts`.

## `/accounts`, `/system`, `/system/roles`

- **`/accounts`** — search users; grant/remove console access and assign
  org roles; each row shows the resolved union of a person's roles
  (including exactly what they can delete and where), audit-logged.
- **`/system`** (gated on `read_system` — engineer and System manager
  only): **System health** (a real timed database round-trip; the
  migration verdict from the same function the build calls; whether
  reference data has ever been seeded; secret/service presence, never a
  value), **Security controls** (derived from `@quagga/auth`'s own
  resolvers — see [`01-auth-and-identity.md`](01-auth-and-identity.md) —
  so this page can never report a rule the stack is not actually
  enforcing), **Org access** (who holds console access, a warning when
  only one System manager exists), **Roles and departments** (a count and
  a link into `/system/roles`), a link to `/audit`.
- **`/system/roles`** — editing what a role may do is itself "god-level
  account management." Two gates, deliberately different: **reading** needs
  `read_system` (an engineer may look — the permission model is this
  deployment's configuration, the same class of fact as the auth settings
  beside it); **changing** anything needs the `god` anchor. Deletion-impact
  data (which carries affected people's email addresses) is not queried at
  all unless the viewer is a System manager. Screens: **Departments**
  (create/rename/delete, naming every role and person affected before
  confirming), **Roles** (org-wide first, then grouped by department; a
  permanent role renders with no delete control and the reason in words,
  never a disabled button), **Assignment** (on `/accounts`, same
  resolved-union renderer). A fourth panel, **What a department owns**,
  reassigns domains between departments — a permissions change in an
  org-chart costume, System-manager-anchored and audited like every other
  rights edit.

The union arithmetic behind the table cell, the dialog preview, and the
editor preview is one pure function, `summarizeOrgActor` — the console can
never describe an access it would refuse.

**Nothing here prints a secret** — only whether one is set, and what
follows. `GOD_EMAILS` is reported as a count, never as addresses.

## Invariants and tests

`packages/core/src/__tests__/org-{permissions,roles}.test.ts`,
`apps/org/lib/__tests__/{org-role-lockout,org-rank-enforcement,medical-audit-surface}.test.ts`,
`e2e/specs/org-staff/{system-panel,engineer-rank}.spec.ts`,
`e2e/specs/god/{god-roles-management,department-domain-scoping}.spec.ts`.
