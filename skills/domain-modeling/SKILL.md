---
name: domain-modeling
description: Crystallise domain terminology into CONTEXT.md and architectural trade-offs into docs/adr/. Use when encountering new domain concepts, fuzzy or conflicting terms, or recording hard-to-reverse decisions.
---

# Domain Modeling

Actively capture and crystallise a project's domain model as you design and build. This skill strictly creates and appends: it catches terms and architectural decisions the moment they emerge, writes them down inline, and never defers them.

(Merely reading `CONTEXT.md` is a baseline reading habit; this skill is for writing and appending.)

## Targets

- **Domain terms**: append to `CONTEXT.md` at the repo root. Follow [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md).
- **Architectural decisions**: append to `docs/adr/`. Follow [ADR-FORMAT.md](ADR-FORMAT.md).

Create targets lazily: create `CONTEXT.md` at repo root when the first term crystallises; create `docs/adr/` when the first ADR is written.

## Steps

1. **Probe.** Watch conversation and code for domain signals:
   - **New concepts**: a domain entity, role, or relationship appears without a definition in `CONTEXT.md`.
   - **Fuzzy or conflicting language**: overloaded words, synonyms, or a mismatch between spoken terms and code identifiers. Align on a single canonical term (the symbol used in code) and identify aliases to avoid.
   - **Irreversible decisions**: an architectural or technology choice that meets the 3-condition bar in [ADR-FORMAT.md](ADR-FORMAT.md) (hard to reverse, surprising without context, real trade-off). If any condition is missing, skip the ADR.
2. **Crystallise.** Write the entry down immediately:
   - **For a term**: append to `CONTEXT.md` following [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md). Define the business reality, not code structure, in 1-2 sentences. Always include `_Avoid_` aliases.
   - **For an ADR**: write `docs/adr/NNNN-slug.md` (increment highest number) following [ADR-FORMAT.md](ADR-FORMAT.md). State context, decision, and why in 1-3 sentences.
3. **Verify.** Confirm the addition is complete:
   - Glossary entry passes the code-independence test and carries `_Avoid_` aliases.
   - ADR qualifies under the contrast test.

Finish when the resolved term or ADR is written to disk and verified against its format.
