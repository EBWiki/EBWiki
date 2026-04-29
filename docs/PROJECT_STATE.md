# PROJECT STATE

_Snapshot as of 2026-04-18._

## Repo
- `EBWiki/EBWiki`

## Project Type
- # Client / Product / Internal / Experiment

## Current Phase
- Refactoring

## Current Goal
Rails 8.1 modernization (Administrate, Devise 5, Sprockets 4, security) - PR #4345 in flight

## Current Branch
- main

## Last Completed Step
Dependency hygiene branch open for review (PR #4345); CodeRabbit + Factory Droid both reviewing; Droid findings applied (signed_in? helper, polymorphic CalendarEvent links)

## Next 3 Micro Tasks
1. Resolve remaining Droid/CodeRabbit review feedback on #4345
2. Run full test suite locally against Rails 8.1
3. Merge #4345 and plan follow-up PRs for the remaining 33-file changes

## Blockers / Risks
- None currently

## Technical Notes
- Workflow files `droid.yml` and `droid-review.yml` in .github/workflows/ enable auto-review via Factory Droid
- Uses polymorphic `linkable_type/linkable_id` — ensure any new model with `has_many :links` uses `as: :linkable`

## PR Review Workflow
- Factory Droid provides automated first-pass review on every PR.
- Human review (gktreviewer) focuses on product correctness; Droid covers correctness, security, and style surface.
- See `docs/DEVELOPMENT_PROCESS.md` in the central /src workspace for the review handshake.

## Exit Criteria for This Phase
- See `Current Goal` above. Ticket this out as the phase progresses.
