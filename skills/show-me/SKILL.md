---
name: show-me
description: Explain the current topic visually with the smallest effective view.
disable-model-invocation: true
---

Help the user understand the current topic visually. Skip the preamble and keep prose brief. Pick the smallest view that makes the key point clear. Place each visual next to the short text it supports.

The visual is this turn's explanation. Keep only the calls, files, props, states, and boundaries needed to answer the current question.

## Choose the view

| Question | View |
| --- | --- |
| Logic or algorithm | Pseudocode |
| Runtime call hierarchy | Call tree |
| UI composition, state, and ownership | Component tree |
| File responsibilities or refactor scope | Shallow file tree |
| Interactions, execution order, or data flow | Mermaid |
| UI, layout, state comparison, or a concept needing richer visuals | Focused HTML |

Use `diff` when the point is a change to an existing structure. Show the whole block when most of it is new, omitted context would hide ownership or order, or the user needs a copyable target shape. Combine views only when they explain different aspects of the question.

## HTML

Write one focused diagram, infographic, or short slide deck to `/tmp/show-me-<slug>.html`. Use real labels and data; support desktop and mobile. Open it using the browser-opening conventions in `use-local-wsl`, and report the absolute path.
