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

## Raw message text

What we do need to do is give them a dashboard to be able to see the final movement order and the costs that are charged or given to the outside service operator and rhe amount due to them. They need a full view of thwy movement order not rhe payment gate way fees or adult orher costs.

And also the ability for them to allocate the project theor erf number thatbis needed for placement and logistics planning to move the vontainer ro the camp erfs the right time or if the system allows for their project when placed to be updated. This can be done in the submission stage and when allocayed and agreed or accepted by the Themwcamp / village, it could automatically be assigned across the many apps or plugins that need th3 allocated wrf number alile the Gas, watwe delkver wood delivery etc. The Container app pr module should be in the Quagga Portal or generic App that we develop. For me I see all the applications we design to all be plug-ins and accesible in a user friendly interface that allows for all things to interact with the Org and for project management, buying your AB ticket. WAp allocation ,budgeting finance etc. Eventually that seemless works with AB Org backend.

Make sense?

---

Hi folks,

I think it would be a good idea for us to have an alignment meeting sometime next week, just to make sure we're all clear on what we're actually trying to build and how we want to work together.

From where I'm sitting, there are two main things we need to align on:

**The broader organisational project**

Ryan, you've fleshed out something that seems to be very close to what the organisation is looking for and may ultimately want to implement, and you're going to be presenting that to them.

I'd like both Bayes and myself to be part of that process. I don't agree with us becoming the "sellers" of the system, because that creates all kinds of complications at AfrikaBurn. If we're developing this as a group, I think we need to approach the organisation as a group as well.

This is also something I originally initiated and have been developing conceptually, so I'd very much like to remain involved in how it evolves and how it is presented.

**Payments and the bigger app vision**

For clarity, I don't think we necessarily need to build or operate the payment gateways ourselves. What we do need is the ability for payment gateways to be embedded or connected to the different apps or modules.

For example, a Theme Camp may want to use its own payment provider or banking system, and we should allow for that. At the same time, getting payments from overseas into South Africa can be extraordinarily difficult, so we definitely need to investigate which payment gateways work well internationally and make sure the system can integrate with them.

Importantly, once a payment gateway is connected to a particular app or module, that module should be able to track the whole onboarding process alongside the payments — who has registered, who has completed what information, who has paid, who still owes money, what payment relates to which service, and where each person is in the process.

As you know, onboarding and keeping track of payments is possibly one of the biggest bugbears there is. If the system can solve that properly, it becomes enormously valuable.

My bigger vision is that the Container Project, Gas Project and the other services we are developing eventually become modules within one larger portal/app.

Ryan, I think this is ultimately where your design is heading as well, or at least that's my understanding.

At AfrikaBurn, one of the problems for participants is that information and services are scattered everywhere. It can be incredibly difficult to know where to go or how to access something.

I'd love to see a future system where a person has one login and can access their Burner profile, buy tickets, create or join a Creative Group or Theme Camp, register projects, manage members, organise containers, gas and other services, and access whatever additional modules they need.

Creative Groups or Theme Camps could then customise what they use, add their own plugins or integrations, and potentially even develop their own modules where necessary.

The same principle would apply to payments. A camp or project could connect its own payment gateway, while the relevant module manages the workflow around it — onboarding, payment requests, payment status, member allocation and administration — without us necessarily having to receive or control the money ourselves.

So, for example, when someone is invited into a Theme Camp or project through their personal portal login, the system could immediately show what they need to complete, what they need to pay, whether they have paid it, and what they now have access to.

That, to me, is where the real usefulness of integrating everything starts to become apparent.

I'd like us to discuss whether this is, in fact, the shared vision before we go too far down separate paths.

Maybe I'm misunderstanding parts of what everyone is proposing, which is exactly why I think an alignment meeting would be useful.

It would be great to make sure we're all actually building towards the same thing.

What do you guys think?

I've also shifted the payment concept slightly so it's clear that the real value isn't simply having a payment gateway — it's the app knowing who has onboarded, who has paid, what they paid for, and what still needs attention.
