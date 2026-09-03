---
name: sync-agent-skills
description: 管理当前 OS 的 .agents Git 仓库，并校验/同步共享 skills。仅用户点名。
disable-model-invocation: true
---

# Sync agent skills

当前 OS 的 `~/.agents` 是本侧 Git 仓库，也是实际生效的 skills 工作树。WSL 与 Windows 各自维护自己的仓库；不从另一侧覆盖目录。

## 日常同步

1. 进入当前 OS 的 `~/.agents`。
2. 检查工作树；有未提交修改就停止并报告。
3. 执行 `git pull --ff-only`。
4. 执行 `uv run tools/check.py`（Windows 可用本机 uv）。

共享集合见仓库根的 `shared-skills.txt`。共享提交只允许修改一个 `skills/<skill>/**` 与必要协议文件；平台专属 skill 不得混入。

## 共享同步（仅 Windows）

共享 skill 的 canonical 来源是 WSL 仓库。

1. `git fetch wsl`（remote 为 `ARKL5/agents-wsl`）。
2. 列出尚未应用到本仓的 `shared(<skill>): ...` 提交。
3. 审查每个提交的路径：只允许一个 `skills/<skill>/**` 与必要协议文件；混入平台专属 skill 则停止。
4. 逐条 `git cherry-pick`；冲突立即停止，不 stash、不覆盖、不自动解决。已有相同变更则跳过。
5. 再执行 `uv run tools/check.py`。

## 完成标准

工作树干净、pull 成功、校验通过；共享同步时还必须说明 fetch 的提交、路径审查结果和 cherry-pick 结果。

不要运行旧 ARK-skills 的 `deploy.py`/`hygiene.py`，它们已停用；不要把 `.agents` 当作只接收目录。
