# Codex

运行时权威：`~/.codex/config.toml`。版本、型号、effort、字段名：一律现查，不写回本文件。

## 类型

不是落点。已有 `~/.codex/agents/` 下的自定义类型先不动，除非用户这轮点名删除。

`~/.codex/AGENTS.md` 不是落点。现查：`codex --help`、官方 custom agents 文档（`find-docs`）

## 表面

- `~/.codex/config.toml`（权限、sandbox、features、委派总闸、插件/市场）
- 现查：`codex features list`、`codex plugin list`、`codex plugin marketplace list`、官方 sandbox / approvals 文档
- 模型与账号段不是这轮默认要动的面

## 家私

toml 字段名现查。理念里没有的政策句删掉。不要改账号或与表面无关的段。

## 故意约定

| 约定 | 说明 |
| --- | --- |
| 权限 | 全开；sandbox 关 |
| 委派 | 总闸开；内置类型无逐项开关，对应 general-purpose 的是 `default` |
| 生图 | 关。功能开关关完，系统 skill 指针仍占技能表，要把该指针也关掉 |
| 生视频 | 无此面 |
| LSP | 无此面 |
| 代码索引 | 无此面 |
| 插件 | 本家不装、不挂市场 |
| 系统 skill | 只留 `openai-docs` |
| 其余面 | 留下。按占法列过、未再点名关的不再关 |

## 现查（动手前）

```bash
codex --version
codex features list
codex plugin list
codex plugin marketplace list
python3 -c 'import tomllib; print(tomllib.load(open("/home/ark/.codex/config.toml","rb")))'
ls ~/.codex/agents
```
