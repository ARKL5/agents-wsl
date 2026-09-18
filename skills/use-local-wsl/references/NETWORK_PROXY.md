# Local WSL Network Proxy

代理 **host:port 与是否在听：现查**。本文件只固定**配置落点**与诊断顺序。

## Discover endpoint

跑 [`../scripts/discover-proxy.sh`](../scripts/discover-proxy.sh)。不要把端口写回本文件。

确认 `~/.profile`、`~/.bashrc` 仍 source 该文件。进程名以现查为准。

`no_proxy` / `NO_PROXY` **只有** `localhost`、`127.0.0.1`、`::1`。WSL 出网进 mixed 口；国内直连与否由 Clash 规则决定，不在 WSL `no_proxy` 里表达。

## Tool layers（查文件，不背端口）

| Consumer | Where to look |
| --- | --- |
| Shell | `~/.config/proxy-env.sh` + profile/bashrc |
| APT | `/etc/apt/apt.conf.d/80proxy` |
| Git HTTP(S) | 通常继承 shell；无则查 git config |
| GitHub SSH | `~/.ssh/config`（`ProxyCommand` / `nc -x`） |
| Node | 继承 shell；可有 `NODE_USE_ENV_PROXY` |
| Docker daemon | `/etc/systemd/system/docker.service.d/http-proxy.conf`（`HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY`）；**不等于** shell 变量 |
| WSL Chrome | `/usr/local/bin/wsl-chrome` + [`BROWSER_ROUTING.md`](BROWSER_ROUTING.md) |
| WinINet / WinHTTP | Windows 侧现查；与 WSL shell 独立 |

Shell 有代理不能证明 systemd/Docker/构建已走代理。

## Windows / WSL net intent

`.wslconfig` 键在 [`LOCAL_WSL.md`](LOCAL_WSL.md)。本文件管出网层和 `no_proxy`。各层 Linux 配置（shell / APT / SSH / dockerd）自写 mixed 口；WSL userland 进 mixed 口，不走 Windows Mihomo TUN。关 `autoProxy` 要发行版重启才完全生效。

## Local CLIProxyAPI

Windows 跑唯一实例；WSL 经 mirrored 回环用它。接入或更新走 `cli-proxy-api`。安装根与计划任务以该 skill 的脚本为准；监听从 Windows `config.yaml` 现查。

## Tool fetch / Fake-IP

Clash Fake-IP answers public names with `198.18.0.0/15`. Clients that send the hostname to the mixed port still work. Tools that resolve first and then SSRF-block "private" ranges fail even when the proxy is healthy.

When a fetch tool reports SSRF / private IP in `198.18.0.0/15`:

1. Confirm the same URL via curl through the discovered mixed port.
2. Treat it as Fake-IP vs that tool's SSRF list, not as a dead proxy.
3. Per-tool allowlist lives with the tool, not in `no_proxy`. Pi: restore via `configure-harness` `assets/pi-web-access/reapply-adaptation.sh`. Grok uses `web_search` (Responses API); `web_fetch` is not a repair surface.

## Verification order

1. 跑 `scripts/discover-proxy.sh`。巡检用 `scripts/audit-live-check.sh`。  
2. 目标进程环境或专属配置层。  
3. 做一次有范围的请求并观察是否经代理（例如 curl 的 peer 地址）。
4. 若工具报 `198.18` SSRF：走上面的 Fake-IP 顺序，不要先改 `no_proxy` 或 TUN。

不要把现查到的端口写回本文件。
