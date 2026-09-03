---
name: fetch-media
description: 混乱源：B 站、YouTube 字幕、OpenCLI。仅用户点名。
disable-model-invocation: true
---

# Fetch media

日常网页用宿主搜索和读页。官方库文档走 `find-docs`。未点名分支时，按用户给的 URL/平台选一支。

命令与会话 **live-check**（`opencli doctor`）。哪份 Chrome、桥怎么连，以本机 use-local 的浏览器合同为准。输出加 `-f yaml`。只读；写操作（评论、关注、点赞、登录）只有用户当次点名才做。不要替用户登录，不要读浏览器 Cookie 文件。

## B 站

走 OpenCLI。不要 `bili-cli`。不要 `yt-dlp`（B 站会 412）。

```
opencli bilibili video BVxxx -f yaml
```

`opencli bilibili --help` 看全表。`download` 依赖 yt-dlp，不要用。

**完成：** 已取到元数据/字幕/总结，或已说明桥/登录态为什么读不到。

## YouTube 字幕 / 转写

先 `yt-dlp` 拉字幕（不下载视频），失败再用 OpenCLI。文件写到本机临时目录（以 use-local 为准）。

```
yt-dlp --write-sub --write-auto-sub --sub-lang "zh-Hans,zh,en" --skip-download -o "<tmpdir>/%(id)s" "URL"
opencli youtube transcript "URL" -f yaml
```

OpenCLI 返回空字幕时最多再试 3 次（过期字幕 URL），仍空则说没有字幕。

**完成：** 已读到非空字幕/转写，或已说明没有字幕。

## OpenCLI

站点不在上面两支、但要读登录态或站点适配器时走这里。

```
opencli list
opencli <site> --help
opencli <site> <command> -f yaml
```

`opencli` 不在 PATH 或 `doctor` 失败：报告缺失，停。发现适配器存在 ≠ 已登录或目标页可读；只在用户任务需要时跑只读命令，并要求非空内容。

**完成：** 已用对应适配器取到内容，或已说明桥/适配器/登录态缺什么。
