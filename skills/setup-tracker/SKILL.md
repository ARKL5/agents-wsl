---
name: setup-tracker
description: Configure this repo's issue tracker. Run once before first use of wayfinder, to-spec, or to-tickets.
disable-model-invocation: true
---

# Setup tracker

Scaffold the per-repo issue tracker that the engineering skills assume. Issues live as local markdown under `.scratch/`: wayfinding in `<effort>/`, spec and implementation tickets in `<effort>-implement/`.

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `AGENTS.md` at the repo root: does it exist? Is there already an Issue tracker line in Required reading?
- `CLAUDE.md`: if it exists, it should only point at `AGENTS.md`. Do not edit `CLAUDE.md`.
- `docs/agents/`: does `issue-tracker.md` already exist?
- `.scratch/`: a sign that a local-markdown issue tracker convention is already in use

### 2. Present findings and confirm

Summarise what's present and what's missing. This repo uses **local markdown**. Show a draft of:

- The one Required reading line to add to `AGENTS.md`
- The contents of `docs/agents/issue-tracker.md` (from [issue-tracker-local.md](./issue-tracker-local.md))

Let them edit before writing.

Do not write `docs/agents/domain.md` or `docs/agents/triage-labels.md`. Glossary and ADR paths belong in `AGENTS.md` as pointers; `domain-modeling` owns those files.

### 3. Write

If `AGENTS.md` exists, add this line under **Required reading** (update in-place if an Issue tracker pointer is already there). Don't overwrite user edits to the surrounding sections. Do not edit `CLAUDE.md`. If `AGENTS.md` does not exist, create it with **Required reading** and this line.

```markdown
**Issue tracker** → [`docs/agents/issue-tracker.md`](docs/agents/issue-tracker.md)
```

Then write `docs/agents/issue-tracker.md` from [issue-tracker-local.md](./issue-tracker-local.md).

### 4. Done

Tell the user the setup is complete and that `wayfinder`, `to-spec`, and `to-tickets` will now read `docs/agents/issue-tracker.md`. Mention they can edit that file directly later; re-running this skill is only necessary if they want to restart from scratch.
