---
name: agent-doc-kit
description: 新仓或 AGENTS/docs/agents 与治理思想脱节时，按该仓事实起草或改写协议文档。
disable-model-invocation: true
---

# agent-doc-kit

**kit** 在这里指一套**思想**（authority、write surface、决策包、claims firewall…），不是要跨仓字节对齐的文件包。

本 skill 的交付是：**读懂思想 → 看清本仓 → 为本仓动态写出（或改好）agent 文档**。  
本 skill 是仓内**协议文档**的初始化源。开场注入只保证编码标准 + glossary。工序 skill 不点名 `AGENTS.md`。人协调 skill。  
同一思想在不同仓应长出**不同正文**（行为权威面、栈、专档路由不同）；相同的是原则与完成条件，不是段落哈希。

写作工艺 → skill `writing-for-agents`（指针、完成条件、progressive disclosure）。  
规划与实现工序 skill 各自负责步骤；本 skill 负责仓内协议与路由文档如何落盘。  
`.scratch` 里 map / spec / issue 怎么写、何时毕业 → 仓内 `documentation-governance.md`。协议文档（`AGENTS.md`、eng-pref）怎样算从思想落下 → **本 skill**。

## 何时用

- 新仓需要一套 agent 入口与治理文档
- 已有仓的 `AGENTS.md` / `docs/agents/*` 与你的治理思想脱节，要重塑或补齐
- 你改了本 skill 里的思想，要让某仓文档**吸收**新原则（改写/增补，不是强制整文件覆盖）
- 审查某仓文档是否违背思想（只读模式：做到「对照表」即可，不写盘）

## 明确不做

- **不做**跨仓机械 sync、标记区块强制对齐、把 exemplars 当必须粘贴的正文
- **不**用本 skill 生成产品 glossary 细节、ADR 取舍正文、known-limitations 的产品清单——只规定它们的**职责与读法**；内容仍来自本仓事实
- **不**代替 wayfinder 开 effort；未用户启动规划时不自建 `.scratch`
- 历史 resolved 票默认**前瞻生效**，不强制 bulk 回改

## 思想入口（先读）

按任务深度加载，不必一次读完：

| 读 | 当 |
| --- | --- |
| [`philosophy/00-overview.md`](philosophy/00-overview.md) | **每次必读**：leading words、权威分层、文档地图、完成判据 |
| [`philosophy/01-planning-and-tracker.md`](philosophy/01-planning-and-tracker.md) | 涉及规划哲学 / 人如何协调 skill |
| [`philosophy/02-engineering-and-delivery.md`](philosophy/02-engineering-and-delivery.md) | 涉及 eng-pref 小改默认、门禁、本仓须填 |
| [`shapes/`](shapes/) | 起草时缺结构：当骨架（标题与「本仓须填」），不是整文件模板 |

按 `00` 文档地图为本仓设计落点；`shapes/` 只在缺结构时打开，用本仓事实填权威面、路径与命令。

## 流程

### 1. 锁定目标与模式

确认：

- 目标仓库根路径
- 模式：`bootstrap`（从无到有） / `reshape`（已有文档按思想改） / `audit`（只读对照，不写）

**完成：** 用户认可路径与模式。

### 2. 加载思想

读 `philosophy/00-overview.md`；若模式触及规划或工程门禁，再读 01 / 02。

**完成：** 能用自己的话列出本仓将遵守的 leading words（至少：能力认实现面、write surface、决策包、claims firewall、前瞻生效、主线程 leader）。

### 3. 探仓（只读）

收集**本仓事实**，禁止用思想里的示例冒充本仓现实：

- 是否已有 `AGENTS.md` / `CLAUDE.md` / `CONTEXT.md` / `docs/agents/*` / `docs/adr/` / `docs/known-limitations.md` / `.scratch/` / `.notes/`
- **行为权威面**实际是什么（代码？迁移？类型？CLI？HTTP 契约？data schema？）
- 实现状态：零实现 / 有可运行入口 / 混合
- 产品专档：第三方声明、模型配置、Compose、smoke 等
- 已有职责表与路由是否互相打架或重复

**完成：** 十行内写出「本仓地图」：已有文件、权威面、缺口、风险（重复权威 / 悬空链接 / 规划文档与 wayfinder 脱节等）。

### 4. 设计落点（先设计再写）

按思想画出**本仓**文档集，而不是照抄 shapes 目录列表：

- 根路由写什么、必读顺序如何（实现仓 vs 规划向可不同）；工程默认与 glossary 必须能从根路由找到
- 哪些文件必须有；哪些可合并或省略（例如无 ADR 习惯则不要假装有 `docs/adr/`）
- 每份文档的**唯一职责**与「明确不写」
- 产品专档如何挂到 `AGENTS.md` 补充路由
- eng-pref 里哪些必须写成**本仓数字与命令**
- 默认窗口不进 claims、documentation-governance

可向用户展示一页「拟创建/修改文件表」。有歧义先问（尤其：是否使用 ADR、门禁命令是什么）。

**完成：** 用户同意文件表与职责边界；或 audit 模式下产出对照表即可停。

### 5. 起草

对每个目标文件：

1. 用思想约束结构与完成条件  
2. 用**本仓事实**填具体权威面、命令、专档、栈  
3. 缺结构时打开 `shapes/` 当骨架，用本仓事实填权威面、路径与命令；禁止整文件覆盖  
4. 遵守 `writing-for-agents`：短指针、可检查完成条件、不复制环境里已有的真相  

`CLAUDE.md`（若使用）只指向 `AGENTS.md`，不复制职责表。根路由默认不指向 claims。

**完成：** 全套草稿在回复或临时缓冲中就绪；关键取舍（省略了哪份文件、本仓权威面如何表述）已写明。

### 6. 确认后写入

展示 diff 或文件摘要 → 用户确认 → 写入仓库。  
audit 模式不写盘。

**完成：** 磁盘与确认稿一致。

### 7. 自检与收工

- 每类知识是否只有一个权威位置  
- 根路由指针可解析（编码标准/glossary）；默认必读不含 claims  
- 无第二份职责表  
- 相对链接可解析；`CLAUDE.md`→`AGENTS.md`  
- 未把目标路线写成现行能力  
- 报告：写了/改了什么、相对思想做了哪些本仓裁剪、未决问题  

**完成：** 自检全过或残留风险已显式列出。

## 改思想本身

1. 改 `philosophy/`（原则）或 `shapes/`（示例形状）  
2. 需要时再对本机相关仓跑本 skill 的 `reshape`——**按仓改写**，不要求多仓正文一致  
3. 产品事实永远在各仓 CONTEXT / limitations / ADR / 代码里更新  
4. reshape 时清掉相对思想加码的过程配额、测试黑名单、claims 里的合同缓存  

## 与相关 skill 的边界

| 需求 | 去哪 |
| --- | --- |
| 文件怎么写才像给 agent 看的 | `writing-for-agents` |
| 开 map、按 skill 内 `.scratch` 树写 map/决策票 | `wayfinder` |
| 编译 spec、切片票 | `to-spec` / `to-tickets` |
| 实现用户给出的那一张（不建 scratch） | `implement` |
| 审查已提交 range | `code-review` |
| map / spec / issue 怎么写、何时毕业 | 仓内 `documentation-governance.md` |
| 领域词与 ADR 格式 | `domain-modeling` |
| 把思想落成仓内协议文档 | **本 skill** |
