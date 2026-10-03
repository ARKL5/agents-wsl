# Deepening

Deepen existing modules by reducing caller knowledge while preserving their responsibilities and behavior. Use the judgments in [SKILL.md](SKILL.md).

## Establish the candidate

Trace representative callers, shared policy, and changes that currently span the cluster. Identify what a new interface would absorb and what callers still need to control. Consolidation earns its cost when it improves depth and locality without combining independent responsibilities.

## Dependencies and verification

The dependency's behavior determines what tests need to exercise; deployment location alone does not dictate the architecture.

| Dependency | Design and testing considerations |
| --- | --- |
| In-process computation or state | Exercise behavior directly. Combine modules when their shared responsibility warrants it, not merely because they have no I/O. |
| Local infrastructure | Prefer a real local dependency or a faithful stand-in where practical. Check which semantics the stand-in omits, such as transactions, locking, or filesystem behavior. |
| Remote service you own | Separate local policy from transport when that improves isolation. A port with production and test adapters can help; test the remote contract and relevant failure behavior as well. |
| External service | An adapter can contain vendor details. A fake or mock verifies local reactions to modeled responses, not whether the vendor behaves that way; verify integration assumptions separately where feasible. |

Place a dependency seam at the responsibility that needs substitution. Keep internal wiring private when callers have no meaningful choice to make. Describe any fidelity gaps left by the verification strategy.

## Migrating tests

Inventory the behaviors and regressions protected by existing tests. Verify preserved behavior through the new interface and retain targeted tests of meaningful internal contracts.

Replace tests tied to removed structure after their valuable coverage has moved. Delete redundant tests based on what they protect, not merely because broader tests now exist. Keep both internal correctness and integration failures observable without requiring tests to mirror incidental implementation details.

A deepening recommendation should identify the caller burden removed, responsibilities preserved, migration path, and evidence that behavior remains covered.
