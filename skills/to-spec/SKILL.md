---
name: to-spec
description: "Turn the current conversation into a spec: no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a spec. Synthesize what you already know.

**Where the spec physically lives.** Read [spec-operations.md](spec-operations.md).

The source is this conversation, or a path the user passed. If they passed one, fetch it and follow its title links to the files that hold the bindings.

Publish only when every observable behavior has checkable acceptance. Otherwise **stop** and list the missing bindings.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations. Seams choose where to test. If a seam answer would redraw observable behavior or out of scope, **stop** and list that as missing.

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

<the seams confirmed in step 2>

</spec-template>

Write only the sections in the template.

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it under **Observable behavior** and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.
