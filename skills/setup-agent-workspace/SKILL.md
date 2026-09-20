---
name: setup-agent-workspace
description: "Bootstrap a new repository or reshape an existing one for agent work: context, tools, environment, and verification."
disable-model-invocation: true
---

# Setup agent workspace

Make a repository ready for the work the user wants to do.

Mode from the request: **bootstrap**, **reshape**, or **audit** (no writes). Named repository; ask only when missing information changes the work. Where the local-machine skill has a query or prepare script, run that script instead of reconstructing the check.

1. **Inspect.** Read the project's instructions, runtime pins, lockfiles, and standard commands. Done: you know what it requires, what is missing, and what has gone stale. The project should record runtimes, dependencies, lockfiles, and commands so it can be reproduced off this machine.
2. **Machine conventions.** Open the local-machine skill — `use-local-wsl` on WSL/Linux, `use-local-windows` on Windows — for only the topics this project needs. Done: those topic files are read. Machine paths, ports, and allowlists stay in the machine skill.
3. **Live state.** Run that skill's query script for those topics (WSL: `scripts/query.sh <topic>`). Done: every needed topic has `status=ok|missing|fail|unverified`.
4. **Diff.** Keep useful arrangements; repair gaps; remove duplication. Read [the principles](philosophy/00.md). For code repositories, adapt the [project index](shapes/agents-responsibilities.md) and [engineering standards](shapes/engineering-standards-core.md) into existing project files.
   - Missing **declared** project runtimes, dependencies, and user-level tools: install now. WSL: `use-local-wsl` `scripts/prepare-runtime.sh <repo>` (audit: `--dry-run`).
   - Machine-policy or system-service changes: propose.
   - Existing toolchains and lockfiles stay unless the user asked to migrate.
   - Audit ends here with findings.
   Done: each gap is installed, proposed, or recorded as kept.
5. **Configure.** Use `writing-for-agents` for agent-facing documents. Done: pointers have reading triggers; existing rule meaning is preserved; new decisions are proposals.
6. **Verify.** Follow the new pointers and run the project's verification command. Done: report what changed, what passed, and what remains unresolved.
