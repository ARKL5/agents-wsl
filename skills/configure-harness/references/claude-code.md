# Claude Code

运行时权威：`~/.claude/settings.json`。版本、型号、effort、字段名：一律现查，不写回本文件。

## 类型

不是落点。已有 `~/.claude/agents/` 下的自定义类型先不动，除非用户这轮点名删除。

现查：`claude --help`、官方 sub-agents 文档（`find-docs` 或 `code.claude.com/docs/en/<页>.md`）

## 表面

- `~/.claude/settings.json`（权限、连接器、内置 skill、账号 skill 同步、反馈工具、Artifact、workflows、`env`、hooks）
- 现查：官方 settings-reference、env-vars、permission-modes 各页
- `statusLine`、`theme` 是活偏好，原样留下
- `hooks` 里的 herdr 条目由 `herdr integration install claude` 维护，不手改

## 家私

bypass 默认模式只在用户级 settings 生效，写在 `~/.claude/settings.json`。`~/.claude/skills/<name>` 链接由 `sync-agent-skills` 的同步维护；`~/.claude/skills/synced/` 是账号同步目录，关同步后其内容移入 `.trash`。

本家权限 deny 只写工具名时，官方明确会把该工具从上下文里整个拿掉，算关上；带范围的 deny 只挡调用，不算。没有专门开关的内置工具走前者。关完用 `claude -p --output-format stream-json --verbose` 的 init 消息核对工具表。

## 故意约定

| 约定 | 说明 |
| --- | --- |
| 权限 | 全开，bypass，跳过进入确认框 |
| 委派 | 总闸开；内置 `Explore` / `Plan` 留下 |
| claude.ai 连接器 | 关 |
| 反馈工具 | 关，从工具表移除 |
| 内置 skill | 关 |
| claude.ai 账号 skill 同步 | 关 |
| Artifact | 关 |
| 自动记忆 | 留下 |
| 遥测 | 关；错误上报等其余后台流量留下 |
| Dynamic workflows | 关 |
| 定时与循环任务 | 关，连同自调度唤醒工具 |
| 云端 routine 触发、设计稿同步、审查报告、notebook 编辑 | 关 |
| worktree 工具与计划模式工具 | 关；后台会话隔离随之改为直接改工作副本 |
| herdr | 集成装上 |
| 其余面 | 留下。按占法列过、未再点名关的不再关 |

## 现查（动手前）

```bash
claude --version
jq . ~/.claude/settings.json
ls ~/.claude/agents ~/.claude/skills
herdr integration status
```
