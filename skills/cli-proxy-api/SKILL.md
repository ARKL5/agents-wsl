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

跑 [`scripts/update.ps1`](scripts/update.ps1)。参数以脚本为准（默认两侧 latest）。以脚本汇总为准。

完成：报告两侧版本及 HTTP 200。

## 接入

只处理用户点名的那一个客户端、Agent 或项目。读 [`references/LOCAL_INSTANCE.md`](references/LOCAL_INSTANCE.md)。先跑 [`scripts/precheck.ps1`](scripts/precheck.ps1)；失败则停并报告失败层。

写入字段以本机 `--help` / schema 或该版本官方文档为准。协议入口和 base URL 从 LOCAL_INSTANCE 与 Windows `config.yaml` 现查。保留已有 provider、模型角色、插件和无关设置；未指定模型则保留当前默认。

改前在同一私有配置目录做时间戳备份。密钥只从 `api-keys` 进程内解析，输出 `<redacted>`。仓库只存环境变量名或秘密引用。

验证顺序：precheck → 目标能加载配置 → 最小请求（若支持无交互）。429 当额度，403 当路由/能力。403 提到未请求的内置工具时，只比对入站/出站的模型、顶层字段和工具类型，按 LOCAL_INSTANCE 转换策略修。目标拒配置则恢复备份；配置有效而上游失败则保留配置并给出复现命令。

完成：用户能判断目标是否经本地 CLIProxyAPI 工作，并能定位或撤销本次配置。报告目标、修改文件、备份、协议入口、provider/model、各层结果；凭据 `<redacted>`。
