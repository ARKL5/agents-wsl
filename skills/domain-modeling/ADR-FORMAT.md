# ADR Format

ADRs live in `docs/adr/` and use sequential numbering: `0001-slug.md`, `0002-slug.md`, etc.

Create the `docs/adr/` directory lazily: only when the first ADR is needed.

## Template

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

That's it. An ADR is a single paragraph. The value is in recording *that* a decision was made and *why*, not in filling out sections.

## Numbering

Scan `docs/adr/` for the highest existing number and increment by one.

## The Contrast Test

Code only records the survivor; it never records the discarded paths. An ADR qualifies only when all three hold:

1. **Hard to reverse**: The cost of changing later is meaningful (lock-in, storage migrations, architectural boundaries).
2. **Surprising without context (The road not taken)**: A reasonable developer or agent reading the code would wonder "why did they do it this way?" and attempt to "fix" or refactor it into an obvious standard. The ADR defends deliberate deviations.
3. **The result of a real trade-off**: Genuine alternatives were evaluated and rejected for specific reasons, or invisible external constraints (compliance, hardware ceilings, upstream partner bugs) dictated the choice.

## The changelog filter

If a reasonable developer inspecting the code would find the implementation natural and unsurprising, **do not write an ADR**. Feature additions, standard bug fixes, and routine refactors belong in commit logs, not `docs/adr/`.

## What qualifies

- **Architectural shape.** "We're using a monorepo." "The write model is event-sourced, the read model is projected into Postgres."
- **Integration patterns between contexts.** "Ordering and Billing communicate via domain events, not synchronous HTTP."
- **Technology choices that carry lock-in.** Database, message bus, auth provider, deployment target. Not every library: just the ones that would take a quarter to swap out.
- **Boundary and scope decisions.** "Customer data is owned by the Customer context; other contexts reference it by ID only." The explicit no-s are as valuable as the yes-s.
- **Deliberate deviations from the obvious path.** "We're using manual SQL instead of an ORM because X." Anything where a reasonable reader would assume the opposite. These stop the next engineer — or an agent imitating neighboring files — from "fixing" something that was deliberate.
- **Constraints not visible in the code.** "We can't use AWS because of compliance requirements." "Response times must be under 200ms because of the partner API contract."
- **Rejected alternatives when the rejection is non-obvious.** If you considered GraphQL and picked REST for subtle reasons, record it; otherwise someone will suggest GraphQL again in six months.
