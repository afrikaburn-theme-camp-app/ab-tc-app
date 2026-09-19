# 2026-09-10 Graeme — Payment and Portal Vision Clarification

## Source
- Direct messages from Graeme Allan, 2026-09-10 (WhatsApp).
- Raw text pasted below verbatim, including original typos, for source fidelity. Do not treat wording as authoritative spec language — see Summary for the interpreted points.

## Summary
- Container Project dashboard: camps need visibility into the final movement order and the costs charged by/owed to the outside service operator — explicitly *not* payment-gateway fees or other costs. (Container Project is an external app to be integrated later — see [Decision 004](../decisions-record/decision-004-accepted-first-demonstrable-slice-placement-and-container-management.md).)
- Erf allocation: once a project's erf number is allocated/agreed/accepted at submission stage, it should be able to auto-propagate across other apps/plugins that need it for logistics (Gas, water delivery, wood delivery, etc.). Flagged in the spec as needing clarification — see [Section 13](../app-specification.md#13-afrikaburn-map-and-erf-placement).
- Portal architecture: the Container module (and others) should sit inside the Quagga Portal / generic app being developed. Vision is a single user-friendly interface where all apps are plug-ins — project management, buying an AB ticket, WAP allocation, budgeting/finance — eventually working seamlessly with the AfrikaBurn Org backend.
- Governance: doesn't want the group to become the "sellers" of the system to AfrikaBurn — wants to approach the organisation as a group, with Graeme and Bayes involved in the presentation process (he originated the concept).
- Payments: the platform does not need to build/operate payment gateways itself — it needs to support gateways being embedded/connected per app or module, so a camp can bring its own payment provider or banking system. See [Decision 009](../decisions-record/decision-009-proposed-payment-direction-tracking-vs-gateway.md).
- International payments (funds moving from overseas into South Africa) are called out as difficult — flags a need to research gateways that work well internationally. Not actioned yet.
- Once a gateway is connected to a module, that module should track the full onboarding-and-payment lifecycle together: who registered, who completed what, who paid, who owes, what payment maps to which service, and where each person is in the process. Considers this one of the biggest sources of admin pain if solved well.
- Bigger vision: Container Project, Gas Project and other services become modules of one larger portal/app, with a single login giving access to Burner profile, ticket purchase, Creative Group/Theme Camp creation, project registration, member management, and all other modules — see [Decision 010](../decisions-record/decision-010-proposed-ticketing-scope-quicket-vs-camp-module.md) re: ticket purchasing implications.
- Camps/Creative Groups should be able to customise which modules they use, add their own plugins/integrations, and potentially build their own modules.
