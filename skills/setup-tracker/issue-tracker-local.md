# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- Wayfinding lives in `.scratch/<effort>/` (map + decision tickets)
- `to-spec` and `to-tickets` write a sibling directory `.scratch/<effort>-implement/`
- `## Answer` is the resolve slot on a wayfinding ticket. `## Comments` is only appended conversation

## When a skill says "publish to the issue tracker"

Follow the operations section that skill named. Create parent directories if needed.

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Spec operations

Used by `/to-spec`.

- **Spec**: `.scratch/<effort>-implement/spec.md`. First line is the title (`# <name>`). Body sections: templates live in to-spec.
- If the user named a write path, use it. If the source is a wayfinding map at `.scratch/<effort>/map.md` and they named no path, write `.scratch/<effort>-implement/spec.md`. If neither an effort nor a write path is known, ask.

## Ticket operations

Used by `/to-tickets`.

- **Implementation ticket**: `.scratch/<effort>-implement/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first); skip numbers already used in that folder. One file per ticket, never a single combined file. First line is the title (`# <NN>: <name>`). Body fields: template lives in to-tickets.
- If the user named a write path, use it as the directory for the per-ticket files. If an effort is known (the source is `.scratch/<effort>-implement/spec.md`, or this session already named the effort) and they named no path, write `.scratch/<effort>-implement/issues/`. If neither an effort nor a write path is known, ask.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<effort>/map.md`. First line is the title (`# <name>`), same rule as child tickets. Body sections: Destination, Notes, Decisions so far, Not yet specified, Out of scope (templates live in wayfinder).
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered from `01`. First line is the title (`# <name>`), used in narration and Decisions so far — never the filename or number. `Type:` is `research` / `prototype` / `grilling` / `task`. `Blocked by: NN, NN` near the top. The question is the body. Omit `Status` until claimed.
- **Blocking**: a ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: scan `.scratch/<effort>/issues/` for files that are not `resolved`, unblocked, and unclaimed; first by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Close**: `Status: resolved`. Off the frontier.
- **Resolve**: append the answer under `## Answer`, **close**, then append a context pointer (title-as-link + one-line gist) to the map's Decisions so far. For `research` tickets, the Answer is a pointer to the file the research skill wrote; do not paste the findings.
- **Close only** (no Answer, no Decisions-so-far line): out of scope, and restatement of a settled ticket. Restatement: one line pointing at the original.
