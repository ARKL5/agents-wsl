---
name: sync-agent-skills
description: 管理本侧工作树：改 skill、装外部 skill、同步。
disable-model-invocation: true
---

# Sync agent skills

本 skill 只在用户点名修改、安装或同步 agent skills 时使用。按 **改 → 装 → 同步** 处理同一请求中的多个动作。

共享名单由 `shared-skills.txt` 声明，WSL 工作树是来源。各 agent 从 `~/.agents/skills` 加载；Claude Code 的 `~/.claude/skills/<name>` 链接由 **同步** 维护。

## 改

在本侧 `~/.agents` 修改点名的 skill。先查看已有改动并保留无关项；共享 skill 由同步流程传播到另一侧。

提交或推送仅在用户点名时进行。共享 skill 的提交只包含该 skill 与必要协议文件，提交信息使用 `shared(<skill>): ...`；平台专属 skill 使用本侧提交。

写盘后跑 `uv run tools/check.py`。

完成：点名 skill 已改，校验已通过；共享 skill 已同步到两侧。列出仍存在的无关脏文件。

## 装

点名来源和 skill 名。未点名先问。点名项目则落到该项目 `.agents/skills/<name>/`；否则 `~/.agents/skills/<name>/`。

1. **列包与基线。** 运行 `npx skills add <source> -l`；记录选定落点、既有同名目录和链接目标。
2. **写入。** 本侧在 `~/.agents` 下运行 `npx skills add <source> --skill <name> -g -y`；项目在项目根运行不带 `-g` 的命令。只安装点名 skill，并保留 `.skill-lock.json` 的更新。
3. **清理。** 仅删除能由基线确认是本次安装新生成、且位于选定落点之外的副本或链接。删除链接前核对目标；同步维护的 Claude Code 链接、既有内容和来源不明内容均保留。
4. **收尾。** 本侧安装默认不加入 `shared-skills.txt`；只有用户点名共享且 skill 可移植、对侧确实使用时才加入。运行 `uv run tools/check.py`；项目安装跳过本步。

完成：点名 skill 位于选定落点，新增冗余已处理，校验已通过；列出仍存在的无关脏文件。

## 同步

在本侧 `~/.agents` 运行 `uv run tools/sync.py`。完成：以脚本输出和最终校验为准。
