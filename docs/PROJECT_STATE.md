# PROJECT STATE

_Snapshot as of 2026-09-19._

## Repo
- `EBWiki/EBWiki`

## Project Type
- Product (community-maintained case archive)

## Current Phase
- Repo hygiene: one review path, leftover dependency PRs, then product drafts

## Current Goal
Leave the repo with one required CI suite, one review bot that can Approve
(CodeRabbit), Dependabot for grouped patch/minor updates, and no leftover
agent drafts. Visual / Hanami / Harbor work stays drafted until that path
is quiet.

## Last Completed Step
- Merged #4423 (bundler-dev updates + Dependabot inventory refresh)
- Closed leftover Copilot drafts #4424, #4387, #4399
- Removed Factory Droid auto-review (`droid-review.yml`)

## Next 3 Micro Tasks
1. Land #4421 (Puma 6.6.1 → 7.2.1) once required CI runs on the current head
2. Disable Copilot automatic PR review in GitHub repo settings
3. Keep product drafts (Harbor #4425, Hanami, staff tools) off the weekly queue

## Blockers / Risks
- #4421 is Approved but CI on the Copilot workflow-file commit is
  `action_required` (GitHub will not run `CI` after a bot edits a workflow)
- Copilot automatic review is a repo setting, not a file in git

## Technical Notes
- `droid.yml` remains for on-demand `@droid` only. It is not a required review.
- Uses polymorphic `linkable_type/linkable_id` — any new model with
  `has_many :links` must use `as: :linkable`

## PR Review Workflow
- **Required:** `CI` (RSpec, RuboCop, Brakeman, markdown links) and CodeQL
- **Review bot:** CodeRabbit only. `@coderabbitai review` if a pass is needed.
  CodeRabbit Approve counts for the review gate.
- **Human:** product correctness and any semver-major (Dependabot will not
  auto-merge those)
- Do not also ping Factory Droid or request Copilot review on the same PR

## Exit Criteria for This Phase
- No leftover Dependabot or agent-draft PRs on the weekly list
- Docs and workflows describe the same review path
- Product spikes use that path instead of adding another bot
