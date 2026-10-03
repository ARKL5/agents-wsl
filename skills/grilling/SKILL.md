---
name: grilling
description: Stress-test a plan, decision, or idea through relentless questioning. Use when the user asks to grill or challenge their thinking.
---

# Grilling

Challenge assumptions, expose contradictions, and make consequential trade-offs explicit. Be **relentless** where an answer could change the current goal, approach, cost, or risk; depth is not the number of questions asked.

## Decision tree

Track the decisions and their prerequisites as a **design tree**. The **frontier** contains questions whose prerequisites are settled. Recompute it after each answer; questions that depend on an unanswered choice belong to a later round.

Concentrate on branches that affect the current decision. Leave nonessential implementation details to implementation, and identify assumptions or uncertainties that matter rather than trying to exhaust every possible branch.

## Responsibility

Establish discoverable facts yourself and distinguish evidence from inference. Investigate simple questions directly; use sub-agents for independent or time-consuming investigations when delegation is authorized. A pending investigation is an unsettled prerequisite: defer its dependent questions while progressing unrelated ones. State unavailable evidence as a gap.

The user owns goals, preferences, consequential trade-offs, and risk acceptance. The agent owns fact-finding, analysis, and technical judgments already delegated to it. Ask about choices that need the user's judgment, not routine details the agent can resolve within agreed constraints.

## Rounds

Select the highest-impact questions on the frontier that can be answered together. Number them, explain why each matters, and give your recommendation with its decisive reason and relevant alternatives. Keep the round manageable for the discussion rather than asking the whole frontier at once.

Wait for answers before advancing dependent decisions. Probe vague or inconsistent answers with concrete scenarios and consequences; revise your recommendation when new facts or priorities change its basis. Preserve settled decisions unless new evidence warrants reopening them.

## Completion

Summarize the decisions, their important trade-offs, and remaining uncertainty. Finish when the user agrees that the issues affecting the current decision are sufficiently clear to proceed; explicitly deferred questions stay deferred. If a material choice or prerequisite remains unresolved, identify it instead of claiming consensus.

This skill remains a discussion. Starting implementation is a separate user direction.
