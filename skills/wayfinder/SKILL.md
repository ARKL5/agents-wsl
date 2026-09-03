---
name: wayfinder
description: Chart a huge effort as a shared map of decision tickets and work that map until the way to the destination is clear. Use when the human has already decided the work will not fit one grill-with-docs session.
disable-model-invocation: true
---

This skill **is** grill-with-docs on a **map**: call the Skill tool twice, for `"grilling"` and `"domain-modeling"`. That pair is the session kernel. Do not call it again as extra chart beats.

The **map** is an **index**, not a store. A **decision ticket** holds one decision. After each grilling round, write settled bindings into the map and tickets. Glossary and ADR writes belong to domain-modeling. Do not change product code unless the loaded map header has `Execute-in-wayfinding: yes`.

Refer to every map and ticket by **name** (its title). A name may wrap a link; do not narrate bare ids.

## The Map

```
.scratch/<effort>/
  map.md
  spec.md
  issues/
    <NN>-<slug>.md
```

`<effort>` is kebab-case from the **destination**. This skill writes `map.md` and wayfinding tickets. It does not write `spec.md` or implementation tickets.

### Required reading

Before asking or writing, load: `map.md` if it exists; the current ticket if working one; every planning file those headers point at (`Uses decisions`, `Uses research`, `Blocked by`, and paths in the body). Follow those pointers until each binding's source file (a ticket, a research note, an ADR, a glossary entry). Do not re-plan a decision that already has a file.

### The map body

```markdown
# <title>

Effort state: active

## Destination

<what reaching the end of this map looks like: one or two lines>

## Notes

<this effort's pointer list: glossary, ADRs, tickets to read — not skills to invoke>

## Decisions so far

- [<closed ticket title>](link): <one-line gist of the answer>

## Not yet specified

<in-scope fog you cannot ticket yet>

## Out of scope

<work ruled beyond the destination>
```

**Fog or ticket:** write a ticket when the question is already sharp (even if blocked). Write **Not yet specified** when you cannot phrase the question yet. Do not pre-slice fog into empty tickets.

### Tickets

`.scratch/<effort>/issues/<NN>-<slug>.md`, numbered from `01` (skip used numbers). `Type` is a label, not a skill dispatcher.

```markdown
# <title>

**Type:** research | prototype | grilling | task
**Blocked by:** None | <upstream titles>
**Uses decisions:** None | <upstream decision titles>
**Uses research:** None | <upstream research titles>
**Status:** ready-for-agent

## Question

## Answer
```

**research:** findings live in their own file; `## Answer` is a pointer only. **prototype:** a cheap artifact; the ticket links it. Do not require Skill `"research"` or `"prototype"`.

### Verbs

**Claim.** Set `Status: claimed` and save.

**Done when** that ticket file has `Status: claimed`.

**Resolve (decision).** Write `## Answer`; set `Status: resolved`; append one gist line plus the title link to the map's **Decisions so far**; before closing, add `Uses decisions` or `Uses research` on still-open (status is neither `resolved` nor `wontfix`) downstream tickets that consume this answer. Assets are linked from the ticket, not pasted in.

**Done when** `## Answer` is filled, `Status` is `resolved`, Decisions so far has the gist+link, and downstream `Uses *` are updated.

**Frontier.** A ticket is on the frontier when: `Effort state: active`; `Status` is `ready-for-agent`, `ready-for-human`, or `claimed`; `Blocked by` is satisfied (`None`, or every listed upstream is `resolved`); no competing claim. Numbered order is the order.

**Blocking.** `Blocked by` lists only upstream titles. Write `None` when there is none. Listed upstream unlocks only at `resolved`; `wontfix` does not unlock. To take a ticket off the frontier as out of scope: `wontfix` (or delete), one line in map **Out of scope** (gist + why, title link). It does not go in Decisions so far.

## Chart the map

User invokes with a loose idea and no map path. Pick kebab `<effort>` from the destination.

If the kernel surfaces no fog (the way to the destination is already clear), say so and wait for the human to say whether to write the files. Do not create an empty effort on your own.

1. **Name the destination.** One or two lines. It fixes the scope.

   **Done when** Destination is one or two lines.

2. **Map the frontier.** Breadth-first: open decisions takeable now, remaining fog in **Not yet specified**.

   **Done when** first-wave questions and remaining fog are listed, or the human has declined to write files.

3. **Write the map** from the template: Destination and Notes filled, Decisions so far empty, fog in **Not yet specified**, Effort state active. Create `.scratch/<effort>/` if the human wants the files.

   **Done when** `.scratch/<effort>/map.md` exists with those sections, or the human declined.

4. **Write the tickets** you can specify now from the ticket template, then wire `Blocked by` / `Uses *`. Unspecifiable questions stay in **Not yet specified**.

   **Done when** each specified question is `issues/<NN>-<slug>.md` numbered from `01`, every header has `Blocked by` and `Uses *` (or `None`), and unspecified questions appear only in Not yet specified.

## Work through the map

User invokes with a map (path, title, or URL). If none, ask which map. Effort = the directory that already holds that `map.md`. Do not search `.scratch`.

A ticket is optional. If the user named one, use it. Otherwise take the first **Frontier** ticket in order.

1. Load the map and do **Required reading**.

   **Done when** `map.md` is loaded and pointed-to planning files are read, or the user has been asked which map.

2. **Claim** that ticket.

   **Done when** that file has `Status: claimed`.

3. Work the **Question** with the session kernel. After each grilling round, write settled bindings.

   **Done when** the human's answers for this ticket are in, or research/prototype assets exist and are pointed to.

4. **Resolve (decision).**

   **Done when** the Resolve (decision) criterion above holds.

5. Add newly-surfaced tickets (write then wire). Graduate fog the answer made specifiable, clearing each graduated patch from **Not yet specified**. If a ticket sits beyond the destination, **Blocking** it out of scope. If the decision invalidates other parts of the map, update or delete those tickets.

   **Done when** each newly-specifiable question is a wired ticket file, each graduated patch is gone from Not yet specified, and each out-of-scope ticket (if any) is `wontfix` or deleted with one Out of scope line.
