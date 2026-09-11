# Contributor Covenant Code of Conduct

## Our Pledge

We as members, contributors, and leaders pledge to make participation in our
community a harassment-free experience for everyone, regardless of age, body
size, visible or invisible disability, ethnicity, sex characteristics, gender
identity and expression, level of experience, education, socio-economic
status, nationality, personal appearance, race, religion, or sexual identity
and orientation.

We pledge to act and interact in ways that contribute to an open, welcoming,
diverse, inclusive, and healthy community.

## Our Standards

Examples of behavior that contributes to a positive environment for our
community include:

- Demonstrating empathy and kindness toward other people
- Being respectful of differing opinions, viewpoints, and experiences
- Giving and gracefully accepting constructive feedback
- Accepting responsibility and apologizing to those affected by our mistakes,
  and learning from the experience
- Focusing on what is best not just for us as individuals, but for the
  overall community

Examples of unacceptable behavior include:

- The use of sexualized language or imagery, and sexual attention or advances
  of any kind
- Trolling, insulting or derogatory comments, and personal or political
  attacks
- Public or private harassment
- Publishing others' private information, such as a physical or email
  address, without their explicit permission
- Other conduct which could reasonably be considered inappropriate in a
  professional setting

## Engineering practices — kind, not just nice

The standards above set the floor: what is never acceptable. This section
sets the practice we aim for day to day in code review, issues and pull
requests — adapted from [Kind Engineering](https://kind.engineering/), whose
opening framing is worth keeping in mind throughout:

> "Kind is about being invested in other people, figuring out how to help
> them, meeting them where they are." — Tanya Reilly

**Be kind, not just nice.** Politeness alone can wave a problem through to
avoid an awkward conversation; kindness means being invested enough in a
contributor's growth to give them the honest feedback that helps them
improve. **Honesty creates trust** — say what you actually think, with care,
rather than a comfortable half-truth. **Challenge directly, care
personally**: pair honest feedback with genuine empathy — say specifically
what worked, what didn't, and what a concrete next step looks like. A vague
approval helps no one; neither does an unqualified "this is wrong."

**In code review:**

- **Understand the why, not just the how.** Review with curiosity: ask
  open-ended questions ("what led you to this approach?") rather than
  making strong-form statements about what's wrong.
- **Don't assume malice or ineptitude.** Assume missing context first, and
  ask for it, rather than correcting as if the author should have known
  better.
- **Label nitpicks as nitpicks.** Prefix optional, stylistic suggestions
  with `nit:` so the author can tell them apart from what's blocking. Where
  a style rule can be enforced by a linter instead of a comment, prefer
  that — see `.eslintrc`/`prettier` in this repo.
- **Switch to sync when a thread gets long.** If a review thread runs past
  a few back-and-forths, move to a real-time conversation (a call, or the
  project's chat — see `AGENTS.md`) rather than litigating it in public
  comments. Summarize the outcome back on the PR afterward so the written
  record stays complete.

**For psychological safety:**

- **Ask for feedback before giving it.** Modelling "what went well, what
  went poorly, what should we repeat" invites the same honesty back.
- **Be inclusive, and amplify quieter voices.** Not everyone's best
  feedback arrives live in a meeting or a comment thread in the moment —
  make room for written follow-ups and asynchronous review.
- **No blame culture.** An individual mistake is usually also a process,
  tooling, or environment gap. Investigate root causes, not scapegoats —
  "we succeed together, we fail together."
- **Reframe failure as learning.** "The cost of failure is education"
  (Devin Carraway) — an incident or a broken build is worth a calm,
  blameless retro, not a search for who to blame. This project's own
  `AGENTS.md` §Verification already treats a wrong assumption caught late
  as something to learn from and document, not something to punish.

**Receiving feedback**: know your own preferences (public/private,
written/verbal) and say so; listen and thank before you respond; take a
beat before reacting rather than answering while defensive; ask for
specifics or an example if a comment is too vague to act on.

**Giving feedback**: account for how the review will land, not just how
it reads to you when you write it; show your reasoning, not just your
conclusion; be specific enough that praise feels earned and criticism
feels actionable; where you can, suggest a concrete next step rather than
only naming the problem.

## Enforcement Responsibilities

Community leaders are responsible for clarifying and enforcing our standards
of acceptable behavior and will take appropriate and fair corrective action in
response to any behavior that they deem inappropriate, threatening, offensive,
or harmful.

## Scope

This Code of Conduct applies within all community spaces — this repository's
issues, pull requests and discussions, and any other forum this project
officially uses — and also applies when an individual is officially
representing the community in public spaces.

## Enforcement

This project does not yet publish a standing conduct email address. Report an
incident by:

- Opening a **private** [GitHub security advisory](../../security/advisories/new)
  on this repository (the same private-reporting path `SECURITY.md`
  describes), or
- Contacting one of the maintainers listed in [`MAINTAINERS.md`](MAINTAINERS.md)
  directly.

All complaints will be reviewed and investigated promptly and fairly. All
community leaders are obligated to respect the privacy and security of the
reporter of any incident.

## Enforcement Guidelines

Community leaders will follow these Community Impact Guidelines in
determining the consequences for any action they deem in violation of this
Code of Conduct:

### 1. Correction

**Community Impact**: Use of inappropriate language or other behavior deemed
unprofessional or unwelcome in the community.

**Consequence**: A private, written warning, providing clarity around the
nature of the violation and an explanation of why the behavior was
inappropriate. A public apology may be requested.

### 2. Warning

**Community Impact**: A violation through a single incident or series of
actions.

**Consequence**: A warning with consequences for continued behavior. No
interaction with the people involved for a specified period of time. This
includes avoiding interactions in community spaces as well as external
channels. Violating these terms may lead to a temporary or permanent ban.

### 3. Temporary Ban

**Community Impact**: A serious violation of community standards, including
sustained inappropriate behavior.

**Consequence**: A temporary ban from any sort of interaction or public
communication with the community for a specified period of time.

### 4. Permanent Ban

**Community Impact**: Demonstrating a pattern of violation of community
standards, including sustained inappropriate behavior, harassment of an
individual, or aggression toward or disparagement of classes of individuals.

**Consequence**: A permanent ban from any sort of public interaction within
the community.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant][homepage],
version 2.1, available at
https://www.contributor-covenant.org/version/2/1/code_of_conduct.html.

Community Impact Guidelines were inspired by
[Mozilla's code of conduct enforcement ladder][mozilla].

The "Engineering practices" section is adapted from
[Kind Engineering](https://kind.engineering/).

For answers to common questions about this code of conduct, see the FAQ at
https://www.contributor-covenant.org/faq. Translations are available at
https://www.contributor-covenant.org/translations.

[homepage]: https://www.contributor-covenant.org
[mozilla]: https://github.com/mozilla/diversity
