---
name: configure-harness
description: 按本机理念对照并改写点名那一家 harness。仅用户点名。
disable-model-invocation: true
---

# 配置 harness

点名一家。未点名先问。一次只改点名的家。以后加家：下表加一行，并新增 `references/<name>.md`。

先读 [`PHILOSOPHY.md`](PHILOSOPHY.md)，再读该家文件。默认这家的全局指令和表面都做；只点其中一面则只做那面。

| 家 | 读 |
| --- | --- |
| **grok** | [references/grok.md](references/grok.md) |
| **pi** | [references/pi.md](references/pi.md) |
| **opencode** | [references/opencode.md](references/opencode.md) |
| **claude** | [references/claude.md](references/claude.md) |
| **codex** | [references/codex.md](references/codex.md) |

cliproxy 接入与更新走 `cli-proxy-api`。本 skill 只写 WSL 家目录，不写 Windows。型号与 effort 以 live 为准，除非这轮用户要改；不写回 skill。

官方字段名、开关、工具面：走 `find-docs`（Context7）加该家活文件，不把查到的名字写回 `references/`。

## Steps

1. **读理念。** 通读 [`PHILOSOPHY.md`](PHILOSOPHY.md)。完成：能列出每一条理念，且没有把家私调用词记成理念。
2. **读这家。** 打开上表文件。Pi 的更新/修复只在点名那些分支时再读该文件后半与 [`assets/`](assets/)。完成：知道活路径和这轮要动的面。
3. **现查。** 按该家文档入口查官方契约（`find-docs` / 本机 user-guide / `--help` / schema），并读活文件全文。完成：每个将写的字段都有当前官方或 schema 依据。
4. **备份。** 改前把将动的文件拷到该家配置目录下带时间戳的副本。完成：每个将改路径都有备份。
5. **写入。** 全局指令：共同段按理念重写，措辞适应该家；家私调用词保留或按官方补上；理念里没有的政策句删掉。`swift` / `deliberate`：指针进类型短描述，立场进类型正文，选型只进 `AGENTS.md` / `CLAUDE.md`。表面：权限拉到该家允许的最开一档；关掉同时满足「厂商内置 / 不用仍常驻上下文 / 挤注意力」的面；核心读写、命令、委派、联网保持可用。用户要自己选关哪些时，先列这次查到的选项再改。不要动密钥、cliproxy、与这轮无关的模型目录。完成：理念每一条在活文件里都有对应句（或「无，已补」）；表面三条都有对照。不能只写「已同步」。
6. **回报。** 家、改了哪些路径、备份、现查验证。密钥只报有/无。

Finish when step 5 的对照写完且只动了点名的家。
