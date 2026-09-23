---
name: use-local-wsl
description: Use when a task on this WSL machine touches Windows paths, wslpath, or .exe; wslview; or uv, mise, Node, pnpm, agent CLIs, or global npm.
---

# Use Local WSL

Conventions live in the topic files. Live versions, ports, and paths: [`scripts/query.sh`](scripts/query.sh) (`--help` for topics).

## Read the matching topic

| Branch | File | Query |
| --- | --- | --- |
| path translation, `.exe` | [`references/WINDOWS_INTEROP.md`](references/WINDOWS_INTEROP.md) | |
| managers, install channels, Node/Python | [`references/INSTALL_POLICY.md`](references/INSTALL_POLICY.md) | `python`, `node`, `tools` |
| 点名才读 | `.wslconfig` / `wsl.conf`、secrets、Docker、重启 → [`references/LOCAL_WSL.md`](references/LOCAL_WSL.md)（`wsl`、`docker` 或 `shell`）；代理、Fake-IP → [`references/NETWORK_PROXY.md`](references/NETWORK_PROXY.md)（`network`）；WSL Chrome → [`references/BROWSER_ROUTING.md`](references/BROWSER_ROUTING.md)（`browser`）；合同巡检 → 对侧 `use-local-windows` `references/AUDIT.md`（`summary`） | 格内注明的那一个 |

Done when each in-scope everyday file is read and its Query has been run. 点名才读只打开被点名的那一份，并跑它注明的 query。随后遵循该文件和下面的规则。

## Always

- Linux work and repos in WSL; Windows tools via absolute `/mnt/c/.../*.exe` and `wslpath`.
- Windows 用户 `ARK\38993`，家目录 `C:\Users\38993`。本侧用户 `ark`，家目录 `/home/ark`，代码根 `/home/ark/CODE`。发行版 Ubuntu（WSL 2）。
- 升级和巡检只覆盖这里的命令行工具和运行时。通道以外的软件，含 Windows 上的图形应用，用户自己装、自己升级。
- Open a URL or local file for the user with `wslview`.
- Skills 本侧工作树 `/home/ark/.agents`，Windows 工作树 `/mnt/c/Users/38993/.agents`。各 agent 从 `/home/ark/.agents/skills` 加载 skill。改这棵树走 `sync-agent-skills`。
- Back up `.wslconfig` / `wsl.conf` before edits. Distro restart only when the user authorizes interruption.

Finish after the command ran in the intended environment and `query.sh` (or the command's own check) confirmed state.
