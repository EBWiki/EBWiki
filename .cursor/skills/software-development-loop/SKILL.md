---
name: software-development-loop
description: Use when starting non-trivial EBWiki work, choosing a phase of the development loop, or deciding whether to plan, implement, verify, review, or open a PR — including large features, bugs, mixed diffs, and "just ship it" pressure.
---

# Software-development loop

## Overview

EBWiki uses one loop: plan → implement → verify → review → ship. Repo rules are binding. Cursor team kit, Compound Engineering, and Superpowers skills on the machine are the detailed executors when present.

## When to Use

- Starting a feature, bugfix, or cleanup that is more than a one-line edit
- Unsure whether to plan first or start coding
- About to open a PR, claim done, or request review
- Tempted to add a second concern (UI sweep, bot deletion, extra refactor) to the current branch

## Phase routing

| Situation | Do this | Plugin skill if installed |
|-----------|---------|---------------------------|
| Multi-area or unclear approach | Write a plan; split independent subsystems | `ce-plan`, `writing-plans` |
| Named change is clear and small | Implement only that change | `ce-work` (or just edit) |
| Test failure, bug, unexpected behavior | Root cause before a fix | `systematic-debugging`, `ce-debug` |
| About to say done / fixed / passing | Run fresh verification | `verification-before-completion`, `check-compiler-errors` |
| Diff has slop you introduced | Clean your diff only | `deslop` |
| Branch is mixed or huge | Split before review | `make-pr-easy-to-review`; repo `splitting-oversized-prs` |
| Named change is verified | Request human review | `requesting-code-review`, `review-and-ship` |
| Review comments arrived | Verify, then implement or push back | `receiving-code-review` |
| Ready to land | One concern, then commit / push / PR | `ce-commit-push-pr`, `new-branch-and-pr`, `finishing-a-development-branch` |

## Hard stops

- Do not skip planning on large or multi-area work.
- Do not invent a UI restyle or archive sweep to accompany a non-UI change.
- Do not claim done without fresh evidence.
- Do not stack CodeRabbit, Copilot, or Factory Droid on the human CODEOWNERS review (`@gktreviewer`).
- Do not add Compound branding to GitHub copy.
- Do not use subagent-driven development unless there is a plan with mostly independent tasks in this session.

## Rails verification

- Ruby change → relevant RSpec + RuboCop on touched files
- UI change → exercise the changed flow (browser or closest substitute)
- Docs/rules only → no full Rails suite

## After the loop

If the working tree spans two areas, stop shipping and use `splitting-oversized-prs`.
