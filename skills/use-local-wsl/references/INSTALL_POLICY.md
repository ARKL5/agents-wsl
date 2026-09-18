# Install policy

本机运行时与全局包的合同。端口和版本现查，不写在这里。

## Python

- 项目环境与第三方 CLI：`uv` / `uv tool`。
- 系统 `/usr/bin/python3` 只承载发行版包。用户包不进 `/usr/local/lib/python3.*/dist-packages`，也不在 `/usr/local/bin` 留下 `#!/usr/bin/python3` 入口。
- 不引入第二套管理器：pyenv、conda、poetry、pipx、Homebrew。

## Agent CLIs（有官方二进制才换）

| 命令 | 装法 | 落点 |
| --- | --- | --- |
| `claude` | `curl -fsSL https://claude.ai/install.sh \| bash` | `~/.local/share/claude` |
| `opencode` | `https://opencode.ai/v2/install`，`--no-modify-path`；更新 `opencode upgrade --method curl` | `~/.opencode/bin` |
| `grok` / `codex` | 各自官方安装器 | 现查 |

`~/.local/bin/opencode` 与 `opencode2` 指向 `~/.opencode/bin/opencode`（真二进制）。官方同目录 shim 用 `$0` 找邻居，经 `~/.local/bin` 会自递归。

`pi` 官方入口是 npm（`--ignore-scripts`），不换二进制。更新 `pi update --self`。

## Node

- 只有 nvm 这一套。默认保持当前已装的那一个版本；需要第二个版本时用项目 `.nvmrc`，不改 default 双轨。
- 全局 npm **只许** `pi`（`@earendil-works/pi-coding-agent`）和 `opencli`（`@jackwener/opencli`）。随 Node 的 `npm` / `corepack` 保留。一次性命令用 `npx` / 项目依赖。

## Java

- 不装 JDK / `javac`。若 apt 因别的依赖留下 `openjdk-*-jre-headless`，那是依赖，不是开发环境。

## 卫生（巡检时认，日常安装时避开）

工序在 Windows `use-local-windows` 的 `references/AUDIT.md`。runner：[`../scripts/audit-live-check.sh`](../scripts/audit-live-check.sh)。

- 家目录下顶层只有 `skills/` 的产品点目录先列为待核实；确认内容是安装器批量复制的残留后再删。不要动 `~/.agents`。
- `/usr/local/bin` 与 `/usr/local/lib/docker/cli-plugins` 里指向已卸软件的断链（例如旧 Docker Desktop、已消失的盘符上的 VS Code）删掉。
