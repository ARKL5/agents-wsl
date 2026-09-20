# Install policy

谁管什么、装法和白名单。版本与是否已装：[`../scripts/query.sh`](../scripts/query.sh) `python` / `node` / `tools`。缺的已声明运行时：[`../scripts/prepare-runtime.sh`](../scripts/prepare-runtime.sh)。

## 谁管什么

| 种类 | 管理器 | 落点 |
| --- | --- | --- |
| Python 运行时、项目环境、锁文件 | `uv` | 项目 `.venv` / `uv.lock` / `.python-version` |
| 独立 Python CLI | `uv tool` | `~/.local/bin` |
| Node 与其他非 Python 运行时 | `mise` | `~/.config/mise/config.toml` |
| 新 Node 项目的包管理器版本 | `package.json` 的 `packageManager`（mise 读取） | 项目内 |
| 项目构建/测试/格式化 | 项目依赖 | 该项目的锁文件 |
| 用户级 Node CLI（白名单） | 当前 mise Node 上的 `npm -g` | 随该 Node 前缀 |
| 有官方二进制的 agent CLI | 各自官方安装器 | 下表 |
| 系统组件、编译工具链、原生库 | apt | 发行版 |
| 临时一次性命令 | `npx` / `uvx` / `mise exec` | 用完即走 |

mise `auto_install` 与 uv `python-downloads` 以本机配置为准（`query.sh` 现查）。准备阶段显式安装已声明的运行时。

Python 只由 uv 管理。系统 `/usr/bin/python3` 只承载发行版包。

已有项目保留原工具链和锁文件。

## Node

- 用户级默认是 LTS 线（`mise latest node@lts`），不是 Current。
- 新项目默认 pnpm；版本权威是 `packageManager`。Corepack 保持未 enable。
- `.nvmrc` / `.node-version` 由 mise 读取，原样留给已有项目。
- 全局 npm **只许** `pi`（`@earendil-works/pi-coding-agent`）和 `opencli`（`@jackwener/opencli`）。随 Node 的 `npm` / `corepack` 二进制保留。
- `pi`：`npm install -g --ignore-scripts`；更新 `pi update --self`。
- `opencli`：`npm install -g --allow-scripts=@jackwener/opencli`（npm 11 默认拦住脚本）。

## Agent CLIs（有官方二进制才换）

| 命令 | 装法 | 落点 |
| --- | --- | --- |
| `claude` | `curl -fsSL https://claude.ai/install.sh \| bash` | `~/.local/share/claude` |
| `opencode` | `https://opencode.ai/v2/install`，`--no-modify-path`；更新 `opencode upgrade --method curl` | `~/.opencode/bin` |
| `grok` / `codex` | 各自官方安装器 | 现查 |

`~/.local/bin/opencode` 与 `opencode2` 必须指向 `~/.opencode/bin/opencode`（真二进制）。官方同目录 shim 经 `~/.local/bin` 会自递归。

渠道以该工具官方安装/更新为准。`/usr/local/bin/uv` 与 `/usr/local/bin/codex` 是指向用户级安装的非登录 PATH 入口。

## Java 与其他语言

不预装。项目约束需要时，在该项目里用 mise 声明并跑 `prepare-runtime.sh`。发行版留下的 `openjdk-*-jre-headless` 是依赖，不是开发环境。

## Docker

原生 Docker Engine（apt）。

## 卫生

合同巡检：对侧 `AUDIT.md`；live 用 [`../scripts/query.sh`](../scripts/query.sh)。

- 家目录下顶层只有 `skills/` 的产品点目录：确认是安装器残留后再删。`~/.agents` 留下。
- `/usr/local/bin` 与 `/usr/local/lib/docker/cli-plugins` 里指向已卸软件的断链删掉。
