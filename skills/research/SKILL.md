---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, or reading legwork delegated to a background agent.
---

If you are already the delegated researcher, perform the work below directly; do not spawn another agent. Otherwise, dispatch one **background researcher**, passing the question, scope, workspace, and these research requirements. You may continue other work while it reads; inspect the returned file before reporting the research complete. The caller owns any ticket or map updates.

The researcher's work:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it in `.notes/` and return the actual file path, with any unresolved questions or source gaps.

Complete when the findings file has been written and checked against the question and primary sources. A dispatch alone is not completion.
