---
name: codebase-design
description: Deep-module design principles. Use when designing or reviewing module interfaces, locating testable seams, or comparing architectural alternatives.
---

# Codebase Design

Design modules that **absorb complexity for their callers**. Judge the whole arrangement: what callers must know, what the module hides, and where changes and verification concentrate. A smaller signature is useful only when it reduces that total burden.

## Vocabulary

Use these distinctions to reason about the design; retain the project's own names for its components, services, APIs, and boundaries.

- **Module**: code with an interface and an implementation, from a function to a package or a slice across layers.
- **Interface**: everything a caller must know to use the module correctly, including invariants, ordering, errors, configuration, and performance, not just types or method signatures.
- **Implementation**: the code and internal structure behind that interface.
- **Depth**: capability relative to the interface a caller must learn. A deep module hides substantial complexity; a shallow one exposes almost as much as it handles. Code volume is not a measure of depth.
- **Seam**: a place where behavior can be varied without rewriting the code that uses it. Choosing its location is distinct from choosing what it exposes.
- **Adapter**: a concrete implementation that fits a seam; the term describes its role, not its size.
- **Leverage**: useful capability per unit of caller knowledge.
- **Locality**: a responsibility's knowledge, changes, defects, and verification concentrate rather than spreading across callers.

## Design judgments

- **Complexity ownership.** Trace actual callers: which details do they repeat or coordinate? Move shared policy and invariants into the module that owns them. Keep choices outside when they genuinely belong to the caller.
- **The deletion test.** Imagine removing the module while preserving its behavior. If complexity disappears, the indirection may be unnecessary; if it reappears across callers, the module was earning its keep. Account for contract translation, isolation, and lifecycle responsibilities as well as computation.
- **Depth over method count.** Fewer entry points or parameters can help, but flags, ordering rules, and configuration can make a tiny signature expensive. Compare representative usage, including failures, rather than counting methods.
- **Locality over consolidation.** Combine responsibilities that share knowledge and change together. Separate independent reasons to change; a large implementation is not automatically a deep module.
- **Evidence for seams.** Justify substitution by actual variation, dependency isolation, or a testing need. Multiple adapters can demonstrate value, but their count alone does not justify an abstraction.

## Testability

Use observable behavior at a meaningful interface as the main test surface. Internal modules can have their own contracts and tests; needing a targeted test is not by itself evidence of a bad design.

Inject dependencies when caller control or substitution has a concrete benefit. Keep construction details inside when exposing them would transfer unnecessary knowledge to callers. Isolate pure computation where it clarifies policy; keep necessary effects with the responsibility that owns their ordering and failure handling.

Evaluate a design with real usage and a plausible change: identify the knowledge callers gain or lose, where that change lands, and how its behavior can be verified. Tie recommendations to those consequences, not a preferred code shape.

## Further reference

- When deepening existing modules with I/O dependencies or migrating their tests, read [DEEPENING.md](DEEPENING.md).
- When exploring alternative interfaces, read [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md).
