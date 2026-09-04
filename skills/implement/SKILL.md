---
name: implement
description: "Implement a piece of work based on a spec, a ticket, or the current conversation."
disable-model-invocation: true
---

Implement the work described in the source. The source is this conversation, or a path the user passed. If they passed one, that file is the source; read it.

Call the Skill tool with "tdd" where possible. If the source has Testing seams, those are the pre-agreed seams; pass them when calling tdd.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Record `git rev-parse HEAD` before the first commit of this run. Commit to the current branch.

Once `HEAD` has moved past that revision, call the Skill tool with "code-review", passing that recorded revision and, when the source was a file, its path.
