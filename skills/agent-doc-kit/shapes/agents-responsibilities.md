<!-- shape exemplar: 可改编的形状示例，不是必须粘贴的权威正文。权威思想见 ../philosophy/ -->

# Project

<!-- 本仓须填：一句话身份；优先工具（如 uv）；人类入口 README -->

## Required reading

**编码标准、权威面、门禁** → [`docs/agents/engineering-preferences.md`](docs/agents/engineering-preferences.md)

工作记忆 `.scratch/` 只放 map / spec / issue；草稿在临时文档目录（本仓须填，典型 `.notes/`）。

## 命名

**领域词 glossary** → [`CONTEXT.md`](CONTEXT.md)。

## Document responsibilities

| 文档 | 唯一职责 | 明确不写 |
| --- | --- | --- |
| **`AGENTS.md`** | 开场注入的必读指针（编码标准、glossary）+ 职责表 | 全局规则、门禁命令、结构细则、领域词、产品边界清单；工序 skill 不点名本文件、不复制路径 |
| **`CLAUDE.md`** | 指向 `AGENTS.md` | 第二份路由或规则正文 |
| **`CONTEXT.md`** | glossary：领域词、概念关系、用词 | API 清单、实现游记、能力声称 |
| **`docs/agents/engineering-preferences.md`** | 本仓权威面、栈、门禁；小改默认 | 规划阶段、claims 正文 |
| **`docs/agents/documentation-governance.md`** | map / spec / issue 怎么写、何时毕业 | 协议文档如何从 kit 落下；tracker 如何 claim |
| **`docs/known-limitations.md`** | 非目标、禁止声称、外发与支持 | 把路线写成现行能力；测试已锁的意图内合同 |
| **`docs/adr/`** | 已决难逆取舍（若使用） | 未决、操作手册、第二套架构游记 |
| **`README.md`** | 面向人的最短入口与命令 | agent 必读细则 |
| **代码 / 测试 / …（本仓权威面）** | 现行行为 | 战略与产品边界 |
| **`.scratch/<effort>/`** | 仅 `map.md` / `spec.md` / `issues/` | 调研、草稿、脚本与产物 |
| **临时文档目录（本仓须填，典型 `.notes/`）** | 临时文档与一次性产物，可随时删 | 产品 CONTEXT / claims / ADR；tracker 三件套 |
