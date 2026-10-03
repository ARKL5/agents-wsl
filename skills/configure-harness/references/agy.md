# Agy

## 配置位置

- `~/.gemini/antigravity-cli/settings.json`：权限、运行方式、工作区信任和界面设置。
- `~/.gemini/config/`：MCP、hooks、插件、skill 路径和自定义 agent 定义。
- `~/.gemini/antigravity-cli/statusline`：个人 Python 状态栏脚本。
- `~/.gemini/antigravity-cli/builtin/skills/`：当前安装附带的说明。

## 个人约定

| 项目 | 约定 |
| --- | --- |
| 权限 | 无逐次确认，关闭沙箱，允许工作区外读写 |
| 状态栏 | 命令调用 Python 脚本；单行自适应宽度，避免折行和异常退出导致停用 |
| 终端 | 始终使用备用屏幕模式 |
| 工作区信任 | 保留已信任路径 |
| 委派 | 保持启用 |
| 插件 | 不安装、不配置市场，也不从其他 harness 导入 |
| MCP | 默认不安装 |
| Skills | 使用 `~/.agents/skills` 的绝对路径，不复制到 harness 专属目录；内置 skill 按需加载，保留 |
| 跨 harness 集成 | 使用 herdr，集成标识为 `antigravity-cli` |

## 维护边界

`~/.gemini/config/hooks.json` 的 herdr 条目由 `herdr integration install antigravity-cli` 维护。

配置维护保留既有状态栏、终端模式、信任清单及远程控制主机名；只在本次任务涉及它们时调整。

## 验证方式

按任务查 `agy --help`、当前安装附带的说明，必要时通过 `find-docs` 查官方契约。MCP、插件和 herdr 集成各用对应的当前命令验证。

功能是否存在、内置 agent 能否分别关闭，以及功能如何进入上下文，均按当前版本核查。此前生图因缺少移除工具描述的配置机制而保留；没有新依据时不自动关闭。
