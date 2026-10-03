# Dependency Substitution

Choose real dependencies or test substitutes according to the behavior being verified, test cost, and required fidelity. Ownership alone does not determine whether a dependency should be mocked.

## Choose the least misleading setup

- **Real dependency**: useful when storage, transport, or integration semantics are part of the contract. Prefer an existing local test setup where practical.
- **Fake or local stand-in**: useful for exercising several behaviors cheaply. Check which production semantics it omits.
- **Stub**: supplies controlled responses when the test concerns how the caller handles them.
- **Mock or spy**: observes an interaction when that interaction is an agreed requirement, such as an effect occurring once.
- **Controlled clock or randomness**: makes a selected time-dependent or probabilistic scenario reproducible.

A substitute tests reactions to the behavior it models; it does not prove that the real dependency matches that model. Make relevant fidelity gaps explicit in the test plan. An internal collaborator can be substituted for a concrete isolation need, but mocking every helper risks testing the wiring instead of the behavior.

## Keep production responsibilities intact

Use existing substitution points where possible. Introduce dependency injection or an adapter when it earns its cost through control, isolation, or meaningful verification. Keep internal construction private when callers have no useful choice to make.

Choose domain operations or transport-level interfaces according to the responsibility they serve. A mock that is easy to configure is not, by itself, a reason to reshape production code.
