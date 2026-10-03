---
name: research
description: Dispatch a background researcher to write cited findings in .notes/.
disable-model-invocation: true
---

# Research

Establish the question and scope from the request; ask only when an ambiguity would change the investigation.

Launch one **background research sub-agent**, passing the question, scope, workspace, and requirements below. The researcher executes them directly without further delegation. If the sub-agent cannot be launched, report the blocker.

The sub-agent's work:

1. **Investigate.** Follow material claims to the primary source that owns them: official documentation, source code, specifications, or first-party data. Distinguish what the source establishes from your inference. Missing or conflicting evidence is a finding, not permission to guess.
2. **Record.** Write one Markdown findings file in `.notes/` with source citations for each material claim, an answer to the question, and unresolved questions or evidence limits.
3. **Check.** Verify that the cited passages support the claims and that the report addresses the requested scope. Return its actual path and remaining gaps; partial research should be reported as partial.

The caller reads and checks the sub-agent's file, then reports its path, conclusion, and remaining gaps to the user without writing a second summary file. Complete when the requested question is answered with supporting evidence; report unresolved scope as partial. Dispatch alone is not completion.
