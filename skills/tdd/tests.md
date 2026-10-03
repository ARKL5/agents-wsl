# Tests Worth Keeping

A test earns its maintenance cost by detecting a meaningful violation of an agreed behavior. Design assertions around that behavior, not the current arrangement of helper functions.

## Independent expectations

Expected values come from a requirement, contract, worked example, or independent oracle. Recomputing the result with the implementation's algorithm can reproduce the same bug.

```typescript
// Weak: repeats the calculation under test.
const expected = items.reduce((sum, item) => sum + item.price, 0);
expect(calculateTotal(items)).toBe(expected);

// Independent: a known result for a concrete case.
expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
```

A literal is useful only when its correctness can be explained. Verify that a plausible wrong implementation would disagree with the assertion.

## Meaningful observation

Prefer behavior visible through the interface that owns the contract. Internal modules can have stable contracts worth testing independently; private structure is not a contract merely because a test can reach it.

Choose the observation that proves the agreed result:

- Retrieval through the application interface can prove that a created user is available to callers.
- Database inspection can prove a storage invariant or persistence requirement when that is the actual contract.
- Call count or ordering can prove a required effect, such as charging once or committing before acknowledging; incidental helper calls do not warrant those assertions.

Name tests by scenario and expected outcome. Several assertions can describe one coherent result. Keep setup and observation focused enough that a failure identifies the violated behavior.

## Scope and sensitivity

Each case must add distinct protection within the approved plan. Equivalent examples, snapshots of incidental structure, and tests of simple forwarding can create maintenance without useful detection. Keep edge cases that expose a relevant risk rather than enumerating every imaginable input.

A refactor that preserves the tested contract should usually preserve its tests. When tests change, distinguish a changed contract from accidental coupling or a removed test surface; retain the behavior they were protecting.
