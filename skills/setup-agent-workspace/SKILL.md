---
name: setup-agent-workspace
description: "Bootstrap a new repository or reshape an existing one for agent work: context, tools, environment, and verification."
disable-model-invocation: true
---

# Setup agent workspace

Make a **project** repository ready for the work the user wants to do. `~/.agents` is not a project repository.

Mode from the request: **bootstrap**, **reshape**, or **audit** (no writes). Named repository; ask only when missing information changes the work. Where the machine skill has a query or prepare script, run that script instead of reconstructing the check.

1. **Inspect.** Read the project's instructions, runtime pins, lockfiles, and standard commands. Done: you know what it requires, what is missing, and what has gone stale. The project should record runtimes, dependencies, lockfiles, and commands so it can be reproduced off this machine.
2. **Machine conventions.** Pick the machine skill by where the repository lives, not which OS this agent is on. Linux path (including `/home/ark/CODE`): `use-local-wsl` — from Windows, `wsl.exe -d Ubuntu -- bash -lc` (`use-local-windows` WSL_INTEROP). Windows drive path the user named as a Windows project: `use-local-windows`. Open only the topics this project needs (usually INSTALL_POLICY). The channel table is readable without running the four-column update. Done: those topic files are read. Machine paths, ports, and allowlists stay in the machine skill.
3. **Live state.** Linux repo: `use-local-wsl` `scripts/query.sh <topic>` (from Windows, the same command inside `wsl.exe -d Ubuntu -- bash -lc`). Done: every needed topic has `status=ok|missing|fail|unverified`. Do not reconstruct that check on Windows.
4. **Diff.** Keep useful arrangements; repair gaps; remove duplication. Read [the principles](philosophy/00.md). For code repositories, adapt the [project index](shapes/agents-responsibilities.md) and [engineering standards](shapes/engineering-standards-core.md) into existing project files.
   - Missing **declared** project runtimes, dependencies, and user-level tools: install now with the machine skill's prepare script. Linux: `use-local-wsl` `scripts/prepare-runtime.sh <repo>` (audit: `--dry-run`; from Windows, inside `wsl.exe`). That installs pins the project already declared; it is not INSTALL_POLICY's named product install.
   - Machine-policy or system-service changes: propose.
   - Existing toolchains and lockfiles stay unless the user asked to migrate.
   - Linux work stays in WSL; Windows does not grow a second project toolchain.
   - Audit ends here with findings.
   Done: each gap is installed, proposed, or recorded as kept.
5. **Configure.** Use `writing-for-agents` for the project's agent-facing documents. Done: pointers have reading triggers; existing rule meaning is preserved; new decisions are proposals.
6. **Verify.** Follow the new pointers and run the project's verification command. Done: report what changed, what passed, and what remains unresolved.
