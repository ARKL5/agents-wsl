---
name: code-review
description: "Review committed changes since a supplied fixed point along two axes: Standards (this repo's coding standards plus Fowler smells) and Spec (the ticket, spec, or notes path the caller passed). Use when reviewing since a commit, branch, or tag."
---

Two-axis review of the diff between `HEAD` and a fixed point the caller supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the path the caller passed?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

## Process

### 1. Pin the fixed point

Whatever the caller said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

The review is `git diff <fixed-point>...HEAD` (three-dot, merge-base). Uncommitted work is outside this review: commit first if it should be in. Also note `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside two parallel sub-agents.

### 2. Identify the spec source

The Spec axis is the path the caller passed. If they did not pass one, skip the **Spec** sub-agent and report "no spec path supplied".

If that file has **What to build**, requirements are that section and the untitled checklist after it. Remaining spec acceptance that file does not own is not missing. If the path is under `.scratch/<effort>/issues/`, also pass that effort's `spec.md` **Out of scope** as a bound (conflict: spec wins).

Otherwise the whole loaded file is the ask.

### 3. Identify the standards source

The Standards axis reads the repo's documented coding standards. If the repo has none, the smell baseline below is the whole documented floor.

The **smell baseline** always applies: a fixed set of Fowler code smells (_Refactoring_, ch.3). Two rules bind it:

- **The repo overrides.** A documented standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

Each sub-agent performs its review directly. It does not invoke `code-review` or spawn further agents.

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The repo's documented coding standards when they exist, **plus the smell baseline from step 3** pasted in full (the sub-agent has no other access to it). If the repo has none, the baseline only.
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard; and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Perform this review directly in this sub-agent; do not invoke code-review or spawn additional agents. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path and contents of the file from step 2. If that path is under `.scratch/<effort>/issues/`, also that effort's `spec.md` Out of scope.
- The brief: "Requirements are What to build and the untitled checklist after it when those exist; otherwise the whole document. When the path is under `.scratch/<effort>/issues/`, treat that effort's `spec.md` Out of scope as a bound; spec wins on conflict. Other spec acceptance this file does not own is not missing. Report: (a) requirements missing or partial; (b) behaviour in the diff that wasn't asked for, including anything in Out of scope; (c) requirements that look implemented but where the implementation looks wrong. Quote the source line (or Out of scope line) for each finding. Perform this review directly in this sub-agent; do not invoke code-review or spawn additional agents. Under 400 words."

If no spec path was supplied, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Open with a short summary of the diff. Then present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings.

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes.
