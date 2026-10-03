---
name: tdd
description: Agree on high-value tests, then implement the selected behavior test-first.
disable-model-invocation: true
---

# Test-Driven Development

Use TDD for an **agreed set of behaviors**, not as a mandate for comprehensive coverage. The user chooses the testing investment; the agent proposes worthwhile cases and is responsible for their implementation and verification.

## 1. Agree on scope

Read the requested behavior, relevant code, and existing tests. Use domain terms and relevant ADRs when present. Judge testing value against the project's purpose, lifetime, and cost of failure.

Propose a focused test plan in the conversation. For each case, state:

- The scenario and expected behavior, with the requirement, contract, or known example that establishes it.
- The meaningful error it would catch and why that protection is worth maintaining.
- The interface or observation used to verify it, and any dependency substitution or fidelity gap.

Prioritize critical flows, error-prone logic, state transitions, and relevant regressions. Reuse existing coverage. State what is intentionally left untested and why; coverage percentage, function count, and possible edge cases alone do not justify more tests.

Resolve facts from the repository yourself. Ask the user to settle unclear behavior and approve the proposed scope before writing tests or implementation. An explicit test plan already approved for this task can satisfy this step. Complete when the cases, expected outcomes, and exclusions are agreed.

## 2. Work the loop

Develop one selected behavior at a time rather than writing the whole test suite up front. Apply [tests.md](tests.md) when designing assertions and [mocking.md](mocking.md) when choosing substitutes. When interface design is itself in question, consult `codebase-design`.

1. **Red.** Write the next test and run it. Confirm it fails because the selected behavior is missing or wrong; setup, import, and syntax failures are not evidence of a regression. If it already passes, establish whether the behavior is already implemented or the test is insensitive, rather than making unrelated code fail.
2. **Green.** Implement the behavior needed for that case and run the relevant tests. A behavior may need several assertions or examples; each should protect a distinct part of the agreed expectation.
3. **Refactor.** Under passing tests, simplify the current implementation without changing its contract. Rerun the affected checks. Separate broader architectural changes from this cycle.

Stay within the agreed test scope. If new evidence warrants another behavior or materially changes the verification strategy, explain the value and revise the plan with the user before expanding it. Test mechanics within the approved plan are the agent's responsibility.

## 3. Verify and report

Check each agreed case against the resulting tests, remove redundant coverage introduced by this work, and run the affected checks and relevant existing regression tests. Report results, deliberate exclusions, and any unresolved failures or verification limits.

Complete when every agreed case is covered by meaningful assertions and passing checks, with evidence of red before implementation where behavior was missing or defective. Already-satisfied cases and blocked checks are reported explicitly. Further coverage is a separate choice, not unfinished work by default.
