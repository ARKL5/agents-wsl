---
name: use-local-wsl
description: Use when a task touches .wslconfig, wsl.conf, or WSL secrets; Windows paths, wslpath, or .exe; mixed-port proxy, Fake-IP, localhost, or CLIProxyAPI; wslview or OpenCLI; or uv, nvm, agent CLIs, or global npm on this WSL machine.
---

# Use Local WSL

Versions, proxy ports, and resource numbers **live-check**; attachments hold paths,
conventions, and how to discover state — not version ledgers.

## Read the matching topic

Open the file for each branch in scope:

- [`references/LOCAL_WSL.md`](references/LOCAL_WSL.md) — identity, `.wslconfig` / `wsl.conf`, secrets, Docker, restart
- [`references/WINDOWS_INTEROP.md`](references/WINDOWS_INTEROP.md) — path translation, `.exe`
- [`references/NETWORK_PROXY.md`](references/NETWORK_PROXY.md) — proxy discovery (`scripts/discover-proxy.sh`) and per-layer files
- [`references/BROWSER_ROUTING.md`](references/BROWSER_ROUTING.md) — open URL/file, OpenCLI / Chrome
- [`references/INSTALL_POLICY.md`](references/INSTALL_POLICY.md) — runtimes and the global-npm allowlist
- 对本机对照合同巡检 → `/mnt/c/Users/38993/.agents/skills/use-local-windows/references/AUDIT.md`；步1–3 runner [`scripts/audit-live-check.sh`](scripts/audit-live-check.sh)。本 skill 不展开全表。

Done when each in-scope file is read and this run follows those files plus the hard rules below.

## Hard rules

- Linux work and repos in WSL; Windows tools via absolute `/mnt/c/.../*.exe` and explicit `wslpath` (WINDOWS_INTEROP).
- Open URLs/files with `wslview` (BROWSER_ROUTING).
- Docker identity: LOCAL_WSL. Egress layers and `no_proxy`: NETWORK_PROXY.
- Runtimes, uv, nvm, agent CLIs, global npm: INSTALL_POLICY.
- 本侧工作树是 `/home/ark/.agents`；各 agent 从 `/home/ark/.agents/skills` 加载 skill。
- Back up `.wslconfig` / `wsl.conf` before edits. Distro restart only when the user authorizes interruption.

Finish only after the command ran in the intended environment, paths resolved there, and state was verified with live checks (not skill-cached versions).
