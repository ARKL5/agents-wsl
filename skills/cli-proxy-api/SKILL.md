---
name: cli-proxy-api
description: 接入或更新本机 CLIProxyAPI：客户端接入，或换 CPA / Keeper 二进制。
disable-model-invocation: true
---

# 本机 CLIProxyAPI

Windows 唯一实例；WSL 经 mirrored 回环用它。脚本都是 Windows `.ps1`。Linux 会话用 `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`，`-File` 接 `wslpath -w` 后的脚本路径。

换二进制、更新 CPA 或 Keeper → **更新**，然后结束。
否则只处理用户点名的客户端、Agent 或项目（**接入**）。

## 更新

跑 [`scripts/update.ps1`](scripts/update.ps1)。参数以脚本为准（默认 CPA 与 Keeper 都升 latest）。脚本会重启这两个计划任务。以脚本汇总为准。

完成：报告 CPA 与 Keeper 的版本及 HTTP 200。

## 接入

1. **范围。** 只处理用户点名的那一个客户端、Agent 或项目。读 [`references/LOCAL_INSTANCE.md`](references/LOCAL_INSTANCE.md)。做完：目标已选定，事实已读。
2. **预检。** 跑 [`scripts/precheck.ps1`](scripts/precheck.ps1)。仅当 `result=pass` 时进入下一步；否则报告 `result` 和未通过的 `management`、`disable_image_generation`、`models` 后结束。做完：`result=pass`，或已停。
3. **备份。** 在目标自己的私有配置目录做时间戳备份。做完：备份路径已记下。
4. **写入。** 字段以该版本 `--help` / schema / 官方文档为准；base URL 以 precheck 为准。保留已有 provider、模型角色、插件和无关设置；未指定模型则保留当前默认。做完：目标配置已写。
5. **验证。** 目标能加载配置后再发最小请求（若支持无交互）。429 当额度；403 按 LOCAL_INSTANCE。目标拒配置则恢复备份；配置有效而上游失败则保留配置并给出复现命令。做完：加载与请求的结果已记录。
6. **报告。** 目标、修改文件、备份、协议入口、provider/model、`management`、`disable_image_generation`、`models`、目标加载、最小请求；凭据 `<redacted>`。

完成：用户能判断目标是否经本地 CLIProxyAPI 工作，并能定位或撤销本次配置。
