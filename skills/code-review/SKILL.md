---
name: code-review
description: "Review committed changes since a supplied fixed point along two axes: Standards (this repo's documented coding standards) and Spec (the path the caller passed). Use when reviewing since a commit, branch, or tag."
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

The Spec axis is the path the caller passed. If they did not pass one, skip this axis.

### 3. Identify the standards source

The Standards axis is the standards document the repo index points at. If the index has no such pointer, skip this axis.

### 4. Spawn both sub-agents in parallel

Each sub-agent performs the review directly. It does not invoke `code-review` or spawn further agents.

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The contents of the document from step 3.
- The brief: "Report, per file/hunk where relevant, every place the diff violates a documented standard: cite the standard (file + the rule). Skip anything tooling enforces. Perform this review directly in this sub-agent; do not invoke code-review or spawn additional agents. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path and contents of the file from step 2.
- The brief: "Requirements are What to build and the untitled checklist after it when those exist; otherwise the whole document. Report: (a) requirements missing or partial; (b) behaviour in the diff that wasn't asked for; (c) requirements that look implemented but where the implementation looks wrong. Quote the source line for each finding. Perform this review directly in this sub-agent; do not invoke code-review or spawn additional agents. Under 400 words."

If no spec path was supplied, skip the Spec sub-agent and note this in the final report. If no standards document was found, skip the Standards sub-agent and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the path asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
