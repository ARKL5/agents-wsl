# Pi

运行时权威：`~/.pi/agent/`。版本、包列表、模型矩阵、compaction 数值：一律现查，不写回本文件。

## 类型

不是落点。已有 `~/.pi/agent/agents/` 下的自定义类型先不动，除非用户这轮点名删除。

`~/.pi/agent/AGENTS.md` 不是落点。现查：`pi --help`、`pi list`

## 表面

- `~/.pi/agent/settings.json`（信任、MCP 是否安装）
- 现查：同上。扩展、SSRF 见下方「更新 / 修复」

## 家私

斜杠形态和 agent frontmatter 现查。本机特有：`$skill-…`。

## 故意约定

| 约定 | 说明 |
| --- | --- |
| provider | `cliproxy`；baseUrl 现查 live；监听约定见 `/home/ark/.agents/references/local-cliproxy.md` |
| 模型路由 | 以 live `settings.json` / `models.json` 为准；本文件不固定主线程模型 |
| 排队 | 意图为 `steeringMode=all` · `followUpMode=all`（改前先读 live） |
| Thinking 显示 | 隐藏 |
| 安静启动 | `quietStartup` + `collapseChangelog` |
| MCP | 默认不装；需要时再装 |
| 委派 | 无此面。不装 sub-agent 插件。跨家走 herdr |
| 扩展 | 只留 FFF、Multi-skills、`pi-web-access` |
| Multi-skills | 本地扩展：提示内 `$skill-a $skill-b …` 原子加载已注册 skill（含 user-only） |
| FFF | `@ff-labs/pi-fff` 不钉版本。`PI_FFF_MODE=override`；家目录扫描关；`PI_FFF_MULTIGREP` 保持未设。env 落点 `~/.config/pi-env.sh` |
| 联网 | `pi-web-access` + 本地 SSRF 适配（Clash fake-IP） |

## 关键路径

```text
~/.pi/agent/
  AGENTS.md · settings.json · models.json · auth.json
  agents/
  extensions/multi-skills.ts
  npm/node_modules/…
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
. ~/.config/pi-env.sh
printf 'PI_FFF_MODE=%s FFF_ENABLE_HOME_SCAN=%s\n' "${PI_FFF_MODE-}" "${FFF_ENABLE_HOME_SCAN-}"
```

上游存活：baseUrl 从 live settings/models 读；监听约定见 `/home/ark/.agents/references/local-cliproxy.md`。

## 更新 / 修复

仅当用户点名更新、修复、装卸包或改约定时走这里。投影表面不必跑。

优先单包更新；仅用户明确要求时才 `--extensions` / `--all`。源字符串带 `@版本` 的 npm 包通常不参加批量更新——以 `pi list` 为准。

```bash
pi update
pi update --extension <source>
pi update --extensions
pi update --all
bash /home/ark/.agents/skills/configure-harness/assets/pi-web-access/reapply-adaptation.sh
```

**Multi-skills**：运行时 `~/.pi/agent/extensions/multi-skills.ts`；镜像 `assets/extensions/multi-skills.ts`。

**pi-web-access / fake-IP**：期望片段 `assets/pi-web-access/web-search.json`（`ssrf.allowRanges` 含 `198.18.0.0/15`）；重放脚本合并、不覆盖用户其它字段。Done：读 `~/.pi/web-search.json` 含该段。

FFF 斜杠 `/fff-health` · `/fff-rescan` · `/fff-mode` 以现查为准。新会话以 `~/.config/pi-env.sh` 为准。

仅当约定、路径或恢复工序变化时更新本文件。不要把 `pi --version`、包版本、模型表写回。
