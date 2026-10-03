---
name: handoff
description: Preserve the context a fresh agent needs to continue the work.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write one handoff document in `.notes/` in the current workspace. Focus it on the next task the user names in their arguments, or on continuing the current work.

Preserve relevant goals, confirmed decisions and authorization boundaries, verified progress, unresolved questions, and the next action. Reference existing artifacts (specs, plans, ADRs, issues, commits, diffs) by path or URL; write only the context they cannot supply. Distinguish verified results from assumptions and work still pending.

Complete when a fresh agent can use the document and its references to identify where to resume, the basis for proceeding, and what still requires the user's decision. Return the document's actual path.
