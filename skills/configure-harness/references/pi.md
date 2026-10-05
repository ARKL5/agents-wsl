# Pi

## 配置位置

- `~/.pi/agent/settings.json`：运行、界面和扩展包设置。
- `~/.pi/agent/models.json`、`auth.json`：模型路由和认证。
- `~/.pi/agent/web-search.json`：联网设置。
- `~/.pi/agent/extensions/`：本地扩展；子 agent 设置在 `subagent/config.json`。
- `~/.pi/agent/agents/`：自定义 agent 定义。
- `~/.config/pi-env.sh`：启动环境，含 FFF 设置。

## 个人约定

| 项目 | 约定 |
| --- | --- |
| 模型调用 | 通过 `cliproxy`；地址和模型路由以实际配置为准 |
| 消息排队 | steering 和 follow-up 均处理全部排队消息 |
| 界面 | 安静启动，折叠更新日志 |
| 扩展包 | 仅使用 FFF、`pi-web-access`、`pi-subagents`，均不固定版本；本地扩展另行维护 |
| FFF | `@ff-labs/pi-fff`；覆盖内置搜索，关闭家目录扫描，保持 `PI_FFF_MULTIGREP` 未设置 |
| MCP | 默认不安装，需要时再安装 |
| 子代理工具 | `disabledFeatures` 固定为全部 15 组，含 `workflow-scripts`。`scheduledRuns.enabled` 为 `false`。模型只用单个 `agent`/`task`、`tasks` 和 `chain`，不写 workflow 脚本，也不创建定时任务 |
| 工具启用 | `pi-web-access` 的 `toolActivation` 固定为 `eager`，不使用 `web_enable`。`pi-subagents` 为 `dynamic`：新会话不带 `subagent`。`subagents_enable` 不进模型请求。`subagent_supervisor` 也先不进，直到 `/subagent-on` 打开 `subagent`，两者出现在同一次请求。打开后的下一次请求接受提示缓存失效。已经带着它的旧会话保持原状 |
| 请求里的说明 | 同一本地扩展用 `prepareLoadout` 隐藏 `bg_wait` 和 `subagents_enable` 的声明，并替换 `subagent` 和 `web_search` 的工具说明。参数 schema 仍由两个包生成。不要改安装文件，不要用 `toolDescriptionMode: "custom"`，也不要在请求里再改参数 |

## 维护边界

`herdr-agent-state.ts` 由 herdr 安装器维护。更新集成使用其官方入口，手工扩展修改只处理用户维护的文件。

## 状态栏

个人扩展 `~/.pi/agent/extensions/statusline.ts`：单个小文件、零配置、零额外依赖。两行 footer，第三行只显示其他扩展的非空状态。

只保留模型、思考档位、上下文、会话 CH、累计标价、末次成功请求的 TTFT 数值、本次发言的加权产出速度。采用鲜明彩色和常规字重，避免灰色、加粗、中文解释及 `TTFT` 标签。布局、色值和计算实现以脚本为准，修改前读全文。

统计选择保持一致：CH 和标价覆盖会话全部条目，含已放弃分支；上下文直接采用 pi 的值。速度按一次用户发言内的成功调用加权，含思考 token，排除请求等待和工具执行；失败或中止的调用不计入，工具循环不会重置发言统计；新发言或恢复会话后先隐藏性能。

CPA Usage Keeper 保持独立看板：它覆盖全部 CPA 流量，没有 pi session id，入库有延迟，速度按总延迟计算，不接入 footer。

## 验证方式

配置和包维护按需查 `pi --help`、`pi list`。优先单包更新；固定版本的包是否参与批量更新，以当前命令帮助为准。FFF 故障先查包内诊断入口及实际启动环境。

本地扩展参照当前安装的 extensions / TUI 文档，验证加载和受影响的行为。只有本次修改状态栏时，才检查窄屏、第三行按需出现和发言间性能清空；修改统计逻辑时，核对累计范围，以及整段发言而非工具步骤的加权速度。
