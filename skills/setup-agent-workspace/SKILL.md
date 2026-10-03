---
name: setup-agent-workspace
description: "Prepare one repository's agent environment from its declarations and current environment conventions."
disable-model-invocation: true
---

# Setup agent workspace

Materialize a project agent environment for one repository. Ground runtime and toolchain choices in repository declarations; adapt agent documentation to the repository's actual arrangements and adopted engineering baseline.

1. **Define.** Inspect the repository. Record its purpose, and any runtime, dependencies, lockfiles, standard commands, and directory conventions it already states. Record a category only when the repository already states it.
2. **Prepare.** Install missing declared runtimes using the current environment's installation conventions and the project's runtime declarations.
3. **Configure.** Use `writing-for-agents`. Read [what belongs where](philosophy/00.md). Read existing agent instructions and engineering standards first; retain working arrangements, fill gaps, and merge equivalent rules. Use the [project index](shapes/project-index.md) as a starting point for `AGENTS.md`, not a replacement template. For code repositories, make the engineering baseline reachable from the index: reuse existing standards, or adapt the [engineering standards](shapes/engineering-standards.md) into `docs/agents/engineering-standards.md` when none exist. Keep sections with content and glossary/ADR pointers conditional on their targets existing. Create a README only when the user explicitly requests one. Leave glossary and ADR creation to `domain-modeling` when a term or decision crystallises.
4. **Verify.** Check that each reading trigger reaches its source when applicable. Run the verification command this project declares. When it declares none, say so. Report what changed, what passed, and what remains unresolved.

Existing declarations, lockfiles, and directory conventions are the input. A compatibility layer or migration note is added only when the user asks for one.
