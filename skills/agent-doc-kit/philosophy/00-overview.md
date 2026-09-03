# 总纲

Agent 文档治理要解决的不是「多写几份 md」，而是：

1. **能力认实现面** — 现行能力只认行为权威面；spec 与 map 是目标与约束  
2. **write surface** — 每类稳定知识只有一个权威位置，入口用读取条件路由  
3. **决策包** — 规划收窄分叉；锁定有实施后果的选型，不等于偷偷交付产品  
4. **claims firewall** — 禁止声称、非目标、外发与支持单独成文  

本 skill 是仓内**协议文档**的初始化源（`AGENTS.md`、eng-pref）。规划与实现工序仍归 `wayfinder` / `to-spec` / `to-tickets` / `implement`。根 `AGENTS.md` 是**开场注入**的指针（编码标准/门禁、glossary）。人协调 skill。工序 skill 正文不点名 `AGENTS.md`。`.scratch` 里 map / spec / issue 怎么写，落在仓内 `documentation-governance.md`。谁创建 `.scratch` 由人调用的 skill 决定。过程可复现；**产出正文随仓而变**。

## Leading words

| 词 | 用法 |
| --- | --- |
| **能力认实现面** | 现行能力只认本仓声明的行为权威面。spec 与 map 是目标与约束，不是能力证明。 |
| **write surface** | 某类知识允许被写入的唯一文档（或代码）位置。改知识 = 改该面，删旧副本。 |
| **决策包** | Wayfinding 产出：已锁分叉 + 显式未决，足够 to-spec/实现而不必再猜产品级选择。思想在本 skill；仓内不复述「该锁什么」的论文。 |
| **claims firewall** | `known-limitations` 专管非目标、禁止声称、外发与支持。测试已锁的意图内合同认行为权威面。默认根路由不指向本文件。 |
| **前瞻生效** | 协议变更约束新工作与仍 open 的票；不强制回改已 resolved 历史。 |
| **主线程 leader** | 委派不转移架构裁决、文档权威判断与最终验证。 |

避免把「零实现」当唯一口号。优先说 **能力认实现面**。

## 权威分层

仓库里一切文件都是**潜在** context；指导实现时只认：

1. **现行行为** — 行为权威面（本仓在 eng-pref 写清枚举）  
2. **战略方向** — 用户确认的路线 + glossary + active ADR + claims；尚无接受路线时默认 claims + 用户当轮指示  
3. **非 oracle** — Git 历史不指导现行设计（取证/许可证除外）  
4. **工作记忆** — `.scratch` 只放 map / spec / issue；谁创建由人调用的 skill 决定。临时文档单独目录（典型 `.notes/`），只作证据与交接，可随时删  

与正式文档冲突时：先从运行入口与测试确认行为，再报文档漂移。

## 文档地图（逻辑角色）

| 角色 | 典型路径 | 写什么 | 不写什么 |
| --- | --- | --- | --- |
| 根路由 | `AGENTS.md` | 开场注入指针（编码标准/门禁、glossary）+ 职责表 | 全局规则正文、claims 触发表、规划阶段全文 |
| 指针 | `CLAUDE.md` | 只指向 `AGENTS.md` | 第二份路由 |
| Glossary | `CONTEXT.md` | 术语、概念关系、用词 | API 清单、实现 tour、能力声称 |
| 工程默认 | `docs/agents/engineering-preferences.md` | 本仓权威面、栈、门禁；小改默认 | 规划阶段、claims 正文 |
| 规划产出写作 | `docs/agents/documentation-governance.md` | map / spec / issue 怎么写、何时毕业 | 协议文档如何从 kit 落下；如何 claim |
| Claims | `docs/known-limitations.md` | 非目标、禁止声称、外发与支持 | 把路线写成现行能力；测试已锁的合同 |
| 难逆取舍 | `docs/adr/*` | 有真实 trade-off 时 | 未决、操作手册 |
| 行为权威面 | 代码/测试/… | 现行行为 | 战略与边界 |

**可裁剪：** 无 ADR 则不要空挂 `docs/adr/`。术语用法写在 `CONTEXT.md` 文首。  
**不可裁掉：** 能力认实现面、单一 write surface、claims 文件存在。

默认窗口不进 claims、documentation-governance。根路由指针给开场注入上下文。写 map/spec/issue 时读 documentation-governance。claims 在用户开口写 README / 答辩 / 质量声称时再读。

## 工作记忆

`.scratch` 只放 map / spec / issue。谁创建由人调用的 skill 决定。写作规则 → 仓内 documentation-governance。  
临时文档单独一个目录（本仓须填路径，典型 `.notes/`），可随时删，不拥有产品权威。产品 CONTEXT / claims / ADR / 行为权威面仍是产品权威。

## 完成判据（思想层）

1. 每类稳定知识只有一个 write surface  
2. 行为权威面在仓内显式枚举  
3. claims 文档存在；根路由默认不指向它  
4. 无第二份职责表；`CLAUDE.md` 若存在则仅为指针  
5. 正文随仓  
6. 默认必读不含规划阶段论文、claims 全文、过程配额  
