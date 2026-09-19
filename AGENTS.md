# Agent instructions

EBWiki is a Rails 7 public archive. Durable team process lives here and in `.cursor/rules/`. Cursor team kit, Compound Engineering, and Superpowers may be installed on the machine; this repo vendors the **model**, not those plugin trees. Repo rules win on conflict.

## The loop

Plan → implement → verify → review → ship. One named change per landing PR.

When starting non-trivial work, use `.cursor/skills/software-development-loop/SKILL.md`. Always-on rules in `.cursor/rules/` are binding.

### 1. Plan before large work

If the work spans multiple areas, has an unclear approach, or would touch more than a handful of files, write a short plan first (`ce-plan` / Superpowers `writing-plans` when those skills are available). Independent subsystems get separate plans and separate PRs. Do not invent a UI restyle, archive sweep, or extra cleanup while planning a named change.

### 2. Implement the named change only

Match existing Rails patterns. Prefer `lib/` for non-view logic. Remove slop you introduced (`deslop`): extra comments, defensive noise, drive-by refactors. Thermo-nuclear questions are **review guidance** (simpler framing, no 1k-line file growth, no spaghetti conditionals, logic in the right layer). Do not run a full thermo-nuclear audit on every commit.

### 3. Debug from root cause

On failure, find the root cause before proposing a fix (Superpowers `systematic-debugging`). No shotgun patches.

### 4. Verify before claiming done

No completion claim without fresh evidence (Superpowers `verification-before-completion`). Ruby: the relevant RSpec examples, plus RuboCop on touched files. UI: exercise the changed flow in the browser or the closest substitute. Do not run the full Rails suite for docs-only work. Use `.cursor/skills/verifying-before-completion/SKILL.md`.

### 5. Review

Request review when the named change is verified. Receive review by checking the codebase, not by performative agreement. Merge Approve is a human in CODEOWNERS (`@gktreviewer`). Cursor implements. Do not also request CodeRabbit, Copilot, or Factory Droid. Do not self-Approve.

Subagent-driven development only when there is an implementation plan with mostly independent tasks in this session. Do not spawn subagents for a tightly coupled one-concern change.

### 6. Ship

A landing PR is the named change plus the smallest unlock. If the diff is mixed or too large to review, split (`make-pr-easy-to-review`: do not polish around an unreviewable PR). See `.cursor/rules/landing-pr.mdc` and `.cursor/skills/splitting-oversized-prs/SKILL.md`.

PR title and body are project writing: complete sentences, name the change, no chat or first-person asides. Follow `ce-commit-push-pr` conventions when that skill is available. Do not add Compound Engineering branding unless `.compound-engineering/config.yaml` explicitly turns it on (this repo keeps it off).

## Do not

- Vendor plugin caches or copy TypeScript-only rules (`no-inline-imports`, exhaustive-switch) unless this change actually edits TypeScript.
- Restyle UI or sweep archive views unless that is the named change.
- Mark unrelated cleanup goals complete from a standards or docs PR.
