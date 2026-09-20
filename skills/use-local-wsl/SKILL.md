---
name: use-local-wsl
description: Use when a task touches .wslconfig, wsl.conf, or WSL secrets; Windows paths, wslpath, or .exe; mixed-port proxy, Fake-IP, localhost, or CLIProxyAPI; wslview or OpenCLI; or uv, mise, Node, pnpm, agent CLIs, or global npm on this WSL machine.
---

# Use Local WSL

Conventions live in the topic files. Live versions, ports, and paths: [`scripts/query.sh`](scripts/query.sh) (`--help` for topics).

## Read the matching topic

| Branch | File | Query |
| --- | --- | --- |
| identity, `.wslconfig` / `wsl.conf`, secrets, Docker, restart | [`references/LOCAL_WSL.md`](references/LOCAL_WSL.md) | `wsl`, `docker` |
| path translation, `.exe` | [`references/WINDOWS_INTEROP.md`](references/WINDOWS_INTEROP.md) | |
| proxy, Fake-IP, CLIProxyAPI | [`references/NETWORK_PROXY.md`](references/NETWORK_PROXY.md) | `network` |
| open URL/file, OpenCLI / Chrome | [`references/BROWSER_ROUTING.md`](references/BROWSER_ROUTING.md) | `browser` |
| managers, install channels, Node/Python | [`references/INSTALL_POLICY.md`](references/INSTALL_POLICY.md) | `python`, `node`, `tools` |
| user-named contract audit | 对侧 `use-local-windows` `references/AUDIT.md` | `summary` |

Missing declared project runtimes: [`scripts/prepare-runtime.sh`](scripts/prepare-runtime.sh) `<repo>`.

Done when each in-scope file is read, `query.sh` has been run for its Query topics, and the run follows those files plus the rules below.

## Always

- Linux work and repos in WSL; Windows tools via absolute `/mnt/c/.../*.exe` and `wslpath`.
- Open a URL or local file for the user with `wslview`.
- Skills 本侧工作树 `/home/ark/.agents`；各 agent 从 `/home/ark/.agents/skills` 加载 skill.
- Back up `.wslconfig` / `wsl.conf` before edits. Distro restart only when the user authorizes interruption.

Finish after the command ran in the intended environment and `query.sh` (or the command's own check) confirmed state.
