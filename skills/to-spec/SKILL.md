---
name: to-spec
description: Form a concise, agreed task specification for a small or medium-sized task.
disable-model-invocation: true
---

# To Spec

Turn the current discussion or supplied source into one concise specification that the user and agent agree on as the task's authoritative requirements.

1. **Clarify.** Establish the intended behavior and what counts as completion. Check relevant code or existing documents when facts need resolving; ask the user about unsettled choices that change the task's meaning or scope. Distinguish confirmed decisions from proposals.
2. **Draft.** Write one Markdown file at the user's chosen path, or follow the repository's temporary-document conventions; otherwise use `tmp/<task>-spec.md`. Include the behavior to implement, observable completion conditions, and necessary boundaries or confirmed decisions. Omit optional sections without meaningful content. Leave implementation details to implementation unless they are part of an agreed constraint. Reference existing material where it supplies the needed context.
3. **Agree.** Present the path and any choices still needing confirmation. Revise the same document with the user until it accurately expresses the agreed task.

Complete when the user approves the document and no unresolved choice affects its requirements or completion conditions. Return its actual path.
