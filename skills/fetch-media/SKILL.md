---
name: fetch-media
description: 用 OpenCLI 读 B 站、小红书、知乎、Boss 直聘。
disable-model-invocation: true
---

# OpenCLI

空结果、桥失败、登录墙按该支完成条件报告即可。

走 OpenCLI（复用已登录 Windows Chrome）。命令与会话 **live-check**（`opencli doctor`）。哪份 Chrome、桥怎么连，以本机 use-local 的浏览器合同为准。输出 `-f yaml`。默认只读；写操作（评论、关注、点赞、登录、打招呼、发消息）只有用户当次点名才做。登录态只经 OpenCLI 桥。

未点名分支时，按用户给的 URL/平台选一支。对不上这四站则走 **web read**。命令以 `opencli <site> --help` 为准。

`opencli` 不在 PATH 或 `doctor` 失败：报告缺失，停。适配器在名单里 ≠ 已登录或目标页可读；跑只读命令并要求非空内容。

## 选站

| 用户说法 | 适配器 |
| --- | --- |
| B 站、bilibili、BV | `bilibili` |
| 小红书、xhs | `xiaohongshu` |
| 知乎 | `zhihu` |
| Boss 直聘、zhipin | `boss` |

## B 站

有 BV → `video` / `subtitle` / `summary`。搜 → `search`。

完成：已取到元数据/字幕/总结，或已说明桥/登录态为什么读不到。

## 小红书

走 `xiaohongshu`。搜笔记 → `search`；打开笔记 → `note`。几乎都要登录。

完成：已取到笔记/搜索结果，或已说明桥/登录态为什么读不到。

## 知乎

搜 → `search`；问题 → `question`；单答 → `answer-detail`；文章 → `download`。

完成：已取到问题/回答/文章，或已说明桥/登录态为什么读不到。

## Boss 直聘

默认求职端只读：`search` / `detail` / `chatlist` / `chatmsg`。招聘端（`greet`、`resume`、`recommend`、`invite`、`batchgreet`）只有用户当次点名。

`search` 的 `--city` 以用户点名为准（命令默认北京）。职位详情用搜索结果里的 `security_id` 调 `detail`。

完成：已取到职位/聊天，或已说明桥/登录态为什么读不到。

## web read

对不上这四站、或有 URL 但适配器读不到时走这里。

```
opencli web read --url <url> --stdout -f yaml
```

默认会写 `./web-articles` 并下图，用 `--stdout`。参数以 `opencli web read --help` 为准。

完成：已读到页面正文，或已说明桥/登录墙为什么读不到。
