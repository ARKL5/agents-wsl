---
name: improve-codebase-architecture
description: Identify evidence-backed architectural improvements and compare their benefits, migration costs, and risks.
disable-model-invocation: true
---

# Improve Codebase Architecture

Find structural costs worth addressing, not refactors to fill a report. Use `codebase-design` for design judgments; deepening a module is one possible remedy, not the predetermined answer.

## 1. Explore the relevant structure

Start with the user's named area or pain point. Otherwise, use recent changes, defects, and repeated modification patterns to choose where to investigate. Change frequency is a lead, not proof that the architecture needs repair. State the inspected scope.

Read relevant project instructions, domain terms, and ADRs when present. Trace actual callers, responsibilities, dependencies, and tests. Look for concrete friction: repeated coordination by callers, knowledge that changes in several places, independent responsibilities that are entangled, or important behavior that is costly to understand or verify.

Investigate directly or use authorized delegation where it adds value. Complete when each suspected problem has code evidence and an explanation of its consequences, rather than merely a label such as shallow, coupled, or untested.

## 2. Present worthwhile candidates

Default to a concise comparison in the conversation. Use diagrams when they clarify the structure; a separate visual report is optional, not a required deliverable.

For each worthwhile candidate, explain:

- **Evidence and impact**: relevant code locations or change history, the burden they reveal, and who bears it.
- **Direction and benefit**: what responsibility or interface would change and what complexity it would remove or absorb.
- **Cost and risk**: affected callers and contracts, migration effort, and uncertainty that could change the recommendation.
- **Verification**: how to show that behavior is preserved and the claimed improvement is real.

Compare the benefit with leaving the arrangement in place or making a smaller change. Rank candidates and recommend where to invest first, with reasons. If a candidate conflicts with an ADR, explain the evidence that warrants reconsidering that decision. Distinguish established friction from hypotheses that need further investigation.

Complete when the user has enough evidence and cost information to choose what, if anything, to explore. If no worthwhile candidate emerges, report that result and the inspection limits rather than manufacturing work.

## 3. Explore the selected candidate

Once the user chooses a candidate, examine its constraints, interfaces, migration path, and relevant alternatives. Resolve technical facts yourself; bring consequential trade-offs to the user. Use `domain-modeling` when recording confirmed terms or architectural decisions.

Finish when the proposed change, its rationale, costs, verification, and remaining decisions are clear. This skill provides analysis and recommendations; implementing a refactor is a separate user direction.
