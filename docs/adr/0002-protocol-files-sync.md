# 协议文件随共享提交到对侧

准入词表和 ADR 是两侧共同的边界，不是 WSL 私货。cherry-pick 允许路径在 skill 与既有协议之外，加上 `CONTEXT.md` 和 `docs/adr/`。

**Code**: `tools/sync.py`

**Status**: accepted

## Considered Options

- **只留 WSL**（拒绝）：Windows 上跑 `sync-agent-skills` 的 agent 看不到准入原则。
- **写进 `sync-agent-skills` 正文**（拒绝）：把 glossary 缓存进 skill，两处会漂。
- **扩允许路径**（采纳）：与 `AGENTS.md` 同类，随共享提交收到 Windows。

把新名字写入名单的那次提交，按该提交里的名单判断是否共享（否则本侧旧名单会把这次提交跳过）。名单里本侧还没有目录的 skill，从 `wsl/main` 检出。
