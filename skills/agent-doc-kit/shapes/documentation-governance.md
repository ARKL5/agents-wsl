<!-- shape exemplar: 可改编的形状示例，不是必须粘贴的权威正文。权威思想见 ../philosophy/ -->

# 规划产出写作

落盘模板在 skill `wayfinder` / `to-spec` / `to-tickets`。本文件只管写什么、不写什么、何时毕业。票字段与 Claim/Resolve 以创建该文件的工序 skill 模板为准。  
协议文档（`AGENTS.md`、eng-pref、tracker 职责等）如何从思想落下 → skill `agent-doc-kit`。文风 → `writing-for-agents`。

正在写或改 map、spec、issue 时读本文件。

## 三件产出

| 产出 | 写 | 不写 |
| --- | --- | --- |
| **map** | Destination、Notes、Decisions 一行 gist + 链、Not yet specified、Out of scope | Answer 全文、实现游记、把目标写成已有能力 |
| **spec** | 文首 Uses decisions 指针、结果、可观察行为、验收、非目标、测试缝（有则写） | Answer 全文、fog、路径、用户故事、逐文件步骤、把路线写成现行能力 |
| **issue** | 决策票：Question → Answer。实现票：What to build + 本切片 AC + Blocked by + Uses 指针 | 两种体裁混在一张票里；把 spec 章节或 Answer 抄进票 |

map 是**索引**，细节在票上。引用用标题链接。

## 权威边界

`.scratch/<effort>/` 只放该 Destination 的 `map.md` / `spec.md` / `issues/`。  
Resolved 记录闭环，不指导新的产品工作，不拥有产品长期事实。

稳定且代码无法表达的**产品**知识要毕业时：落到根 `AGENTS.md` 职责表指定位置；改协议文档走 `agent-doc-kit` 或用户确认。本文件不规定 `AGENTS.md` 怎样算写完。

调研、草稿、一次性脚本与产物 → 临时文档目录（本仓须填，典型 `.notes/`）。可随时删，不拥有产品权威。产品 `CONTEXT` / claims / ADR / 行为权威面仍是产品权威。

## 完成（仅 scratch 产出）

1. 写出的节符合本文件与对应 skill 的模板；  
2. map 不复制票正文；票体裁与 Type 一致；  
3. 该毕业的产品知识已指出落点；留下的草稿在临时文档目录，不写进 `.scratch`；  
4. 无决策/验收/证据变化时不改 `.scratch`。  
前瞻生效：已 resolved 的票不强制回改。
