# Ticket operations

Create parent directories if needed.

- **Implementation ticket**: `.scratch/<effort>-implement/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first); skip numbers already used in that folder. One file per ticket, never a single combined file. First line is the title (`# <NN>: <name>`). Body fields: the template in SKILL.md.
- If the user named a write path, use it as the directory for the per-ticket files. If an effort is known (the source is `.scratch/<effort>-implement/spec.md`, or this session already named the effort) and they named no path, write `.scratch/<effort>-implement/issues/`. If neither an effort nor a write path is known, ask.
