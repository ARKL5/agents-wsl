# agents-wsl: Multi-Harness Agent Skills & Context Governance

[![Skills Verification](https://img.shields.io/badge/skills-27%20verified-brightgreen)](tools/check.py)
[![Architecture](https://img.shields.io/badge/architecture-multi--harness-blue)](skills/configure-harness/)
[![Philosophy](https://img.shields.io/badge/context-governance-purple)](skills/configure-harness/PHILOSOPHY.md)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

面向现代自主智能体（Autonomous Agents）与主流开发 Harness 的**上下文工程治理体系与标准化软件工程技能库**。

本项目不追求碎片化、情绪化的自然语言 Prompt 堆砌，而是从**系统级上下文负载管理（Context Budgeting）**、**渐进式信息披露（Progressive Disclosure）**与**软件工程最佳实践规约化**出发，构建一套可跨平台复用、具备确定性交付质量的 AI-Assisted 研发工作流。

---

## 🌟 核心理念 (Philosophy)

大模型在复杂工程任务中的表现，本质取决于**上下文纯度（Context Purity）**与**完成契约（Completion Criteria）**。本项目遵循以下三大治理支柱：

### 1. 三类上下文开销剪裁 (Context Budgeting)
在持续多轮会话中，每一行常驻上下文都在持续消耗模型注意力与 Token 预算。我们在 [`configure-harness/PHILOSOPHY.md`](skills/configure-harness/PHILOSOPHY.md) 中确立了严格的审计规则：
- **调用才进（On-demand）**：仅在命中触发条件时加载正文（如绝大多数专业 Skills），指针极度紧凑，正文零常驻负载；
- **不用也常驻（Always-loaded）**：针对全局常驻提示词与工具表，坚决剪裁“永远用不上但每轮进窗口”的厂商预置沉淀，净化模型注意力；
- **关了也不省（Interface-only）**：区分单纯的 UI 选项与真实进入模型窗口的上下文，杜绝无意义的防御性配置。

### 2. 渐进式披露与信息阶梯 (Progressive Disclosure)
参考 [`writing-for-agents/SKILL.md`](skills/writing-for-agents/SKILL.md)，将 Agent 输入信息严格分层：
$$\text{In-file Steps (执行步骤)} \longrightarrow \text{In-file Reference (即时查阅)} \longrightarrow \text{Disclosed Reference (指针外展)}$$
通过条件指针（Context Pointer）替代全局平铺，阻断长上下文中的注意力涣散（Attention Sprawl），实现精准按需调度。

### 3. 完成契约与正向引导 (Completion Criteria & Positive Steering)
- **拒绝模糊收工**：为关键工程动作设计可断言、可验证的“完成契约（Completion Criteria）”，通过明确清晰度（Clarity）与需求度（Demand）杜绝 Agent 的过早交卷倾向（Premature Completion）；
- **正向语义引导**：用正向的高信息密度语义锚点（Leading Words）替代脆弱的禁止性禁令（Negation），高效唤醒模型的预训练先验。

---

## 🚀 支持的 Harness 生态 (Supported Platforms)

本项目设计了跨 Harness 的适配抽象，覆盖以下主流 Agent 运行时：

| Harness / Platform | 适配重点 | 配置文件与规范 |
|---|---|---|
| **Claude Code** | 技能符号链接、全局与局部规约分层、权限边界治理 | `skills/configure-harness/references/claude-code.md` |
| **Google Antigravity (AGY)** | 运行时定制、MCP 工具协同、子 Agent 协同规约 | `skills/configure-harness/references/agy.md` |
| **OpenAI Codex** | CLI 交互模式约束、指令加载优化 | `skills/configure-harness/references/codex.md` |
| **Pi / OpenCode / Grok** | 子 Agent 交互协议与上下文剪裁 | `skills/configure-harness/references/` |

---

## 🗂️ 核心技能矩阵 (Skills Matrix)

仓库内现行沉淀 **27 项工程技能**（其中 14 项列入跨工作区共享名单 [`shared-skills.txt`](shared-skills.txt)），全部经过 [`tools/check.py`](tools/check.py) 的严格类型与契约校验：

### 🏗️ 架构设计与领域建模 (Architecture & Domain)
- [`domain-modeling`](skills/domain-modeling/)：将模糊概念晶体化为领域词汇表（`CONTEXT.md`）与架构决策记录（`ADR`），杜绝隐式术语漂移；
- [`codebase-design`](skills/codebase-design/)：遵循 John Ousterhout 深度模块理念，设计深接口、强内聚接缝与可维护代码边界；
- [`improve-codebase-architecture`](skills/improve-codebase-architecture/)：代码坏味道识别、重构手法建议与设计演进；
- [`to-spec`](skills/to-spec/) / [`to-tickets`](skills/to-tickets/)：需求严密形式化，将自然语言诉求拆解为原子化、带验收断言的工程工单。

### 🛡️ 质量保障与防御性研发 (Quality & Resilience)
- [`code-review`](skills/code-review/)：沿“工程标准（Standards）”与“需求契约（Spec）”双轴对变更做高可信静态审查；
- [`tdd`](skills/tdd/)：红-绿-重构循环，测试先行，以行为断言驱动高质量代码实现；
- [`grilling`](skills/grilling/) / [`grill-me`](skills/grill-me/)：对架构方案、复杂重构与重大决策开展高强度的对抗性拷问，挖掘隐藏盲区；
- [`prototype`](skills/prototype/)：抛弃型原型探索，用最低成本验证状态模型与交互逻辑。

### ⚙️ Harness 治理与 Agent 研发 (Harness & Metaprogramming)
- [`configure-harness`](skills/configure-harness/)：多平台 Harness 运行时权限、常驻负载与剪裁治理；
- [`writing-for-agents`](skills/writing-for-agents/)：面向自主 Agent 的规范文档与 Skill 编写方法论（指针、负载、阶梯与契约）；
- [`cli-proxy-api`](skills/cli-proxy-api/)：多模型路由、代理转发与工程化接口适配；
- [`sync-agent-skills`](skills/sync-agent-skills/)：跨工作区技能分发、版本锁定与一致性校验。

### 🔍 调研与上下文导航 (Research & Navigation)
- [`research`](skills/research/)：针对高信度一手信息源（官方文档、RFC、源码）开展深度技术研判，输出落盘报告；
- [`find-docs`](skills/find-docs/)：优先对接官方权威 SDK、CLI 与云服务文档库，阻断虚假第三方 API 幻觉；
- [`handoff`](skills/handoff/) / [`wayfinder`](skills/wayfinder/)：复杂跨轮次会话上下文交接与复杂代码库地标导航。

---

## 🛠️ 自动化工具链 (Tooling)

```bash
# 验证所有 Skills 的契约合规性（frontmatter、调用权限、共享名单对齐）
uv run tools/check.py

# 跨工作区技能同步与版本管理
uv run tools/sync.py
```

- **零密钥硬编码**：全流程遵循无凭证设计，所有鉴权走环境变量或安全本地代理；
- **契约级确定性**：每一个 Skill 拥有独立 YAML 元数据、调用面与清晰的步骤终止条件。

---

## 📄 开源许可 (License)

本项目采用 [MIT License](LICENSE) 开源协议。
