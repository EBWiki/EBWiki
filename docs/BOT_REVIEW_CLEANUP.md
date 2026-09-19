# One review bot, one human Approve

EBWiki used to run several review and coding agents on the same PRs.
Comments conflicted, required Approve was unclear, and leftover bot
drafts stayed open.

The documented review path is now:

```
CI + CodeQL              → required checks (merge truth)
GitHub Copilot           → the one review bot (first-pass comments only)
CODEOWNERS @gktreviewer  → the only Approve that counts
Dependabot               → grouped patch/minor + security PRs
Cursor                   → coding agent for this cleanup stream
```

Copilot does **not** Approve and cannot replace a human. Do not request
Copilot as an Approver. The PR author (`mnyon-grandkru`) cannot
self-Approve.

## How to set the Cursor goal

In Cursor, a long-running goal is a single objective the agent keeps working
toward across turns. Set it when you want cleanup to stay the north star
instead of a one-off PR.

Recommended objective:

> Leave EBWiki with one required CI truth, GitHub Copilot as the only
> review bot (comments only), a human Approve via CODEOWNERS, Dependabot
> for grouped patch/minor updates, and no leftover agent drafts.

That is narrower and more useful than “meet high design standards.” Visual
design, Hanami, and Harbor stay on their own drafts until this review path
is quiet.

## Current inventory (2026-09-19)

### Keep

| Thing | Role |
|---|---|
| `CI` (`.github/workflows/ci.yml`) | RSpec, RuboCop, Brakeman, markdown links. This is merge truth. |
| CodeQL (`dynamic/github-code-scanning/codeql`) | Security scan. |
| Dependabot (`.github/dependabot.yml`) | Grouped weekly patch/minor + security. Ignores semver-major. |
| Dependabot auto-merge | Patch/minor only, Dependabot actor only (landed with #4421). |
| Publish Docker Image | Deploy artifact, not review. |
| GitHub Copilot code review | The remaining review bot. First-pass comments only. Does **not** Approve. Leave it enabled. |
| `.github/CODEOWNERS` | Requests `@gktreviewer`. That human Approve is the required review. |

### Removed or retired

| Bot | Status |
|---|---|
| Factory Droid Auto Review (`droid-review.yml`) | Deleted in this PR. Do not restore. |
| Factory Droid Tag (`droid.yml`) | Deleted in this PR. Do not restore. |
| CodeRabbit | Not the remaining bot. OSS plan rate-limits after one included review. Unofficial `CHANGES_REQUESTED` does not count as Approve. `.coderabbit.yaml` keeps `auto_review: false`. Do not `@coderabbitai review`. A maintainer should uninstall the GitHub App. |
| Copilot coding agent (`copilot-swe-agent`) | Not the review bot. Do not assign it to issues Cursor is already on. That is how #4424 duplicated #4421. |

`docs/PROJECT_STATE.md` (April 2026) still said “Droid first-pass, human
second.” That is stale. Copilot is the first-pass commenter now.

### Leftover bot drafts

Closed 2026-09-19: #4424 (duplicate Puma), #4387 (239-file exploration),
#4399 (240-file Droid-reclassify rewrite). This PR is the small redo of #4399.

Human feature drafts (Hanami, Harbor, staff tools, maps) are out of scope
here. Do not close those as part of bot cleanup.

## Recommended end state

One review bot. One human Approve. No second bot that comments “just in case.”

```
CI + CodeQL     → required checks (merge truth)
Copilot         → first-pass comments only (not an Approve)
CODEOWNERS      → the required Approve (`@gktreviewer`)
Dependabot      → grouped patch/minor + security PRs
Cursor          → coding agent for this cleanup stream
Human           → product/merge for majors and anything CI cannot see
```

Turn off or stop using:

- **Droid Auto Review** — `.github/workflows/droid-review.yml` is deleted.
- **Droid Tag** — `.github/workflows/droid.yml` is deleted. A maintainer
  may drop `FACTORY_API_KEY` after this PR lands.
- **CodeRabbit** — `.coderabbit.yaml` disables automatic reviews. A
  maintainer should uninstall the GitHub App. Do not `@coderabbitai review`.
  The OSS hourly limit and unofficial `CHANGES_REQUESTED` reviews are why
  this is no longer the path.
- **Copilot coding agent as a default** — do not assign Copilot to issues
  that Cursor is already on.
- **Code Climate README badges** — `docs/DEVELOPMENT.md` still mentions
  CodeClimate. Confirm the app is gone; remove the badges if it is.

Leave **Copilot code review** enabled. It is the remaining review bot.
Its comments do not clear `REVIEW_REQUIRED`; `@gktreviewer` still must
Approve. Do not disable Copilot.

## What “high design standards” means here

“Design” here is the open source project: how PRs land, what CI means,
what stays on the ready list, and whether docs match git. It is not
graphic design and it is not a reason to restyle archive pages in a
hygiene PR.

1. A PR has one required CI suite, one review bot (Copilot comments),
   and one human Approve.
2. Semver-major and product changes still need a human. Bots do not
   auto-merge those. Copilot comments are not an Approve.
3. Agent drafts that are not the landing PR get closed the same week they appear.
4. Docs that describe the review handshake match the workflows (`docs/PROJECT_STATE.md`, `docs/DEVELOPMENT.md`).
5. Visual / product redesign (Harbor, Hanami, staff tools) is a later phase.

## Execution plan

### Phase 0 — stop the bleeding

Done: closed #4387, #4399, #4424. Merged #4423 and #4421. No open
Dependabot PRs remain.

Rule going forward: if an Approve is needed, request a human from
`CODEOWNERS`. Leave Copilot comments in place. Do not `@coderabbitai review`.

### Phase 1 — make roles explicit in git

In this PR:

1. Deleted `.github/workflows/droid-review.yml` and `.github/workflows/droid.yml`.
2. Rewrote `docs/PROJECT_STATE.md` and the CI paragraph of
   `docs/DEVELOPMENT.md`. Removed dead Code Climate badges from `README.md`.
3. Still needs a maintainer: uninstall the CodeRabbit GitHub App and
   remove the `FACTORY_API_KEY` secret. Those are not files in git.
   Leave Copilot code review enabled.
4. Documented public GitHub copy in `docs/DESIGN.md`.
5. Added `.github/CODEOWNERS` (`@gktreviewer`) and `.coderabbit.yaml`
   (`reviews.auto_review.enabled: false`).

Already landed in #4421 (not this PR): the
`github.actor == 'dependabot[bot]'` guard on
`dependabot-auto-merge.yml`, so `pull_request_target` on `main` skips
rewritten Dependabot PRs instead of failing fetch-metadata.

Archive UI and VideoEmbed work is out of this PR. That continues on
issue #4437 (the leftover UI from former mixed #4435).

### Phase 2 — settings that live outside git

A maintainer with admin on `EBWiki/EBWiki` should:

1. Confirm branch protection / rulesets: required checks are `CI` jobs +
   CodeQL only. Copilot comments must not be a required Approve.
   CodeRabbit and Droid must not be required. Require a review from
   Code Owners if that setting is not already on.
2. Uninstall unused GitHub Apps: CodeRabbit, Factory Droid, and Code
   Climate if the badges are dead. Leave Copilot code review installed.
3. Leave Dependabot and CodeQL installed.

### Phase 3 — after the review path is quiet

The UI and architecture bar is in `docs/DESIGN.md`. Only then pick up
product design work (Harbor spike #4425, Hanami drafts, staff tools).
Those PRs use this review path and that design bar, not a new bot or a
new CSS framework.

## Decision

Factory Droid is removed from git. CodeRabbit is retired as a review
bot (`auto_review` off; uninstall the app). GitHub Copilot is the one
remaining review bot and leaves first-pass comments only. Required
Approve is `@gktreviewer` via `CODEOWNERS`. A maintainer should delete
`FACTORY_API_KEY` and uninstall the CodeRabbit app after this PR lands.
Leave Copilot code review on.

## Out of scope

- Archive UI quality and VideoEmbed (issue #4437 / former mixed #4435).
  Those are separate landing PRs after this review path lands.
- Rewriting CI into path-aware jobs (#4399). Useful later; not required to stop bot pile-up.
- Hanami / Harbor / maps / photos drafts.
- Semver-major gem migrations other than Puma 6 → 7 (landed in #4421).
  Puma 7 → 8 stays deferred.
