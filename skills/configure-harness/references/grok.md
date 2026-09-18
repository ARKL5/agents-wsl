# Grok

运行时权威：`~/.grok/config.toml`。版本、型号、effort、字段名：一律现查，不写回本文件。

## 类型

不是落点。已有 `~/.grok/agents/` 下的自定义类型先不动，除非用户这轮点名删除。

现查：`~/.grok/docs/user-guide/16-subagents.md`、`05-configuration.md`、`grok inspect`；官方字段走 `find-docs`

## 表面

- `~/.grok/config.toml`（权限、sandbox、features、memory、compat、skills、委派类型开关）
- 现查：同目录 user-guide 里 permissions / features / harness compatibility 各节
- `[models]` 与各 `[model."…"]` 是活偏好，除非用户这轮要改型号，否则原样留下

## 家私

spawn 参数名、权限字段名现查，不要沿用记忆。

## 故意约定

| 约定 | 说明 |
| --- | --- |
| 权限 | 全开；sandbox 关 |
| 委派 | 总闸开。类型开关关了仍占 spawn 工具表，关了也不省，所以不关 |
| 生图 / 生视频 | 关。改图没有能从工具表拿掉的用户开关，仍占着 |
| LSP | 关 |
| 代码索引 | 关 |
| 插件 | 本家不装、不挂市场 |
| 跨家扫描 | Cursor / Claude / Codex 的 skills、rules、agents、mcp、hooks、sessions 关 |
| skill | 只认 `~/.agents/skills`，不往 `~/.grok/skills` 装 |
| 其余面 | 留下。按占法列过、未再点名关的不再关 |

## 现查（动手前）

```bash
grok --version
grok inspect
python3 -c 'import tomllib; print(tomllib.load(open("/home/ark/.grok/config.toml","rb")))'
ls ~/.grok/agents
```
