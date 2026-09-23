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
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Location.** Single file at the repository root: `CONTEXT.md`. Create it lazily when the first term is resolved.
- **The code-independence test.** Define the business reality, not the code structure. If a definition mentions database tables, schemas, fields, functions, endpoints, or UI buttons, it is broken: it has degenerated into a cache of the implementation. A non-technical domain expert should understand it completely.
- **Negative space is mandatory.** Code only reveals the identifiers chosen; it cannot reveal the ones rejected. Every term must carry `_Avoid_` with plausible synonyms an agent or developer might casually introduce. This arrests vocabulary drift before it starts.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does. The headword is the canonical identifier.
- **Project-specific only.** Exclude general programming concepts (caches, retries, DTOs, timeouts). Only include terms unique to this domain.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.
