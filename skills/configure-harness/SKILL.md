---
name: configure-harness
description: 维护本机 harness 的个人配置、扩展和集成。
disable-model-invocation: true
---

# 维护 harness 配置

处理用户指定 harness 的配置调整、故障修复、扩展和包维护，以及个人约定的记录。维护范围是 WSL 用户目录；一次处理一个 harness，目标可从当前对话确定，无法确定时再问。

| Harness | 参考文件 |
| --- | --- |
| grok | [references/grok.md](references/grok.md) |
| pi | [references/pi.md](references/pi.md) |
| opencode | [references/opencode.md](references/opencode.md) |
| codex | [references/codex.md](references/codex.md) |
| agy | [references/agy.md](references/agy.md) |
| claude-code | [references/claude-code.md](references/claude-code.md) |

## 工作流程

1. **确定任务。** 读取目标 harness 的参考文件，确定要调整的行为和相关文件。局部维护只检查相关配置；用户要求全面整理时才扩大范围。
2. **核查依据。** 完整读取待修改的配置或脚本。涉及权限、功能启停或上下文精简时，读 [PHILOSOPHY.md](PHILOSOPHY.md)；官方配置字段和 API 查 `find-docs` 或当前安装附带的文档、帮助、schema。
3. **修改并验证。** 使用该 harness 实际加载的配置入口。配置改动验证解析及生效，扩展改动验证加载及相关行为，包维护核对更新结果；需要重载或重启时说明。
4. **记录并回报。** 新的个人偏好、维护约束，或不从实际配置本身可直接判断的稳定维护入口写回对应参考文件。报告修改路径、行为变化和验证结果；未验证的部分明确列出。

## 维护边界

- 实际配置文件是当前状态的依据，参考文件记录个人约定；用户本次要求优先。只修改与任务相关的内容，模型、思考强度、账号和自定义 agent 定义不作为例行重置项。
- 配置写入 harness 支持的配置文件或扩展；不用全局 `AGENTS.md` 代替配置。跨 harness 会话使用 herdr，其管理的集成通过官方维护入口调整。
- 参考文件保留个人决定和必要的维护知识；版本、模型清单、官方能力支持情况和可直接读取的实现细节按需核查，不写入参考文件。具体模型及思考强度保留在实际配置中。
- 凭据仅报告有无，不输出内容。

完成标准：任务范围内的修改和必要验证已完成，新的个人约定已记录，无关配置保持原样。
