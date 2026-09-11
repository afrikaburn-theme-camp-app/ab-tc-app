# **📝 Notes**

Aug 6, 2026

[Original Google Doc](https://docs.google.com/document/d/16U6vC7_fKMoBiGanjzOV1afupTmJ0jdz2PN81520tcg/edit?tab=t.mi0x2xmaw1sr)

## **Tech team onboarding**

Invited Pride Musvaire, Beyers Nel, Finlay Kettlewell, Michael Hazel, Remi Bun Ooaasies, Ryan James Noble, Rohan Shackleford

Attachments Tech team onboarding (calendar event) [Notes – Tech team onboarding](https://docs.google.com/document/d/1haEa_0TWhNiaeGjfTX7GbH3EfgIGj08OYKZW9GojzAM/edit)

Meeting records [Transcript](https://docs.google.com/document/d/16U6vC7_fKMoBiGanjzOV1afupTmJ0jdz2PN81520tcg/edit?usp=drive_web&tab=t.3p78t95tho2j) 

### ***Summary***

The team reviewed development workflows, prioritized architectural simplicity, and adopted pull request stacking for code management.

**Workflow and Tooling Strategy**  
The team prioritized low-overhead management over complex tooling to ensure development efficiency. They implemented automated triage for bugs and enforced high code coverage using test requirement thresholds.

**Architecture and Design Integration**  
The infrastructure utilizes a monorepo architecture with standardized component libraries to maintain consistency. Designers will integrate with engineering workflows through autonomous branches and standardized design import protocols.

**Decision on Review Processes**  
The team decided to adopt pull request stacking to facilitate iterative development without implementing restrictive pre-commit hooks. Human oversight remains mandatory for final code sign-off to ensure quality.

### ***Decisions***

## Aligned

* **Mandatory human code review sign-off** Pull requests require final human approval to verify semantics and implementation paradigms, regardless of initial AI-driven triage or review comments.

* **Strict pre-commit enforcement postponed** Implementation of strict pre-commit hooks and automated PR size limits is postponed to allow the team to observe natural workflow requirements and mature the project first.

* **Auto-labeling pull requests for UAT** Pull requests modifying UI components will utilize code detection on specific folder paths to auto-label the request for human user acceptance testing (UAT) and include a mandatory check block.

* **GitHub issue requirement for PRs** GitHub issue creation is established as optional for active pull requests, with issues reserved exclusively for work items that are not being actively addressed.

We've **updated the Decisions section** using your feedback.

Let us know what you think: [Helpful](https://google.qualtrics.com/jfe/form/SV_5bXzKQfylMIhSXc?isHelpful=True&entryPoint=decisions&confid=IZ92aaUn72ZD5CE4EL1IDxIVOBABMgUIigIgABgDCA&isGoogler=False) or [Not Helpful](https://google.qualtrics.com/jfe/form/SV_5bXzKQfylMIhSXc?isHelpful=False&entryPoint=decisions&confid=IZ92aaUn72ZD5CE4EL1IDxIVOBABMgUIigIgABgDCA&isGoogler=False)

### ***Next steps***

- [ ] \[Rémi B.\] Message Richard: Contact Richard to join the meeting session.

- [ ] \[Ryan James Noble\] Update Vercel Access: Grant all project participants access to the Vercel preview link.

- [ ] \[Ryan James Noble\] Audit Postgres Coverage: Review the existing coverage tests to ensure the codebase remains maintainable.

- [ ] \[Ryan James Noble\] Clean API Files: Remove redundant files within the API directory.

- [ ] \[Ryan James Noble\] Audit Components: Perform a thorough check of the component library to ensure quality and consistency.

- [ ] \[The group\] Peer Review PRs: Evaluate and provide feedback on team member pull requests.

- [ ] \[The group\] Identify Website Bugs: Search for bugs and security vulnerabilities within the application to improve stability.

- [ ] \[Ryan James Noble\] Setup fuzz testing: Implement a security auditing agent to perform fuzz testing across the shared codebase.

- [ ] \[Ryan James Noble\] Research branch management: Investigate if GitHub Desktop or similar tools can facilitate branching for design work in Pencil.

- [ ] \[Rohan Shackleford\] Review project architecture: Analyze the Pencil files and existing site documentation to understand current project structures.

- [ ] \[Michael Hazell, Rohan Shackleford\] Schedule 1 on 1 meeting: Conduct a session next week to align on design workflows and architectural needs.

- [ ] \[Ryan James Noble\] Prepare grant presentation: Compile a list of suitable grant infrastructures for South African non-profit organizations into a presentation.

- [ ] \[Ryan James Noble\] Investigate organization credits: Explore available free tier or grant-funded credit options for the organization accounts.
