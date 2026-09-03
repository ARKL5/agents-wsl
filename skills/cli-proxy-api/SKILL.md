---
name: cli-proxy-api
description: 接入或更新本机 CLIProxyAPI：客户端接入与诊断，或换 CPA / Keeper 二进制。
disable-model-invocation: true
---

# 本机 CLIProxyAPI

先读本机 use-local 里的 CLIProxyAPI 身份（WSL：`NETWORK_PROXY`；Windows：`WSL_INTEROP`）。怎么调 PowerShell 也以该合同为准。

换二进制、更新 CPA 或 Keeper → **更新**，然后结束。
否则只处理用户点名的客户端、Agent 或项目（**接入**）。

## 更新

安装根在身份文件。默认两侧；只点名一侧则只跑那侧。`-Version` / `-Force` 只给点名的一侧；未点名则两侧 latest，点了 `-Force` 则两侧都传。

同一 PowerShell 进程跑安装根里的 `update.ps1`。脚本自己做 checksum、换二进制、回滚和健康检查。`curl.exe` 不继承 WinINet：访问 GitHub 需要代理时，现查 mixed/HTTP 监听，同进程设 `HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY`；没在听则停。

任务或二进制缺失：该侧报告，不重建。退出码非零看是否已回滚；`-Force` 只在用户点名时传。一侧失败不阻断另一侧。Keeper `.env` 只报 `<redacted>`。以脚本输出为准；`LastTaskResult=267009` 表示任务仍在跑。

完成：用户能判断每一侧是否成功以及服务是否可用。

## 接入

只处理用户点名的那一个客户端、Agent 或项目。读 [`references/LOCAL_INSTANCE.md`](references/LOCAL_INSTANCE.md)。服务与带客户端 key 的 `/v1/models` 可用再改配置；失败则停并报告失败层。

写入字段以本机 `--help` / schema 或该版本官方文档为准。协议入口和 base URL 从身份文件加官方契约现查。保留已有 provider、模型角色、插件和无关设置；未指定模型则保留当前默认。

改前在同一私有配置目录做时间戳备份。密钥只从 `api-keys` 进程内解析，输出 `<redacted>`。仓库只存环境变量名或秘密引用。

验证顺序：管理页 → 模型目录 → 目标能加载配置 → 最小请求（若支持无交互）。429 当额度，403 当路由/能力。403 提到未请求的内置工具时，只比对入站/出站的模型、顶层字段和工具类型，按 LOCAL_INSTANCE 转换策略修。目标拒配置则恢复备份；配置有效而上游失败则保留配置并给出复现命令。

完成：用户能判断目标是否经本地 CLIProxyAPI 工作，并能定位或撤销本次配置。报告目标、修改文件、备份、协议入口、provider/model、各层结果；凭据 `<redacted>`。
