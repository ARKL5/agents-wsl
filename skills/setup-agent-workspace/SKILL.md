---
name: setup-agent-workspace
description: "Bootstrap a new repository or reshape an existing one for agent work: context, tools, environment, and verification."
disable-model-invocation: true
---

# Setup agent workspace

Make a **project** repository ready for the work the user wants to do. `~/.agents` is not a project repository.

Mode from the request: **bootstrap**, **reshape**, or **audit** (no writes). Named repository; ask only when missing information changes the work. Where the machine skill has a query or prepare script, run that script instead of reconstructing the check.

1. **Inspect.** Read the project's instructions, runtime pins, lockfiles, and standard commands. Done: you know what it requires, what is missing, and what has gone stale. The project should record runtimes, dependencies, lockfiles, and commands so it can be reproduced off this machine.
2. **Machine conventions.** Pick the machine skill by where the repository lives, not which OS this agent is on. Linux path: `use-local-wsl`. Windows drive path the user named as a Windows project: `use-local-windows`. Cross-OS entry is this OS machine skill's interop topic. Open only the topics this project needs (usually INSTALL_POLICY). Done: those topic files are read. Machine paths, ports, and allowlists stay in the machine skill.
3. **Live state.** Run that machine skill's query script for those topics. Done: the script has been run and its live status is in hand.
4. **Diff.** Keep useful arrangements; repair gaps; remove duplication. Read [the principles](philosophy/00.md). For code repositories, adapt the [project index](shapes/project-index.md) and [engineering standards](shapes/engineering-standards.md) into existing project files.
   - Missing **declared** project runtimes, dependencies, and user-level tools: install now with that machine skill's prepare script (audit: dry-run). That installs pins the project already declared; it is not INSTALL_POLICY's named product install.
   - Machine-policy or system-service changes: propose.
   - Existing toolchains and lockfiles stay unless the user asked to migrate.
   - Audit ends here with findings.
   Done: each gap is installed, proposed, or recorded as kept.
5. **Configure.** Use `writing-for-agents` for the project's agent-facing documents. Done: pointers have reading triggers and real targets; existing rule meaning is preserved; new decisions are proposals.
6. **Verify.** Follow the new pointers and run the project's verification command. Done: report what changed, what passed, and what remains unresolved.
