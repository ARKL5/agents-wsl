---
name: find-docs
description: >-
  MUST USE Context7 for official library, SDK, framework, CLI, or
  cloud-service docs — even if the user said 查/搜/look up.
  Not web research, social platforms, or "what people think".
---

```bash
npx ctx7@latest library <name> "<query>"
npx ctx7@latest docs <libraryId> "<query>"
```

At most 3 CLI calls per question, then answer from the best result.

1. **Resolve** — `library` unless the user already gave `/org/project` (or `/org/project/version`). `query` is required and ranks matches. Prefer official names (`Next.js`, not `nextjs`). Pick by name, description, snippet count, reputation, and benchmark; if nothing fits, say so.
2. **Query** — `docs` with that id and a **single-topic** lookup (what to find in the docs, not the whole task). Pin a version only if the user named one that `library` listed. Split unrelated topics into separate `docs` calls.

Library ids start with `/`. Never put secrets or proprietary code in queries.
