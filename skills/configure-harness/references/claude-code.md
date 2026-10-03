# Claude Code

## 配置位置

- `~/.claude/settings.json`：用户级权限、功能、环境、hooks 和界面设置。
- `~/.claude/agents/`：自定义 agent 定义。
- `~/.claude/skills/`：skill 链接及账号同步内容。

## 个人约定

| 项目 | 约定 |
| --- | --- |
| 权限 | 使用 bypass 模式，跳过进入确认框 |
| 委派 | 保持启用，保留内置 `Explore` 和 `Plan` |
| 关闭的集成 | claude.ai 连接器和账号 skill 同步 |
| 关闭的工具与能力 | 反馈工具、内置 skills、Artifact、Dynamic workflows；定时和循环任务及自调度唤醒工具；云端 routine 触发、设计稿同步、审查报告、notebook 编辑；worktree 和计划模式工具 |
| 后台会话 | 直接修改工作副本，与关闭 worktree 工具的决定一致 |
| 自动记忆 | 保留 |
| 后台流量 | 关闭遥测；错误上报等其余后台流量保留 |
| 跨 harness 集成 | 安装 herdr 集成 |

## 维护边界

- bypass 默认模式配置在用户级 settings 中；修改时核查当前生效范围。
- herdr hooks 由 `herdr integration install claude` 维护。
- `~/.claude/skills/<name>` 链接由 `sync-agent-skills` 的同步流程维护。
- `~/.claude/skills/synced/` 是账号同步目录；关闭同步时，其内容移入 `.trash`。
- 状态栏和主题保留实际配置中的个人偏好，只在任务涉及它们时调整。

## 验证方式

按任务查当前官方 settings、环境变量、权限模式或 sub-agents 文档。配置字段通过 `find-docs` 核查，集成通过 herdr 的当前诊断入口验证。

精简工具时区分“从上下文移除”和“仅禁止调用”。此前不带范围的工具名 deny 可移除工具描述，而带范围的 deny 仅阻止调用；修改前核查当前契约，修改后验证会话初始工具表。
