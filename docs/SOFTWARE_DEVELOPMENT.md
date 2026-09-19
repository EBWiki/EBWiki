# Software development model

EBWiki follows one loop for humans and agents: **plan → implement → verify → review → ship**.

This is the repo-owned model distilled from Cursor team kit, Compound Engineering, and Superpowers. Those plugins may be installed in a contributor's editor. This repository vendors the model, not the plugin file trees.

Agent entry points: `AGENTS.md`, `.cursor/rules/`, and `.cursor/skills/`. Landing-PR size detail: [Landing PRs](LANDING_PRS.md).

## Plan

Write a short plan before large or multi-area work. Independent subsystems (review-path hygiene, UI, library extract, dependency bump) get separate plans and separate pull requests.

Do not invent a UI restyle, archive sweep, or extra cleanup while planning a named change.

## Implement

Change only what the named change needs. Match existing Rails patterns. Prefer `lib/` for non-view logic.

Remove slop you introduced: extra comments, defensive noise, drive-by refactors. At review time, ask the thermo-nuclear questions as guidance (is there a simpler framing; did a file cross 1,000 lines; were conditionals bolted onto unrelated paths; is logic in the right layer). Do not run a full thermo-nuclear audit on every commit.

## Debug

Find the root cause before proposing a fix. Reproduce, read the error, check recent changes, then fix the cause. Shotgun patches are out of model.

## Verify

Do not claim done, fixed, or passing without fresh evidence.

- Ruby: the relevant RSpec examples, plus RuboCop on touched files
- UI: exercise the changed flow in the browser or the closest substitute (not a single screenshot)
- Docs-only: do not run the full Rails suite

## Review

Merge Approve is a human in CODEOWNERS (`@gktreviewer`). Cursor implements. Do not also request CodeRabbit, Copilot, or Factory Droid. Do not self-Approve.

Evaluate review comments against this codebase. Implement what is technically right; push back with reasoning when it is not.

Use subagent-driven development only when there is an implementation plan with mostly independent tasks in the same session.

## Ship

A landing pull request is one named change plus the smallest unlock. If the diff is mixed or too large to review in one pass, split it. Notes and squash do not make a mixed PR reviewable.

Public GitHub titles and bodies are project writing: complete sentences, name the change, no chat. Do not add Compound Engineering branding unless `.compound-engineering/config.yaml` explicitly turns it on (this repo keeps it off).

## Why this exists

The 73-file mixed landing PR failed more than size:

- It mixed review-path hygiene with a large view/SCSS sweep (ship)
- It invented UI work that was not the named change (plan / implement)
- It stacked extra review bots on a human CODEOWNERS path (review)
- Work was treated as ready without a verification story for each concern (verify)
