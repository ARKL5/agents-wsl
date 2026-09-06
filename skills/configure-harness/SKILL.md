---
name: configure-harness
description: 按本机理念对照并改写点名那一家 harness。仅用户点名。
disable-model-invocation: true
---

# 配置 harness

点名一家。未点名先问。一次只改点名的家。以后加家：下表加一行，并新增 `references/<name>.md`。

先读 [`PHILOSOPHY.md`](PHILOSOPHY.md)，再读该家文件。默认只做表面。

| 家 | 读 |
| --- | --- |
| **grok** | [references/grok.md](references/grok.md) |
| **pi** | [references/pi.md](references/pi.md) |
| **opencode** | [references/opencode.md](references/opencode.md) |
| **codex** | [references/codex.md](references/codex.md) |
| **agy** | [references/agy.md](references/agy.md) |

cliproxy 接入与更新走 `cli-proxy-api`。本 skill 只写 WSL 家目录，不写 Windows。型号与 effort 以 live 为准，除非这轮用户要改；不写回 skill。

官方字段名、开关、工具面：走 `find-docs`（Context7）加该家活文件，不把查到的名字写回 `references/`。

## Steps

1. **读理念。** 通读 [`PHILOSOPHY.md`](PHILOSOPHY.md)。完成：能列出每一条理念，且没有把家私调用词记成理念。
2. **读这家。** 打开上表文件。Pi 的更新/修复只在点名那些分支时再读该文件后半与 [`assets/`](assets/)。完成：知道活路径和这轮要动的面。
3. **现查。** 按该家文档入口查官方契约（`find-docs` / 本机 user-guide / `--help` / schema），并读活文件全文。完成：每个将写的字段都有当前官方或 schema 依据。
4. **写入。** 落点是表面。已有全局 `AGENTS.md` / `CLAUDE.md` 先不动，除非用户这轮点名删除；不创建、不改写它们。不创建、不改写自定义类型文件；已有的先不动，除非用户这轮点名删除。表面按 [`PHILOSOPHY.md`](PHILOSOPHY.md) 逐条对照。用户要自己选关哪些时，先按占法列出这次查到的选项再改。不要动密钥、cliproxy、与这轮无关的模型目录。完成：理念每一条在这家活配置里有对照（留下、关上、或无此面）；全局指令文件与自定义类型均未改（除非用户点名删除）。不能只写「已同步」。
5. **回报。** 家、改了哪些路径、现查验证。密钥只报有/无。

Finish when step 4 的对照写完且只动了点名的家。
