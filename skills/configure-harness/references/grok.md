# Grok

## 配置位置

- `~/.grok/config.toml`：权限、功能、模型、兼容性扫描和 skills 设置。
- `~/.grok/agents/`：自定义 agent 定义。
- `~/.grok/docs/user-guide/`：当前安装附带的文档。

## 个人约定

| 项目 | 约定 |
| --- | --- |
| 权限 | 全部开放，关闭沙箱 |
| 委派 | 保持启用；内置子 agent 只启用 `general-purpose`，关闭 `explore` 和 `plan` |
| 功能精简 | 关闭生图、生视频、LSP 和代码索引 |
| 插件 | 不安装，也不配置市场 |
| 兼容性扫描 | 关闭对 Cursor、Claude、Codex 的 skills、rules、agents、MCP、hooks 和 sessions 扫描 |
| Skills | 只使用 `~/.agents/skills`，不往 `~/.grok/skills` 安装 |

## 维护边界

改图此前因缺少移除工具描述的配置机制而保留；没有新依据时不自动关闭。

## 验证方式

配置修改参照本机 user-guide 的配置、权限、功能及兼容性章节；委派修改查 subagents 章节。`grok inspect` 用于核对生效配置，具体参数以当前帮助为准。
