---
name: sync-agent-skills
description: 把 ARK-skills 分发到两侧农场。仅用户点名。仅 WSL 有效。
disable-model-invocation: true
---

# Sync agent skills

只在 WSL 点名有效。Windows 点名：告诉用户去 WSL 跑，不代跑。

工作副本路径以 `use-local-wsl` 为准（`/home/ark/CODE/ARK-skills`）。两侧 `~/.agents/skills` 只接收。

## Sync

1. 工作副本 `git pull`
2. `uv run /home/ark/CODE/ARK-skills/scripts/deploy.py`
3. `uv run /home/ark/CODE/ARK-skills/scripts/hygiene.py`

任一步失败即停，把 stderr 给用户。

**完成：** pull 已完成；清单内目录已覆盖两侧农场；卫生（派生 yaml、Claude 映射、摘错误链接）已跑通，或已把失败输出给你。

Create、收编、watch 上游见仓库 [`MAINTAIN.md`](/home/ark/CODE/ARK-skills/MAINTAIN.md)。禁止在农场 `mkdir`。
