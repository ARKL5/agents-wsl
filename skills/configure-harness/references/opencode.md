# OpenCode

## 配置位置

- `~/.config/opencode/opencode.json`：权限、provider、模型和 agent 设置；自定义 agent 定义也可能在此文件中。
- `~/.config/opencode/plugins/`：用户插件。

## 个人约定

| 项目 | 约定 |
| --- | --- |
| 权限 | 全部开放 |
| 委派 | 保持启用；内置子 agent 启用 `general`、关闭 `explore`；主 agent `plan` 保留 |
| 插件 | 不安装用户插件 |
| MCP | 默认不安装 |

## 维护边界

配置文件同时包含多种设置，按本次任务修改相关键。模型路由及 agent 的模型选择、思考强度以实际配置为准。

## 验证方式

配置字段查文件声明的 schema 及当前官方 agents / permissions 文档。CLI 使用本机 `opencode2` 入口，命令以当前帮助为准；按任务核对 agent、MCP、插件或 herdr 集成。
