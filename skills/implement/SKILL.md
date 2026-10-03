---
name: implement
description: "Implement agreed work, verify it, commit it, and complete an independent review."
disable-model-invocation: true
---

# Implement

Calling this skill requests the full delivery cycle: implementation, verification, commits on the current branch, and independent review. Push only when requested.

## 1. Establish the work

Read the source the user supplies, or use the agreed requirements in the current conversation. Distinguish requirements and confirmed decisions from proposals. Inspect the relevant code, project instructions, and existing checks; resolve discoverable facts yourself and ask about decisions that would change scope or behavior.

Record the starting `HEAD` and existing worktree changes before editing. Preserve unrelated work and keep it outside this task's commits and review scope. Complete when the deliverable, acceptance conditions, and starting state are clear.

## 2. Implement and verify

Implement the agreed behavior and relevant failure paths using the project's existing patterns.

Choose verification according to the change's impact and project purpose: existing checks, relevant regression tests, and direct behavior checks where useful. Add tests when they protect a meaningful risk, not to pursue comprehensive coverage. Inspect the diff against the requirements and project standards before committing.

Complete when the requested behavior is implemented and the chosen checks have run, with failures, omissions, and verification limits identified. Resolve failures caused by this work; distinguish pre-existing failures from regressions.

## 3. Commit and independently review

Commit this task's changes on the current branch, following repository commit conventions. Invoke `code-review` with the recorded starting revision and the requirement source: its file path, or the agreed behavior, acceptance conditions, and exclusions from the conversation.

Repeat this cycle while independent review identifies substantiated findings within scope: fix them, rerun affected checks, commit the corrections, and invoke `code-review` again with the same baseline and requirements. Continue until those findings are resolved. If progress requires a user decision or is blocked, report the incomplete state and what is needed to proceed.

Complete when the implementation and any corrections are committed, verification results are known, and independent review has no unresolved substantiated findings within scope. If verification or review remains incomplete, report the blocker and current state rather than claiming full delivery.

Report the delivered behavior, commit IDs, verification and review results, and any remaining decisions or gaps.
