---
name: cli-proxy-api
description: 在本机通过 CLIProxyAPI 接入用户点名的客户端、Agent 或项目，或更新 CLIProxyAPI / CPAUsageKeeper。
disable-model-invocation: true
---

# 本机 CLIProxyAPI

更换二进制或更新 CPA/Keeper 时走“更新”，完成后结束；其余走“接入”。

Windows 是唯一实例，WSL 通过 mirrored 回环访问。脚本均为 Windows PowerShell；Linux 会话用
`/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe` 执行，并把脚本路径先转为 `wslpath -w`。

## 更新

执行 [`scripts/update.ps1`](scripts/update.ps1)，参数和输出以脚本为准。以脚本汇总报告 CPA 与 Keeper 的版本、任务状态和 HTTP 结果。

## 接入

仅处理用户点名的客户端、Agent 或项目。动态事实以 [`scripts/precheck.ps1`](scripts/precheck.ps1) 输出为准；更新结果以 [`scripts/update.ps1`](scripts/update.ps1) 汇总为准。协议路径、客户端字段和配置 schema 以目标当前版本的 `--help`、schema 或官方文档为准。CPA Usage Keeper 是用量看板，不作为 Agent provider。

1. 执行 [`scripts/precheck.ps1`](scripts/precheck.ps1)。退出码非 0 时停止，并原样报告脚本输出中的失败事实。
2. 在目标自己的私有配置目录创建时间戳备份，并记录路径。
3. 以目标当前版本的 `--help`、schema 或官方文档确定字段和协议；以 precheck 输出确定本地入口。只改目标所需字段，保留现有 provider、模型角色、插件和其它设置；用户未指定模型时保留当前默认。
4. 让目标重新加载配置后发最小请求（若支持无交互）。配置加载失败则恢复备份；配置有效但上游失败则保留配置并提供复现命令。
5. 报告目标、修改文件、备份路径、协议入口、provider/model、precheck 结果、配置加载和最小请求结果。

完成标准：更新以脚本汇总为准；接入能定位配置、撤销修改，并能判断目标是否通过本机 CLIProxyAPI 工作。
