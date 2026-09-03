---
name: implement
description: "Implement one written ask: TDD at the seams, then review and commit."
disable-model-invocation: true
---

Build what is already written down. Do not reopen the plan.

One invocation, one unit of work, current branch (do not create a branch).

There must be a **source**. Load the path, title, or URL the user passed. If they did not pass one, ask which file to load. Do not search `.scratch` or `.notes`. Do not classify the source. Do not create `.scratch`.

Consume this tree when it already exists:

    .scratch/<effort>/
      map.md
      spec.md
      issues/
        <NN>-<slug>.md

A file under `.scratch/<effort>/issues/` is bound by that effort's `spec.md` (effort root, not a file inside `issues/`).

If the loaded file has a `Status:` field: **Claim** first (`Status: claimed` and save) before building. Read every `Uses decisions:`, `Uses research:`, and `Blocked by:` on the header; follow those planning pointers to each binding's source file. After the work: **Resolve** — write `## Answer` aligned with the untitled checklist after What to build; set `Status: resolved`; update downstream `Uses *` if needed.

If there is no `Status:` field, do not Claim or Resolve.

Restate What to build (or the brief) in one or two lines, then start.

**Testing seams.** If the loaded file has a Testing seams section, those are the pre-agreed seams. If the file is under `.scratch/<effort>/issues/`, also read that effort's `spec.md` Testing seams (and Out of scope as a bound). Treat those seams as already confirmed when calling the Skill tool with `"tdd"`; do not ask the user to confirm them again.

## Process

### 1. Load the ask

**Done when** the source is loaded and restated in one or two lines. If `Status:` is present, `claimed` is saved and header pointers have been read.

### 2. Build

Call the Skill tool with `"tdd"` at those seams, one red-green slice at a time. Typecheck and run single test files as you go.

Record `git rev-parse HEAD` as the review fixed point before the first commit of this run.

**Done when** `git rev-parse HEAD` is recorded, and the working tree meets the ask: the untitled checklist after What to build, or the whole loaded brief.

### 3. Gate, commit, review, resolve

Run the delivery gate the repo documents.

Commit to the current branch.

Call the Skill tool with `"code-review"`, passing the fixed point recorded in step 2 and the path loaded in step 1. Report its two axes; do not merge them. Do not silently rewrite the plan from the findings.

If `Status:` was present, **Resolve** as above.

**Done when** `HEAD` has moved past the fixed point recorded in step 2, code-review has run against that range with the path loaded in step 1, and a `Status:` source (if any) is resolved.
