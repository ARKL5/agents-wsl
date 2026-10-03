# CONTEXT.md Format

## Structure

```md
# {Project Name}

{One or two sentence description of what this project does and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Location.** Single file at the repository root: `CONTEXT.md`. Create it lazily when the first term is resolved.
- **Maintain one current definition per concept.** Add an entry for a new concept; revise the existing entry in place when its meaning or canonical name is clarified. Merge duplicate entries for the same concept, retaining relevant `_Avoid_` aliases. Resolve unsettled meanings before writing them as canonical definitions.
- **The code-independence test.** Define the business reality, not the code structure. If a definition mentions database tables, schemas, fields, functions, endpoints, or UI buttons, it is broken: it has degenerated into a cache of the implementation. A non-technical domain expert should understand it completely.
- **Record meaningful negative space.** Use `_Avoid_` for names that have caused confusion or pose a concrete risk of being mistaken for the canonical term. Preserve the distinction from genuinely different concepts; omit the field when no meaningful confusion exists.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does. The headword is the canonical identifier.
- **Project-specific only.** Exclude general programming concepts (caches, retries, DTOs, timeouts). Only include terms unique to this domain.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.
