---
name: verifying-before-completion
description: Use when about to claim work is complete, fixed, passing, or ready for review — including after implementation, a suspected fix, or before opening a PR.
---

# Verifying before completion

## Overview

No completion claim without fresh verification evidence. Confidence is not evidence.

## Gate

1. Name the command or browser path that would prove the claim.
2. Run it now. Read the output and the exit code.
3. Claim only what that output shows.

Skip a step = do not claim done.

## What counts

| Claim | Evidence |
|-------|----------|
| Ruby behavior works | Relevant RSpec output, 0 failures |
| Style/lint clean | RuboCop on touched files, 0 offenses you introduced |
| UI works | Exercised the changed flow, not a single static screenshot |
| Bug fixed | Original symptom re-checked after the fix |
| Docs/rules only | `git diff --stat` matches the named change; no app code claimed |

## Hard stops

- Do not say "should pass", "looks good", or "done" before the run.
- Do not use an earlier run as proof.
- Do not run the full Rails suite to decorate a docs-only PR.
- Do not treat a compile/lint pass as proof of a behavior fix.

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "I am confident" | Run the command. |
| "Just this once" | No exceptions. |
| "The agent said success" | Read the output yourself. |
| "A screenshot is enough" | For UI, exercise the flow. |
