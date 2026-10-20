---
name: use-local-wsl
description: Use when work on this WSL machine crosses Windows paths, or changes uv, mise, Node, or pnpm.
---

# Use Local WSL

Conventions live in the topic files. Live versions, ports, and paths: [`scripts/query.sh`](scripts/query.sh) (`--help` for topics).

## Read the matching topic

| Branch | File | Query |
| --- | --- | --- |
| Windows paths | [`references/WINDOWS_INTEROP.md`](references/WINDOWS_INTEROP.md) | |
| managers, install channels, Node/Python | [`references/INSTALL_POLICY.md`](references/INSTALL_POLICY.md) | `python`, `node`, `tools` |
| 升级候选或批量升级 | 本节「升级」 | 见升级节 |
| 点名 `.wslconfig`、`wsl.conf`、重启 | [`references/LOCAL_WSL.md`](references/LOCAL_WSL.md) | `wsl` |
| 点名 secrets | [`references/LOCAL_WSL.md`](references/LOCAL_WSL.md) | `shell` |
| 点名 Docker | [`references/LOCAL_WSL.md`](references/LOCAL_WSL.md) | `docker` |
| 点名代理、Fake-IP | [`references/NETWORK_PROXY.md`](references/NETWORK_PROXY.md) | `network` |
| 点名 WSL Chrome | [`references/BROWSER_ROUTING.md`](references/BROWSER_ROUTING.md) | `browser` |
| 点名环境合同 | [`scripts/query.sh`](scripts/query.sh) | `summary` 或相关主题 |

点名才读的分支只打开被点名的那一份。

## Always

- Linux work and repos in WSL; Windows tools via absolute `/mnt/c/.../*.exe` and `wslpath`.
- 本侧用户 `ark`，家目录 `/home/ark`，代码根 `/home/ark/CODE`。发行版 Ubuntu（WSL 2）。Windows 的用户、家目录、安装通道与图形应用见 use-local-windows。
- Open a URL or local file for the user with `wslview`.
- 本侧 skills 工作树 `/home/ark/.agents`。各 agent 从 `/home/ark/.agents/skills` 加载 skill。改这棵树走 `sync-agent-skills`。
- WSL system changes stay within the user's requested scope. Get explicit authorization before interrupting or restarting the distro.

## 升级

升级和巡检覆盖 INSTALL_POLICY 声明的通道，含其中的 apt 包。通道以外的本侧软件由用户自己管理。

环境合同用 [`scripts/query.sh`](scripts/query.sh)。升级候选用 [`scripts/live-check-wsl.sh`](scripts/live-check-wsl.sh)，它不刷新 APT 索引，候选版本可能滞后。自动维护只报告 unattended-upgrades 覆盖的安全源。

[`scripts/apply-wsl.sh`](scripts/apply-wsl.sh) 分两次：root 执行 APT，再以用户 `ark` 执行 mise、uv、opencli、agent-browser。只有用户授权覆盖整个脚本时才运行。Windows 侧的批量脚本见 use-local-windows。

## 完成标准

- 查询：跑完所选主题并按输出汇报异常；点名 `query.sh` 时覆盖对应行的主题。
- 变更：命令在目标环境执行，`query.sh` 或命令自带检查确认目标状态；报告异常及未验证范围。
- 本次打开的参考文档中适用于任务的完成标准均已满足。
