---
name: code-review
description: "Independently review committed changes since a supplied revision against project standards and requirements from a file or the agreed conversation."
---

# Code Review

Review through two independent perspectives:

- **Standards**: does the change violate the project's documented engineering standards?
- **Spec**: does it implement the agreed behavior correctly, without omissions, regressions, or unrequested scope?

Keep the perspectives distinct during investigation; combine their evidence into a useful report afterward. This skill reviews and reports. The implementing caller owns code changes and commits.

## 1. Pin the range

Use the fixed point supplied by the caller; ask if none was supplied. Resolve it and `HEAD` to commit IDs so all reviewers inspect the same snapshot. Use `git diff <base>...<target>` and `git log <base>..<target> --oneline`. State that the diff starts at the merge base; if that differs from the supplied base, clarify the intended range before proceeding.

Confirm the range is valid and non-empty before delegation. Uncommitted changes are outside this review; report that exclusion without committing them. An invalid range or no changes to inspect is not a successful review.

## 2. Establish the sources

For **Spec**, read the supplied file and relevant linked decisions, or use the caller's account of requirements and confirmed decisions from the current conversation. Separate requirements, acceptance criteria, and explicit exclusions from proposals and background explanation. A heading or checklist format does not establish approval. Ask about ambiguity only when it changes the review's conclusion.

For **Standards**, follow the repository's agent index to its engineering standards and relevant local rules. Existing ADRs can explain deliberate choices.

State which sources each perspective uses. If a source is unavailable, mark that perspective as skipped and explain the limit. If neither perspective has an adequate source, report the blocker rather than launching an empty review or inventing a spec or standards document.

## 3. Dispatch independent reviewers

Launch one fresh-context, read-only sub-agent per applicable perspective, in parallel when both apply. Give each the pinned range, repository location, source material, and its review brief. Each reviewer investigates directly without invoking this skill or delegating further.

**Standards brief**: check applicable documented rules and cite the violated rule for each finding. Distinguish deliberate, justified departures from violations. Personal style preferences, speculative refactors, and coverage targets absent from the project's standards are not defects. Avoid duplicating mechanical diagnostics already supplied by tooling.

**Spec brief**: account for every agreed requirement, identify missing or partial behavior, and inspect implemented behavior for errors and regressions. Check exclusions and report behavior outside the requested scope. Cite the requirement or existing contract that establishes the expected behavior.

Both reviewers read the surrounding implementation, callers, tests, and contracts needed to check consequences; the diff is the entry point, not the whole evidence. Focus on problems introduced or exposed by the change. Distinguish pre-existing issues. Test gaps warrant findings when they leave a concrete relevant risk unverified, not merely because more tests are possible.

Each finding includes its perspective, severity, file and line, triggering conditions, impact, and supporting evidence. Reviewers distinguish established defects from unresolved questions and state what they inspected and any verification limits. They do not edit code or commit. A launch or reviewer failure is an incomplete review; report the blocker.

## 4. Check and report

Verify findings against the code and source material. Resolve duplicates and disagreements with evidence; preserve unresolved uncertainty as a question rather than turning it into a confirmed defect. Keep the originating perspective or perspectives on merged findings.

Present substantiated findings in severity order, followed by open questions, assumptions, and review limits. If there are no findings, say so within the inspected scope. Report which perspectives ran and any skipped work or checks not performed; missing review is not a pass.

Complete when each applicable review has returned, its findings have been checked, and the report identifies actionable issues and remaining uncertainty. Completion of a review does not mean the code is defect-free or that its findings have been fixed.

## Reviewing corrections

When the caller supplies committed fixes, pin the new target and independently recheck the affected findings and relevant regression risks. Retain the original requirements and baseline; use the previous review target to identify the corrections. Report whether each previous finding is resolved, still present, or inconclusive, plus any new substantiated issues. The same investigation and reporting rules apply; rechecking does not transfer code changes to the reviewers.
