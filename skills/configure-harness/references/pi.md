# Pi

运行时权威：`~/.pi/agent/`。版本、包列表、模型矩阵、fast 开关、compaction 数值：一律现查，不写回本文件。

## 全局指令

- `~/.pi/agent/AGENTS.md`
- `~/.pi/agent/agents/swift.md`
- `~/.pi/agent/agents/deliberate.md`
- 现查：`pi --help`、`pi list`、已装 `pi-subagents` 的 README（`~/.pi/agent/npm/node_modules/pi-subagents/`）

## 表面

- `~/.pi/agent/settings.json`（信任、`subagents.disableBuiltins`、MCP 是否安装）
- 现查：同上。扩展、补丁、SSRF 见下方「更新 / 修复」

## 家私

斜杠形态和 agent frontmatter 现查。本机特有：`/run swift` · `/run deliberate`、`/cliproxy-fast`、`$skill-…`。

## 故意约定

| 约定 | 说明 |
| --- | --- |
| provider | `cliproxy`；baseUrl 现查 live；监听约定见 `/home/ark/.agents/references/local-cliproxy.md` |
| 模型路由 | 以 live `settings.json` / `models.json` 为准；本文件不固定主线程模型 |
| 排队 | 意图为 `steeringMode=all` · `followUpMode=all`（改前先读 live） |
| Thinking 显示 | 隐藏 |
| 安静启动 | `quietStartup` + `collapseChangelog` |
| MCP | 默认不装；需要时再装 |
| Subagents | builtins 关闭；角色名 `swift` / `deliberate`；`maxSubagentDepth=1`；`model`/`thinking` 只存在 live。包源不钉版本，参加 `pi update --all` |
| Multi-skills | 本地扩展：提示内 `$skill-a $skill-b …` 原子加载已注册 skill（含 user-only） |
| Fast | 本地 `cliproxy-gpt-fast-mode`；默认开关在 state 文件，**勿用资产默认覆盖用户开关** |
| FFF | `@ff-labs/pi-fff` 不钉版本。`PI_FFF_MODE=override`；家目录扫描关；`PI_FFF_MULTIGREP` 保持未设。env 落点 `~/.config/pi-env.sh` |
| 联网 | `pi-web-access` + 本地 SSRF 适配（Clash fake-IP） |
| Compaction | git 包 `pi-openai-server-compaction` + 本地 cliproxy 补丁（`pi update` 后需重打） |

## 关键路径

```text
~/.pi/agent/
  AGENTS.md · settings.json · models.json · auth.json
  agents/{swift,deliberate}.md
  openai-server-compaction.json
  extensions/cliproxy-gpt-fast-mode/
  extensions/multi-skills.ts
  state/cliproxy-gpt-fast-mode.json
  git/github.com/algal/pi-openai-server-compaction/
  npm/node_modules/…
  backups/
  fff/
~/.pi/web-search.json
~/.config/pi-env.sh
```

## 现查（动手前）

```bash
pi --version
pi list
jq . ~/.pi/agent/settings.json
jq . ~/.pi/agent/models.json
ls ~/.pi/agent/extensions
jq . ~/.pi/agent/state/cliproxy-gpt-fast-mode.json
jq . ~/.pi/agent/openai-server-compaction.json
. ~/.config/pi-env.sh
printf 'PI_FFF_MODE=%s FFF_ENABLE_HOME_SCAN=%s\n' "${PI_FFF_MODE-}" "${FFF_ENABLE_HOME_SCAN-}"
```

上游存活：baseUrl 从 live settings/models 读；监听约定见 `/home/ark/.agents/references/local-cliproxy.md`。

## 更新 / 修复

仅当用户点名更新、修复、装卸包或改约定时走这里。投影全局指令/表面不必跑。

改前备份 `settings.json`、`models.json`、`auth.json` 到 `~/.pi/agent/backups/<时间戳>/`（密钥 `0600`）。优先单包更新；仅用户明确要求时才 `--extensions` / `--all`。源字符串带 `@版本` 的 npm 包通常不参加批量更新——以 `pi list` 为准。

```bash
pi update
pi update --extension <source>
pi update --extensions
pi update --all
bash /home/ark/.agents/skills/configure-harness/assets/reapply-cliproxy-compaction-patch.sh
bash /home/ark/.agents/skills/configure-harness/assets/pi-web-access/reapply-adaptation.sh
```

**Compaction**（更新该 git 包后必复核）：目标 `…/pi-openai-server-compaction/src/openai.ts`、`remote-compaction.ts`；源 `assets/openai.ts.patched`、`assets/remote-compaction.ts.patched`。条件意图：`openai-responses` + `provider=cliproxy` + loopback + 模型 id 以 `gpt-` 开头。Done：脚本或 diff 有输出。

**Fast**：运行时 `~/.pi/agent/extensions/cliproxy-gpt-fast-mode/`；状态文件是用户开关权威；镜像 `assets/extensions/cliproxy-gpt-fast-mode/`。仅当状态文件缺失时才用 `assets/state-cliproxy-gpt-fast-mode.defaults.json`。

**Multi-skills**：运行时 `~/.pi/agent/extensions/multi-skills.ts`；镜像 `assets/extensions/multi-skills.ts`。

**pi-web-access / fake-IP**：期望片段 `assets/pi-web-access/web-search.json`（`ssrf.allowRanges` 含 `198.18.0.0/15`）；重放脚本合并、不覆盖用户其它字段。Done：读 `~/.pi/web-search.json` 含该段。

FFF 斜杠 `/fff-health` · `/fff-rescan` · `/fff-mode` 以现查为准。新会话以 `~/.config/pi-env.sh` 为准。

仅当约定、路径或恢复工序变化时更新本文件。不要把 `pi --version`、包版本、模型表、fast 开关写回。
