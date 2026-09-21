---
name: sync-agent-skills
description: 管理本侧工作树：改 skill、装外部 skill、同步。
disable-model-invocation: true
---

# Sync agent skills

本侧工作树是 `~/.agents`。点名 skill、优化或改 → **改**；装外部 skill → **装**；同步或拉仓 → **同步**。多条都点则按 改 → 装 → 同步。

共享名单：`shared-skills.txt`。共享 skill 来源是 WSL 工作树。各家从 `~/.agents/skills` 加载。

## 改

在本侧 `~/.agents` 改点名的 skill。先列出工作区已有改动，留下无关项。共享 skill 两侧工作树写同一份。

提交、推送仅当用户点名。共享 skill 一次提交只含一个 `skills/<skill>/**` 与必要协议文件，说明 `shared(<skill>): ...`；平台专属走自己的提交。

写盘后跑 `uv run tools/check.py`。

完成：点名 skill 已改；共享 skill 则两侧已是同一份；校验已跑；无关脏文件仍在则列出。

## 装

点名来源和 skill 名。未点名先问。点名项目则落到该项目 `.agents/skills/<name>/`；否则 `~/.agents/skills/<name>/`。

1. **列包。** `npx skills add <source> -l`。完成：要装的名字在列表里。
2. **写入。** 本侧：在 `~/.agents` 下 `npx skills add <source> --skill <name> -g -y`。项目：在该项目根下 `npx skills add <source> --skill <name> -y`。只装点名那一个。装完其它位置若出现该 skill 的副本或 symlink 则删，只留选定 `.agents` 这一处。`.skill-lock.json` 随安装更新。完成：磁盘上该 skill 只有这一处。
3. **本侧收尾。** 仅本侧：默认不进 `shared-skills.txt`，用户点名共享才加（准入见 `docs/adr/`）；提交规则同 **改**；跑 `uv run tools/check.py`。项目跳过。完成：本侧已校验，或本步已跳过。

完成：点名 skill 在选定落点；本侧则校验已跑；无关脏文件仍在则列出。

## 同步

在本侧 `~/.agents` 跑 `uv run tools/sync.py`。完成：以脚本输出为准。
