# Spike: one review path, fewer bots

EBWiki currently runs several review and coding agents on the same PRs. That
is the opposite of a high design bar: comments conflict, required Approve is
unclear, and leftover bot drafts stay open.

This spike is now the Phase 1 PR: Droid auto-review is removed, review
docs match CodeRabbit + CI, and leftover Copilot drafts are closed.

## How to set the Cursor goal

In Cursor, a long-running goal is a single objective the agent keeps working
toward across turns. Set it when you want cleanup to stay the north star
instead of a one-off PR.

Recommended objective:

> Leave EBWiki with one required CI truth, one review bot that can Approve,
> Dependabot for grouped patch/minor updates, and no leftover agent drafts.

That is narrower and more useful than “meet high design standards.” Visual
design, Hanami, and Harbor stay on their own drafts until this review path
is quiet.

## Current inventory (2026-09-19)

### Keep — these are not review bots

| Thing | Role |
|---|---|
| `CI` (`.github/workflows/ci.yml`) | RSpec, RuboCop, Brakeman, markdown links. This is merge truth. |
| CodeQL (`dynamic/github-code-scanning/codeql`) | Security scan. |
| Dependabot (`.github/dependabot.yml`) | Grouped weekly patch/minor + security. Ignores semver-major. |
| Dependabot auto-merge | Patch/minor only, Dependabot actor only (landed with #4421). |
| Publish Docker Image | Deploy artifact, not review. |

### Overlapping review / coding agents — this is the mess

| Bot | How it fires | What it actually does on #4421 |
|---|---|---|
| CodeRabbit | Repo app; `@coderabbitai review` | Can **Approve**. This is what unblocked #4423. |
| Factory Droid Auto Review | `droid-review.yml` on opened / ready / reopened | First-pass review. Does **not** run on `synchronize`, so a rewritten PR gets no new review. |
| Factory Droid Tag | `droid.yml` on `@droid` | Coding agent, not an Approve gate. |
| Copilot code review | GitHub app `copilot-pull-request-reviewer` | COMMENTED / “changes recommended.” Does **not** Approve. |
| Copilot coding agent | `copilot-swe-agent` | Opens its own PRs. Left #4424 (closed), #4387, #4399. |
| Cursor cloud agent | This session | Implementation. Not a GitHub required reviewer. |
| github-advanced-security | Code scanning comments | Inline CodeQL notes. Fine if CodeQL stays. |

`docs/PROJECT_STATE.md` (April 2026) still says “Droid first-pass, human
second.” That is stale and is why agents keep stacking.

### Leftover bot drafts

Closed 2026-09-19: #4424 (duplicate Puma), #4387 (239-file exploration),
#4399 (240-file Droid-reclassify rewrite). This PR is the small redo of #4399.

Human feature drafts (Hanami, Harbor, staff tools, maps) are out of scope
here. Do not close those as part of bot cleanup.

## Recommended end state

One job per role. No second bot that comments “just in case.”

```
CI + CodeQL     → required checks (merge truth)
CodeRabbit      → the one review bot; Approve counts
Dependabot      → grouped patch/minor + security PRs
Cursor          → coding agent for this cleanup stream
Human           → product/merge for majors and anything CI cannot see
```

Turn off or stop using:

- **Droid Auto Review** — delete `.github/workflows/droid-review.yml`. CodeRabbit already covers first-pass review and can Approve.
- **Copilot code review** — disable the repo/org automatic Copilot review. It cannot clear `REVIEW_REQUIRED` and it cited the stale July Dependabot plan on #4421.
- **Copilot coding agent as a default** — do not assign Copilot to issues that Cursor is already on. That is how #4424 duplicated #4421.
- **Droid Tag** — optional. Keep `.github/workflows/droid.yml` only if someone still wants on-demand `@droid`. Otherwise delete it and drop `FACTORY_API_KEY`.
- **Code Climate README badges** — `docs/DEVELOPMENT.md` still mentions CodeClimate. Confirm the app is gone; remove the badges if it is.

## What “high design standards” means here

For this repo, the design bar is a quiet review path, not more tools.

1. A PR has one advisory review voice (CodeRabbit) and one required CI suite.
2. Semver-major and product changes still need a human. Bots do not auto-merge those.
3. Agent drafts that are not the landing PR get closed the same week they appear.
4. Docs that describe the review handshake match the workflows (`docs/PROJECT_STATE.md`, `docs/DEVELOPMENT.md`).
5. Visual / product redesign (Harbor, Hanami, staff tools) is a later phase. It should not start while three review bots still comment on dependency PRs.

## Execution plan

### Phase 0 — stop the bleeding

Done: closed #4387, #4399, #4424. Merged #4423 and #4421. No open
Dependabot PRs remain.

Rule going forward: if a review is needed, `@coderabbitai review` only.

### Phase 1 — make roles explicit in git

In this PR:

1. Deleted `.github/workflows/droid-review.yml`.
2. Left `.github/workflows/droid.yml` as on-demand `@droid` only.
3. Rewrote `docs/PROJECT_STATE.md` and the CI paragraph of
   `docs/DEVELOPMENT.md`. Removed dead Code Climate badges from `README.md`.
4. Still needs a maintainer: disable Copilot automatic code review in GitHub
   repo settings. That is not a file in git.
5. Added Copilot's `github.actor == 'dependabot[bot]'` guard to
   `dependabot-auto-merge.yml` here so `pull_request_target` on `main`
   skips rewritten Dependabot PRs instead of failing fetch-metadata.

### Phase 2 — settings that live outside git

A maintainer with admin on `EBWiki/EBWiki` should:

1. Confirm branch protection / rulesets: required checks are `CI` jobs + CodeQL only. Droid and Copilot review must not be required.
2. Uninstall or suspend unused GitHub Apps: Factory Droid (if both workflows go), Copilot reviewer if unused, Code Climate if the badges are dead.
3. Leave Dependabot, CodeQL, and CodeRabbit installed.

### Phase 3 — after the review path is quiet

Only then pick up product design work (Harbor spike #4425, Hanami drafts, staff tools). Those PRs should get the same single review path, not a new bot.

## Decision still needed

Keep on-demand `@droid`, or remove Factory from the repo entirely?

- **Keep `@droid`:** delete only `droid-review.yml`. One coding-agent mention remains.
- **Remove Factory:** delete both Droid workflows and the `FACTORY_API_KEY` secret.

Recommendation: remove Factory. Cursor is the coding agent for this stream, CodeRabbit is the reviewer, Copilot stays available in the editor if people want it, but it should not open or review PRs by default.

## Out of scope

- Rewriting CI into path-aware jobs (#4399). Useful later; not required to stop bot pile-up.
- Hanami / Harbor / maps / photos drafts.
- Semver-major gem migrations other than Puma 6 → 7 (landed in #4421).
  Puma 7 → 8 stays deferred.
