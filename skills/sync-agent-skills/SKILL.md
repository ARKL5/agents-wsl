---
name: sync-agent-skills
description: 管理当前 OS 的 .agents 工作树：改 skill、拉仓、把共享 skill 收到 Windows。仅用户点名。
disable-model-invocation: true
---

# Sync agent skills

当前 OS 的 `~/.agents` 是本侧工作树。参数决定分支：点名 skill、优化或改 → **改**；只说同步或未点名 → **同步**。两条都点则先改再同步。

共享集合：仓库根 `shared-skills.txt`。共享 skill 的来源是 WSL 仓。

## 改

在本侧 `~/.agents` 改点名的 skill。先列出工作区已有改动，留下无关项。

共享 skill：一次提交只含一个 `skills/<skill>/**` 与必要协议文件；说明为 `shared(<skill>): ...`。平台专属 skill 走自己的提交。用户点名才提交。

写盘后跑 `uv run tools/check.py`。

完成：点名 skill 已改；校验已跑；无关脏文件仍在则列出。

## 同步

在本侧 `~/.agents`：

1. 报告工作区改动，不因此停下。
2. `git pull --ff-only`。Git 因本地改动拒绝则记下，继续还能做的。
3. Windows：`git fetch wsl`（remote `ARKL5/agents-wsl`）。列出尚未收下的 `shared(<skill>): ...`。每条先看路径：只含一个共享 skill 与必要协议文件则 `git cherry-pick`；混入平台专属则跳过该条并报告；已有相同变更则跳过。冲突停在那一条，留给人，并列出其余未挑的。
4. `uv run tools/check.py`。

完成：pull、已收下的 shared 提交、跳过与冲突、校验、仍脏的文件，都能从报告对上。
