---
name: setup-agent-workspace
description: "Initialize a new project repository for agent work."
disable-model-invocation: true
---

# Setup agent workspace

Initialize a new project repository so an agent can find its context, tools, and verification command.

1. **Define.** Record the project's purpose, users, deployment boundary, non-goals, runtime, dependencies, lockfiles, and standard commands.
2. **Prepare.** Read the machine skill for the repository location and run its query and prepare scripts for declared runtimes. Keep machine paths, ports, and allowlists in the machine skill.
3. **Configure.** Use `writing-for-agents` to create the project's `AGENTS.md` and, when needed, `docs/agents/engineering-standards.md`. Use the [project index](shapes/project-index.md) and [engineering standards](shapes/engineering-standards.md) shapes. Create a README only when the user explicitly requests one.
4. **Verify.** Follow the new pointers and run the project's verification command. Report what changed, what passed, and what remains unresolved.

A new project starts with no existing project rules to preserve. Do not add compatibility layers or migration guidance unless the user requests them.
