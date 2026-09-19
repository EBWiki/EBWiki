# PROJECT STATE

_Snapshot as of 2026-09-19._

## Repo
- `EBWiki/EBWiki`

## Project Type
- Product (community-maintained case archive)

## Current Phase
- Repo hygiene: one review bot plus a human Approve, leftover
  dependency PRs, then product drafts

## Current Goal
Leave the open source project in good working order: one required CI
suite, GitHub Copilot as the only review bot (first-pass comments), a
human Approve via `CODEOWNERS`, Dependabot for grouped patch/minor
updates, and no leftover agent drafts. That is the design bar. Graphic
redesign, Hanami, and Harbor stay drafted until that path is quiet.

## Last Completed Step
- Merged #4423 (bundler-dev) and #4421 (Puma 7.2.1)
- Closed leftover Copilot drafts #4424, #4387, #4399
- Drafted the 239-file Doppler rewrite #4420
- This review-path PR removes Factory Droid workflows
  (`droid-review.yml`, `droid.yml`), adds `.github/CODEOWNERS`, and
  turns off CodeRabbit auto-review in `.coderabbit.yaml`. Copilot stays
  as the remaining review bot.
- Archive UI / VideoEmbed leftover from mixed #4435 continues as
  issue #4437, not this PR

## Next 3 Micro Tasks
1. Land #4438 (this review-path PR) after a human Approve from `@gktreviewer`
2. Uninstall the CodeRabbit GitHub App in repository settings. Leave
   Copilot code review enabled.
3. Continue archive UI quality as issue #4437 (separate landing PRs)

Product drafts (Harbor #4425, Hanami, staff tools) stay off the weekly
queue until this review path is quiet.

## Blockers / Risks
- Copilot code review is a repo setting, not a file in git. Leave it on.
- CodeRabbit remains installed until a maintainer uninstalls the app;
  repo config only stops automatic reviews after this file is on `main`
- Branch protection still requires an Approve that this agent cannot give

## Technical Notes
- Uses polymorphic `linkable_type/linkable_id` — any new model with
  `has_many :links` must use `as: :linkable`

## PR Review Workflow
- **Required:** `CI` (RSpec, RuboCop, Brakeman, markdown links) and CodeQL
- **Review bot:** GitHub Copilot. First-pass comments only. Does not
  Approve. Leave it enabled. Do not request Copilot as an Approver.
- **Reviewer:** a human from `.github/CODEOWNERS` (`@gktreviewer`). That
  Approve is the required review.
- **Human:** product correctness and any semver-major (Dependabot will not
  auto-merge those)
- Do not request CodeRabbit or Factory Droid
- Public GitHub titles and descriptions follow `docs/DESIGN.md`

## Exit Criteria for This Phase
- No leftover Dependabot or agent-draft PRs on the weekly list
- Docs and workflows describe the same review path
- Product spikes use that path instead of adding another bot
