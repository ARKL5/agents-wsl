---
name: setup-agent-workspace
description: "Materialize one repository's agent environment from its declarations and this machine's use skill."
disable-model-invocation: true
---

# Setup agent workspace

Materialize a project agent environment for one repository. The machine skill for that location is the resident global environment: `use-local-windows` or `use-local-wsl`. It holds identity, install channels, paths, ports, and allowlists. This skill reads that environment and writes only what this repository declares.

1. **Define.** Inspect the repository. Record its purpose, and any runtime, dependencies, lockfiles, standard commands, and directory conventions it already states. Record a category only when the repository already states it.
2. **Prepare.** Follow that machine skill's install-channel file. Install a missing declared runtime inside this project the way the channel file says.
3. **Configure.** Use `writing-for-agents`. Read [what belongs where](philosophy/00.md). Create `AGENTS.md` from the [project index](shapes/project-index.md). Keep the glossary and ADR pointers; they are the repository's context structure. Keep other sections only when they have content. When this repository will be implemented and reviewed as code, also create `docs/agents/engineering-standards.md` from the [engineering standards](shapes/engineering-standards.md) shape. Create a README only when the user explicitly requests one. Leave `CONTEXT.md` and `docs/adr/` for `domain-modeling` to write when a term or decision crystallises.
4. **Verify.** Follow the new pointers. Run the verification command this project declares. When it declares none, say so. Report what changed, what passed, and what remains unresolved.

Existing declarations, lockfiles, and directory conventions are the input. A compatibility layer or migration note is added only when the user asks for one.
