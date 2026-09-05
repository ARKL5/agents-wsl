# Wayfinding

Create parent directories if needed.

The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<effort>/map.md`. First line is the title (`# <name>`), same rule as child tickets. Body sections: Destination, Notes, Decisions so far, Not yet specified, Out of scope (templates live in SKILL.md).
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered from `01`. First line is the title (`# <name>`), used in narration and Decisions so far — never the filename or number. `Type:` is `research` / `prototype` / `grilling` / `task`. `Blocked by: NN, NN` near the top. The question is the body. Omit `Status` until claimed.
- **Blocking**: a ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: scan `.scratch/<effort>/issues/` for files that are not `resolved`, unblocked, and unclaimed; first by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Close**: `Status: resolved`. Off the frontier.
- **Resolve**: append the answer under `## Answer`, **close**, then append a context pointer (title-as-link + one-line gist) to the map's Decisions so far. For `research` tickets, the Answer is a pointer to the file the research skill wrote; do not paste the findings.
- **Close only** (no Answer, no Decisions-so-far line): out of scope, and restatement of a settled ticket. Restatement: one line pointing at the original.

`## Answer` is the resolve slot on a wayfinding ticket. `## Comments` is only appended conversation.

If the user named a path, read that file. If they named a ticket title or number, read the matching child under that effort's `issues/`.
