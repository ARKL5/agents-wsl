---
name: setup-agent-workspace
description: "Bootstrap a new repository or reshape an existing one for agent work: context, tools, environment, and verification."
disable-model-invocation: true
---

# Setup agent workspace

Make a repository ready for the work the user wants to do.

Choose the mode from the request: **bootstrap** a new workspace, **reshape** an existing one, or **audit** it without writing. Use the named repository or area; ask only for missing information that changes the work.

1. **Inspect.** Read the project instructions, relevant source and configuration, tools, environment, and verification commands. Find what works, what is missing, and what has gone stale.
2. **Shape.** Read [the principles](philosophy/00.md). Keep useful arrangements, repair gaps, and remove duplication. For code repositories, adapt the [project index](shapes/agents-responsibilities.md) and [engineering standards](shapes/engineering-standards-core.md) into existing project files. An audit ends with located findings and recommendations.
3. **Apply.** Use `writing-for-agents` for agent-facing documents. Configure the context, tools, environment, and checks needed for the purpose. Point to real sources with clear reading triggers. Preserve the meaning of existing rules; present new decisions as proposals.
4. **Verify.** Follow the new pointers and run the verification commands. Report what changed, what passed, and what remains unresolved.

Start with a clear purpose, a useful index, and a working verification loop. Add structure as the work needs it.
