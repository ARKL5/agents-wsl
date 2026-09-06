# OpenCode

## 类型

不是落点。已有 `opencode.json` 里的自定义 `agent.*` 先不动，除非用户这轮点名删除。

`~/.config/opencode/AGENTS.md` 不是落点。现查：`opencode --help`、该 json 的 `$schema`；官方字段走 `find-docs`

## 表面

- 同一 `opencode.json`：`permissions`、内置 `agent.*.disable`
- 现查：官方 agents / permissions 文档，版本以这次安装为准
- 模型目录不是这轮默认要动的面

## 家私

不要改 `provider`、模型目录、以及与表面无关的键。

## 故意约定

| 约定 | 说明 |
| --- | --- |
| 权限 | 全开 |
| 委派 | 总闸开。内置 `plan` / `general` / `explore` 不关；关了会从 agents 列表拿掉，但这是会用的面 |
| 插件 | 本家不装用户插件；MCP 默认不装 |
| 其余面 | 留下。按占法列过、未再点名关的不再关 |

## 现查（动手前）

```bash
opencode2 --version
opencode2 debug agents
opencode2 mcp list
opencode2 plugin list
python3 -c 'import json; print(json.load(open("/home/ark/.config/opencode/opencode.json")))'
ls ~/.config/opencode/plugins
herdr integration status
```
