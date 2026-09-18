---
name: to-spec
description: "Turn the current conversation or a source document into a spec, filling in technical details from the repository."
disable-model-invocation: true
---

Synthesize the source decisions into a spec. Fill in technical details from repository evidence; ask a focused question only when a missing decision would change observable behavior, acceptance, or scope.

**Where the spec physically lives.** Read [spec-operations.md](spec-operations.md).

The source is this conversation, or a path the user passed. If they passed one, fetch it and follow its title links to the files that hold the bindings.

Give every observable behavior checkable acceptance derived from the source. Resolve blocking decisions before publishing.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Identify the public interfaces through which the specified behavior can be verified. Reuse agreed testing seams; otherwise select suitable existing interfaces from the repository. Record newly selected seams as technical proposals without a separate confirmation step. Leave test files, mocks, and helpers to implementation.

3. Write the spec using the template below, then publish it as spec-operations.md specifies.

<spec-template>

# <title>

## Observable behavior

<what an observer sees when the work is done>

## Acceptance

- [ ] <checkable sentence derived from an observable behavior; at least one per behavior>

## Out of scope

<what the source already ruled out>

## Testing seams

<interfaces through which behavior will be verified; distinguish existing agreements from technical proposals>

</spec-template>

Write only the sections in the template.

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it under **Observable behavior** and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.
