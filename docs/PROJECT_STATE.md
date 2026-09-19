# PROJECT STATE

_Snapshot as of 2026-09-19._

## Repo
- `EBWiki/EBWiki`

## Project Type
- Product (community-maintained case archive)

## Current Phase
- Repo hygiene: one review path, leftover dependency PRs, then product drafts

## Current Goal
Leave the open source project in good working order: one required CI
suite, a human Approve via `CODEOWNERS`, Dependabot for grouped
patch/minor updates, and no leftover agent drafts. That is the design
bar. Graphic redesign, Hanami, and Harbor stay drafted until that path
is quiet.

## Last Completed Step
- Merged #4423 (bundler-dev) and #4421 (Puma 7.2.1)
- Closed leftover Copilot drafts #4424, #4387, #4399
- Drafted the 239-file Doppler rewrite #4420
- Removed Factory Droid workflows (`droid-review.yml`, `droid.yml`) in #4435
- Stopped using CodeRabbit as the merge reviewer: `.coderabbit.yaml`
  turns off auto-review, and `.github/CODEOWNERS` requests `@gktreviewer`

## Next 3 Micro Tasks
1. Land #4435 (this review-path PR) after a human Approve
2. Disable Copilot automatic PR review and uninstall the CodeRabbit
   GitHub App in repository settings
3. Continue archive UI quality as issue #4437 (separate landing PRs)
4. Keep product drafts (Harbor #4425, Hanami, staff tools) off the weekly queue

## Blockers / Risks
- Copilot automatic review is a repo setting, not a file in git
- CodeRabbit remains installed until a maintainer uninstalls the app;
  repo config only stops automatic reviews after this file is on `main`
- Branch protection still requires an Approve that this agent cannot give

## Technical Notes
- Uses polymorphic `linkable_type/linkable_id` — any new model with
  `has_many :links` must use `as: :linkable`

## PR Review Workflow
- **Required:** `CI` (RSpec, RuboCop, Brakeman, markdown links) and CodeQL
- **Reviewer:** a human from `.github/CODEOWNERS` (`@gktreviewer`). That
  Approve is the required review.
- **Human:** product correctness and any semver-major (Dependabot will not
  auto-merge those)
- Do not request CodeRabbit, Copilot, or Factory Droid
- Public GitHub titles and descriptions follow `docs/DESIGN.md`

## Exit Criteria for This Phase
- No leftover Dependabot or agent-draft PRs on the weekly list
- Docs and workflows describe the same review path
- Product spikes use that path instead of adding another bot
