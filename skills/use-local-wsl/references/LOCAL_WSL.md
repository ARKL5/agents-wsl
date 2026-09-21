# Local WSL Facts

## Stable identity

| Item | Value |
| --- | --- |
| Windows user | `ARK\38993` |
| Default distro | `Ubuntu`, WSL 2 |
| Linux user | `ark` |
| Linux home | `/home/ark` |
| Main code root | `/home/ark/CODE` |
| Skills 本侧工作树 | `/home/ark/.agents` |
| Skills Windows 工作树 | `/mnt/c/Users/38993/.agents` |

**WSL/Windows/Ubuntu 版本号、CPU/内存/swap**：[`../scripts/query.sh`](../scripts/query.sh) `wsl`。

## Configuration paths

- Windows: `C:\Users\38993\.wslconfig` ↔ `/mnt/c/Users/38993/.wslconfig`
- Linux: `/etc/wsl.conf`

**现行内容以文件为准**（读文件，勿背文档）。意图约定（改前先对照 live）：

- `.wslconfig`：`networkingMode=mirrored`，`autoProxy=false`，`dnsTunneling=true`；memory / processors / swap 以文件为准。processors 少于本机逻辑核，留给 Windows 前台。
- `wsl.conf`：`systemd=true`；`interop.enabled=true`，`appendWindowsPath=false`

意图是否仍在生效：[`../scripts/query.sh`](../scripts/query.sh) `wsl`（pid1/systemd、`appendWindowsPath`、`networkingMode`、`processors-vs-host`）。

## User shell secrets

`/home/ark/.env.secrets`（mode `600`）是 WSL 用户 shell 凭据的单一来源；`~/.config/wsl-env.sh` 加载它（由 `~/.bashrc` / 非 bash 的 `~/.profile` 引入）。systemd / Docker / Windows 应用各有自己的凭据存储。现查 [`../scripts/query.sh`](../scripts/query.sh) `shell`（`env_secrets_mode`、`secrets_dir`；只报名与 set/unset）。

增删轮换：保持无关变量；客户端只引用 `${NAME}`；报告名与 set/unset，不回显值；用新 login shell 与最小鉴权调用验证。

## Docker

| Item | Value |
| --- | --- |
| Client | `/usr/bin/docker` |
| Socket | `unix:///var/run/docker.sock` |
| Compose | `docker compose` |
| User | `ark` ∈ `docker` |
| Daemon proxy | drop-in 与 `NO_PROXY` 见 [`NETWORK_PROXY.md`](NETWORK_PROXY.md) |

客户端/服务端版本：[`../scripts/query.sh`](../scripts/query.sh) `docker`。`docker pull` 是否走代理看 daemon 环境，不看当前 shell。

## Applying changes

改 `.wslconfig` 或 boot/interop 前先备份该文件。完整生效通常要 distro 重启；在 WSL 内跑的 agent **不得**自行 `wsl --shutdown`，除非用户明确授权中断。

点名压缩虚拟盘：用户授权中断后，在 Windows 上停发行版再 `diskpart compact` 那个 `ext4.vhdx`。不要压 swap VHDX。服务停在 Stopping 时重启 `WSLService`，不要 unregister。
