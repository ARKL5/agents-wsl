---
name: to-spec
description: Compile already-settled bindings into one observable spec. Use when the human wants a spec file; the source is whatever they passed (a map, a path, or this conversation).
disable-model-invocation: true
---

Compile already-settled bindings into one loadable **spec**: an observable contract. Do not interview. Do not start a grilling round. The spec is a projection, not a restatement of answers.

There must be a **source**. The human supplies it: a path, title, or URL, or this conversation. Do not classify the source. If they passed nothing and this conversation has no settled bindings, ask for a source. Do not search `.scratch` or `.notes`. Do not create `.scratch`.

**Write path.** If they named a write path, use it. If the source path is a `map.md`, write `spec.md` in that same directory (layout, not classification). If the source is this conversation and they named no write path, ask where to write.

If a source file has pointers (`Uses decisions`, title links, ADRs, glossary), follow them to each binding's source file before compiling. Do not re-plan.

If you cannot write checkable acceptance for every observable behavior, **stop**. List the missing bindings. Wait. Do not name other skills.

```
.scratch/<effort>/
  map.md
  spec.md
  issues/
    <NN>-<slug>.md
```

Write only the sections in the template. Copy `Effort state` from the map header only when writing into a directory that already has that map.

## Process

### 1. Load the source

Load what the human passed, or use this conversation. Follow planning pointers on it.

**Done when** the source is in hand, or the human has been asked for one.

### 2. Compile

**Uses decisions** is an index of title links — gist nothing a ticket already holds. **Outcome** is one or two lines. **Observable behavior** is the compiled contract: what an observer sees when the outcome holds. **Acceptance** is checkable sentences derived from those behaviors. Every behavior gets at least one; a behavior with no checkable sentence is missing — stop, do not publish. **Out of scope** is what the source already ruled out.

**Testing seams.** If the source already has seams, write them; do not ask. If it has none, ask **once** (prefer existing seams, highest, as few as possible; the ideal number is one). If the human omits, omit the section. Seams only choose where to test. If a seam answer would redraw the outcome, observable behavior, or out of scope, stop and list that as missing — do not publish.

A prototype snippet that encodes a locked decision more precisely than prose (state machine, reducer, schema, type shape) may sit inside Observable behavior, trimmed to the decision-rich parts.

**Done when** every behavior has checkable acceptance, Testing seams is written or omitted, and the spec introduces no new product forks — or the run has stopped with missing bindings listed.

### 3. Publish

Write `spec.md` at the write path.

**Done when** that file exists with the sections above, or the human has been asked where to write.

<spec-template>

# <title>

Effort state: active

## Uses decisions

- [<decision title>](link)

## Outcome

<one or two lines>

## Observable behavior

<the compiled contract>

## Acceptance

- [ ] <checkable sentence derived from an observable behavior>

## Out of scope

<ruled beyond the outcome>

## Testing seams

<where this feature is tested; omit this section when there are none>

</spec-template>

