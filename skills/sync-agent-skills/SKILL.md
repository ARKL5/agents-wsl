---
name: sync-agent-skills
description: 管理当前 OS 的 .agents 工作树：改 skill、装外部 skill、拉仓、把共享 skill 收到 Windows。仅用户点名。
disable-model-invocation: true
---

# Sync agent skills

当前 OS 的 `~/.agents` 是本侧工作树。参数决定分支：点名 skill、优化或改 → **改**；装外部 skill → **装**；只说同步或未点名 → **同步**。多条都点则按 改 → 装 → 同步。

共享集合：仓库根 `shared-skills.txt`。共享 skill 的来源是 WSL 仓。本侧所有家从 `~/.agents/skills` 加载 skill；外部 skill 也只落这里。

## 改

在本侧 `~/.agents` 改点名的 skill。先列出工作区已有改动，留下无关项。

共享 skill：一次提交只含一个 `skills/<skill>/**` 与必要协议文件；说明为 `shared(<skill>): ...`。平台专属 skill 走自己的提交。用户点名才提交。

写盘后跑 `uv run tools/check.py`。

完成：点名 skill 已改；校验已跑；无关脏文件仍在则列出。

## 装

点名来源和 skill 名。未点名先问。落点只有 `~/.agents/skills/<name>/`。

1. **列包。** `npx skills add <source> -l`。完成：要装的名字在列表里。
2. **写入。** 在 `~/.agents` 下执行 `npx skills add <source> --skill <name> -g -y`。只装点名的那一个，不用 `--all`。安装器可能顺手在产品家目录写下 symlink 或副本（例如 `-a grok` 会建 `~/.grok/skills`）；装完扫一遍，那些路径里若出现该 skill 就删，只留 `~/.agents/skills/<name>/`。`.skill-lock.json` 随安装更新。完成：磁盘上该 skill 只有这一处。
3. **各家能看见。** 本侧正在用的家都从 `~/.agents/skills/<name>` 发现它。Grok：非本仓目录跑 `grok inspect --json`，`source.path` 是这一处。Agy：`~/.gemini/config/skills.json` 的 `entries` 含绝对路径 `/home/ark/.agents/skills`（没有就写上；`~` 它不认）。Codex / Pi / OpenCode 官方会扫 `~/.agents/skills`。完成：每家现查都对上这一处，且没有第二份。
4. **名单。** 默认不进 `shared-skills.txt`（平台专属）。用户点名共享才加。提交规则同 **改**。
5. **校验。** `uv run tools/check.py`。

完成：点名 skill 在 `~/.agents/skills/<name>`；各家现查来自这一处；校验已跑；无关脏文件仍在则列出。

## 同步

在本侧 `~/.agents` 跑 `uv run tools/sync.py`。

有 `wsl` remote 时，脚本把 `wsl/main` 上的共享名单、协议文件和名单里每个 skill 检出到本侧，有改动则提交 `sync: shared set from wsl/main`。然后 `tools/check.py`。

完成：以脚本输出为准。
