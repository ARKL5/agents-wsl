# 本机 CLIProxyAPI 接入事实

监听、版本、密钥数量、转换开关、上游凭据字段名以 [`../scripts/precheck.ps1`](../scripts/precheck.ps1) 为准。协议路径以该版本官方文档为准。CPA Usage Keeper 是用量看板，不配进 Agent。

常见坑：OpenAI SDK 的 base 含 `/v1`（precheck 的 `openai_base`）；Anthropic SDK 的 base 是 origin（precheck 的 `base`）。

## 请求转换

根配置保持 `disable-image-generation: passthrough`（precheck 现查值必须是它）。普通请求由客户端决定是否声明 `image_generation`；代理不注入、不删除。专用 `/v1/images/*` 仍按服务策略。

用途：文本客户端走无图片权限的 Codex API-key group 时，避免代理追加 `image_generation` 导致 403。验证发不含图片工具的最小 `/v1/responses`，看出站工具类型未新增图片工具或请求成功。429 `usage_limit_reached` 是上游额度，不是该策略能修的。

## 客户端密钥

客户端密钥只来自顶层 `api-keys`（precheck 的 `api_keys` 计数）。恰有一个就用；不是一个则只报数量并请用户选，值一律 `<redacted>`。其它凭据字段名见 `upstream_key_fields`。

读写 key 走进程内 YAML/JSON/TOML；不进 stdout、shell 字面量、补丁、临时明文。权限检查只报 mode。Linux 新文件 `0600`；Windows 以 ACL 为准，不拿 drvfs mode 当证据。
