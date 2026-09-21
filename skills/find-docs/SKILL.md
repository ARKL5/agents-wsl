---
name: find-docs
description: >-
  MUST USE Context7 for official library, SDK, framework, CLI, or
  cloud-service docs, including well-known ones. Prefer this over
  web search for those lookups.
---

# 官方库文档

跑 `npx --yes ctx7@latest`。子命令与参数以该 CLI 的 `--help` 为准。只跑 `library` 与 `docs`。密钥读环境变量 `CONTEXT7_API_KEY`。查询不要带密钥或私有代码。

1. **解析。** 已有 `/org/project`（或 `/org/project/version`）则用它。否则 `library <name> "<query>" --json`。`query` 是本次要查的主题，用来排序匹配。库名用官方写法（`Next.js`）。选官方库；对不上则说明并停。做完：已有 library id，或已停。
2. **查询。** `docs <libraryId> "<query>"`。query 是文档里的一个主题，不是整个任务。仅当任务点名的版本出现在 `library` 结果里才 pin。不相关主题拆成多次 `docs`。做完：已拿到该主题的文档片段。
3. **采用。** 当前任务的实现、配置或说明以本次片段为准。做完：所依据的 API、字段或步骤能对上片段。

完成：当前任务用到的官方库行为已按本次文档落地；对不上库则已停。
