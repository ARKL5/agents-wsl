# Design It Twice

Explore materially different interfaces before settling on one. Each alternative must solve the same real problem; differences should expose trade-offs, not manufacture future requirements. Use the judgments in [SKILL.md](SKILL.md).

## Frame

Ground the problem in actual callers, required behavior, dependencies, and relevant domain terms and ADRs. Establish the constraints each design must satisfy. Read [DEEPENING.md](DEEPENING.md) when dependency isolation or test migration affects the choice.

## Explore

Choose competing approaches that reveal the decision: for example, a cohesive operation versus caller-controlled stages, or an interface tailored to the common caller versus one supporting several existing caller types. Explore enough alternatives to challenge the initial idea; adapter patterns and extra extension points must earn their place through the problem's constraints.

For parallel sub-agent exploration, give each designer the same factual brief and a distinct design emphasis. Each designer produces its own proposal directly. Compare the returned proposals against the shared constraints rather than accepting their self-assessments.

Each proposal should show:

- The interface, including invariants, ordering, errors, and required configuration.
- Representative usage, including an important failure path.
- Complexity absorbed by the module and choices remaining with callers.
- How a likely change and its verification would be handled.
- The trade-off that distinguishes it from the alternatives.

## Compare

Compare caller knowledge, depth, locality, and testability using those examples. Recommend the strongest fit and explain its cost. A hybrid earns its place only if the combined interface still has a coherent responsibility and a demonstrated benefit.

Finish when the alternatives satisfy the same constraints and their material trade-offs and your recommendation are explicit.
