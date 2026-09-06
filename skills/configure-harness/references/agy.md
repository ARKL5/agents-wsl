# Agy

运行时权威：`~/.gemini/antigravity-cli/settings.json`。全局自定义在 `~/.gemini/config/`。版本、型号、effort、字段名：一律现查，不写回本文件。命令是 `agy`。

## 类型

不是落点。已有 `~/.gemini/config/` 下的自定义类型先不动，除非用户这轮点名删除。

`AGENTS.md` / `GEMINI.md` 不是落点。现查：`agy --help`、`agy agent`；官方字段走 `find-docs`。本机内置说明在 `~/.gemini/antigravity-cli/builtin/skills/`。

## 表面

- `~/.gemini/antigravity-cli/settings.json`（权限、sandbox、工作区外读写、遥测）
- `~/.gemini/config/`（MCP、hooks、plugins、skills.json）
- 现查：官方 CLI permissions / features / reference；`agy mcp list`、`agy plugin list`
- 型号与账号不是这轮默认要动的面

## 家私

json 字段名、权限模式取值、hooks 事件名现查。不要改账号、远程控制主机名、与表面无关的段。`skills.json` 的 `path` 用绝对路径。

## 故意约定

| 约定 | 说明 |
| --- | --- |
| 权限 | 全开；sandbox 关；工作区外读写开 |
| 委派 | 总闸开。内置类型无逐项开关 |
| 生图 | 无用户开关能从工具表拿掉，仍占着 |
| 生视频 | 无此面 |
| LSP | 无此面（语言服务器是产品自身，不是用户工具开关） |
| 代码索引 | 无此面（本地搜索，不是常驻索引） |
| 插件 | 本家不装、不挂市场、不从别家导入 |
| MCP | 默认不装 |
| 内置 skill | 调用才进，留下 |
| skill | 全局 `skills.json` 指向 `~/.agents/skills`，不往 `~/.gemini/config/skills/` 复制 |
| 跨家 | herdr 官方 integration；检测名是 `agy` |
| 其余面 | 留下。按占法列过、未再点名关的不再关 |

## 现查（动手前）

```bash
agy --version
agy --help
agy agent
agy mcp list
agy plugin list
python3 -c 'import json; print(json.load(open("/home/ark/.gemini/antigravity-cli/settings.json")))'
ls ~/.gemini/config
herdr integration status
herdr agent start --help
```
