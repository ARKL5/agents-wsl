# 本机 CLIProxyAPI 接入事实

身份以本机 use-local 为准。host:port 从 Windows `config.yaml` 现查。OpenAI 兼容路径是 `/v1`；Anthropic 是根路径。CPA Usage Keeper 是用量看板（Management API），不配进 Agent。

## 请求转换

Windows 根配置保持 `disable-image-generation: "passthrough"`。普通请求由客户端决定是否声明 `image_generation`；代理不注入、不删除。专用 `/v1/images/*` 仍按服务策略。

用途：文本客户端走无图片权限的 Codex API-key group 时，避免代理追加 `image_generation` 导致 403。验证发不含图片工具的最小 `/v1/responses`，看出站工具类型未新增图片工具或请求成功。429 `usage_limit_reached` 是上游额度，不是该策略能修的。

## 客户端密钥

只把 Windows 配置顶层 `api-keys` 分给本机客户端。恰有一个就用；不是一个则只报数量并请用户选，值一律 `<redacted>`。

不用这些当客户端密钥：`remote-management.secret-key`、`openai-compatibility` 凭据、`claude-api-key` / `codex-api-key` / `xai-api-key`、`auths/`。

读写 key 走进程内 YAML/JSON/TOML；不进 stdout、shell 字面量、补丁、临时明文。权限检查只报 mode。Linux 新文件 `0600`；Windows 以 ACL 为准，不拿 drvfs mode 当证据。

## 预检

- 管理页 200：服务存活。
- 带客户端 key 的 `/v1/models` 200：认证和目录可用。
- 端到端最小请求：目标协议适配成功。
