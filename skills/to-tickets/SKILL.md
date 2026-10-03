---
name: to-tickets
description: "Organize an agreed large body of work into verifiable tickets with explicit dependencies."
disable-model-invocation: true
---

# To Tickets

Organize an agreed large body of work into **tickets** that another agent can pick up: each has a bounded deliverable, acceptance criteria, and explicit dependencies. The work comes from this conversation or a source path the user supplies; read the source and relevant linked decisions.

Reference existing requirements and decisions instead of rewriting the spec. Tickets add execution boundaries, verification, dependencies, and the context needed to resume.

**Where the tickets physically live.** Read [ticket-operations.md](ticket-operations.md).

## Process

### 1. Establish the basis

Inspect the relevant code and existing checks as needed to establish scope and dependencies. Use the project's domain vocabulary and respect relevant ADRs.

Resolve discoverable facts yourself; leave implementation details that do not affect the breakdown to implementation. Ask the user about unresolved choices that change scope, behavior, or acceptance before treating them as settled.

### 2. Draft work units

Use **tracer bullets** for feature work: each slice covers the layers needed for one verifiable behavior, rather than dividing the work by technical layer. Migrations, enabling capabilities, and architectural changes can be separate tickets when they have a concrete outcome and verification method.

- Bound each ticket so one agent session can complete and verify it with the supplied context.
- Declare **blocking edges** only when another ticket's result is required, not merely because it is convenient to do first.
- Make prefactoring a prerequisite only when it is necessary for dependent work.
- Account for every agreed requirement across the tickets, including integration and final verification where needed; remove gaps, duplicate scope, and work the source does not call for.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket; green is promised only there.

### 3. Review the breakdown

Present the proposed tickets as a numbered list, showing each deliverable and its blockers with the reason for each dependency. Ask the user to review scope, priorities, and granularity; revise until they approve the breakdown.

### 4. Publish the tickets

Write the approved tickets using the template below, then publish them as ticket-operations.md specifies. Publish in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers.

Leave the source unchanged.

<ticket-template>

# <NN>: <Ticket title>

**What to build:** the bounded behavior or outcome this ticket delivers, with enough context to distinguish its scope from adjacent tickets.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None (can start immediately)".

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</ticket-template>

Keep the ticket centered on its deliverable and acceptance. Reference source artifacts for established requirements and decisions; file paths can locate relevant code, and concise code can express an agreed contract when it is more precise than prose.

Complete when the approved tickets are written, collectively cover the agreed work, have verifiable acceptance criteria and acyclic blocking edges that reference existing tickets, and provide enough context and references for another agent to proceed. Return their location.
