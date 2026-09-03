---
name: to-tickets
description: Slice already-settled bindings into tracer-bullet implementation tickets with blocking edges. Use when the human wants ticket files; the source is whatever they passed (a spec, a path, or this conversation).
disable-model-invocation: true
---

Project the source into **tickets**: **tracer bullet** vertical slices, each declaring the tickets that **block** it. Tickets add session bounds and order; they do not compile a second contract.

There must be a **source**. The human supplies it: a path, title, or URL, or this conversation. Do not classify the source. If they passed nothing and this conversation has no settled bindings, ask for a source. Do not search `.scratch` or `.notes`. Do not create `.scratch`. Do not compile a spec in this skill.

**Write path.** If they named a write directory, use it. If the source path is a `spec.md` inside `.scratch/<effort>/`, write `issues/<NN>-<slug>.md` in that same effort (layout). `NN` starts from `01`; skip numbers already used in that folder. If the source is this conversation and they named no write directory, ask where to write.

If a source file has pointers, follow them to each binding's source file. Do not copy spec sections or decision Answer bodies onto the ticket. If ticket AC and the spec conflict, the spec wins.

```
.scratch/<effort>/
  map.md
  spec.md
  issues/
    <NN>-<slug>.md
```

## Vertical slices

Each slice cuts a narrow but complete path through every layer (schema, API, UI, tests): **vertical**, not a horizontal slice of one layer. A completed slice is demoable or verifiable on its own. **What to build** is the end-to-end behaviour this ticket makes work, not a layer-by-layer list.

**Wide refactors** are the exception. A wide refactor is one mechanical change (rename a column, retype a shared symbol) whose blast radius fans across the whole codebase, so a single edit breaks thousands of call sites and no vertical slice can land green. Sequence it as **expand–contract**: expand (add the new form beside the old); migrate call sites in batches (each batch its own ticket blocked by the expand); contract (delete the old form in a ticket blocked by every migrate batch). When even the batches cannot stay green alone, they share an integration branch and all block a final integrate-and-verify ticket.

Prefactoring that makes the change easy is a slice of its own and comes first when the human approves it. Do not explore the codebase as a required step.

## Process

### 1. Load the source

Load what the human passed, or use this conversation. Follow planning pointers on it.

**Done when** Outcome, Observable behavior, Acceptance, Out of scope, and Uses (if any) are in hand, or the human has been asked for a source.

### 2. Draft slices

Every spec acceptance criterion is owned by at least one ticket. Each ticket has What to build, a checklist implied by the spec, `Blocked by`, and `Uses *` as pointers this slice consumes.

**Done when** that coverage holds on the draft list.

### 3. Ask once

Show a numbered list: title, Blocked by, Acceptance. Ask whether granularity, edges, merge/split are right. Iterate until the human approves.

**Done when** the human has approved the list.

### 4. Publish

Write the approved tickets from the template. Blockers first so edges can use real titles. No `Type:` on implementation tickets. No upstream → `None`.

A prototype snippet that encodes a locked decision more precisely than prose may sit inside What to build, trimmed to the decision-rich parts.

Report the paths and titles written. Leave the source file unchanged.

**Done when** each approved slice exists at that path with the template fields filled, or the human has been asked where to write.

<implementation-ticket-template>

# <NN> — <title>

**Blocked by:** None | <upstream titles>
**Uses decisions:** None | <upstream decision titles>
**Uses research:** None | <upstream research titles>
**Status:** ready-for-agent

## What to build

<this slice's observable increment; a trimmed prototype snippet may sit here>

- [ ] <acceptance implied by the spec>

## Answer

</implementation-ticket-template>
