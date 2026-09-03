# 规划思想

本节只给 kit bootstrap/reshape 读。工序 skill 不知道本节存在。人是 skill 的协调器：调哪个 skill，就走哪条。kit 不写入口顺序，不写票字段表，不写 Gate/Claim 动词表。

## 原则

- **代码**是系统的主真相原。map / spec / 票 / glossary / ADR 只是这条流程自己的真相原。
- **人**选取绑定（决策）；agent 查事实、按指针读已写入的文件，不把已有决策再规划一遍。
- **日常**入口是人调用的 grill-with-docs（grilling + domain-modeling）。流程文件在每一轮答案落地后写入。
- **巨大**任务才有 map：人自己判断塞不进一次日常会话时，才调用 wayfinder。map 是索引；一条决策只住在一张票里；按 Uses / Blocked by 读到该绑定的源文件。
- **转换**（to-spec / to-tickets）要有来源（人给的路径或当前对话），不分类来源，互不点名。编不出可检查的验收就停、列出缺失、等人。
- **实现**吃已经写下的东西。有 `Status:` 才 Claim/Resolve。implement 不创建 `.scratch`。
- 默认不改产品代码。map 头栏可以有 `Execute-in-wayfinding: yes`；何时打开由人决定。

这些段落不要复制进默认必读，也不要落成仓内 tracker。
