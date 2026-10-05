# GKT-742 — Review-gate checklist spike for PR #4475

| Field | Value |
| --- | --- |
| Linear | [GKT-742](https://linear.app/gkt/issue/GKT-742) |
| Parent epic | [GKT-355](https://linear.app/gkt/issue/GKT-355) (stays **open**; PR does not close it) |
| Pull request | [#4475](https://github.com/EBWiki/EBWiki/pull/4475) — Fix versions revert request spec PaperTrail routing flake (GKT-722) |
| Branch | `cursor/versions-spec-papertrail-flake-b537` |
| Scope | `spec/requests/versions_spec.rb` only (+17 / −17) |
| Idempotency (this spike) | `GKT-355:auto:4475-review-gate-checklist` |
| Idempotency (PR) | `GKT-355:auto:versions-spec-papertrail-flake` |
| Mode | **Audit-only** — no undraft, Approve, or merge performed in this run |
| Audit timestamp (UTC) | 2026-10-05T19:41:13Z |

## Goal

Written spike for moving [#4475](https://github.com/EBWiki/EBWiki/pull/4475) through the human review gate:

**undraft → `@gktreviewer` Approve → mark merge GO → merge** (merge itself is out of scope for this audit).

---

## Section A — Assumptions

1. **Expected tip.** Head SHA is `28ce1fc3ee703463fd0ef7e5fb0a5f3ce1fac6d4` (short `28ce1fc3`), matching the GKT-742 / GKT-729 expectation unless a newer push lands after this audit.
2. **CI baseline.** GKT-729 reported CI green at that tip; this spike **re-verifies** live GitHub check runs at audit time (not cached agent claims).
3. **Landing PR bar.** One named change: isolate `versions_spec` PaperTrail revert routing flake (re-land from #4425 `8609c999`). Single file, reviewable in one pass (`.cursor/rules/landing-pr.mdc`).
4. **Review path.** Required merge Approve is a **human** `@gktreviewer` per `.github/CODEOWNERS` and `AGENTS.md`. No agent self-Approve.
5. **Epic hygiene.** PR closes GKT-722 only; parent GKT-355 remains open (stated in PR body).
6. **Blocked vs locked.** `mergeable_state: blocked` with `mergeStateStatus: BLOCKED` is expected while **draft** and **review required**; `locked: false` on the PR.
7. **Local verify.** Cloud workspace lacks `config/database.yml`; local `rspec` for this file was not used as gate evidence. **GitHub CI `rspec` job** is the authoritative verify for this spike.
8. **Out of scope.** Undraft, Approve, merge, and Linear status updates are human/automation follow-ups, not performed here.

---

## Section B — Review-gate checklist (pass / fail)

| # | Gate | Criterion | Result | Evidence |
| --- | --- | --- | --- | --- |
| B1 | Named change | Single concern: `versions_spec` PaperTrail revert routing flake | **PASS** | 1 file changed; PR title/body; diff isolates `post_revert` + per-example contexts |
| B2 | Reviewability | Diff holdable in one pass; no mixed hygiene/views/lib | **PASS** | +17/−17; `changed_files: 1` |
| B3 | Base freshness | Branch based on current `main` | **PASS** | `origin/main` `302c9a1d` is ancestor of head; merge-base check OK at audit |
| B4 | Live tip | Head matches expected `28ce1fc3` | **PASS** | `headRefOid` / `head.sha` = `28ce1fc3ee703463fd0ef7e5fb0a5f3ce1fac6d4` |
| B5 | CI — rspec | Required job success at tip | **PASS** | Check run `rspec`: success (CI workflow, completed 2026-10-05T19:30:10Z) |
| B6 | CI — rubocop | Required job success at tip | **PASS** | Check run `rubocop`: success |
| B7 | CI — brakeman | Required job success at tip | **PASS** | Check run `brakeman`: success |
| B8 | CI — other required | markdown-link-checker, CodeQL ruby/actions/js/py | **PASS** | All `success`; `dependabot` auto-merge **skipped** (expected for non-dependabot PR) |
| B9 | Combined status | No failing required checks | **PASS** | `statusCheckRollup`: no `FAILURE`; legacy status `CodeRabbit`: success (review skipped) |
| B10 | Merge conflict | GitHub mergeable | **PASS** | `mergeable: MERGEABLE` |
| B11 | PR locked | Conversation not locked | **PASS** | `locked: false` |
| B12 | Draft cleared | Ready for review (not draft) | **FAIL** (expected pre-gate) | `isDraft: true` / `draft: true` — **undraft required** before Approve/merge |
| B13 | Human Approve | `@gktreviewer` Approve | **FAIL** (expected pre-gate) | `reviewDecision: REVIEW_REQUIRED`; zero PR reviews |
| B14 | Merge GO (process) | Blockers only draft + review | **PASS** (conditional) | `mergeStateStatus: BLOCKED` explained by B12+B13, not by CI or conflicts |
| B15 | Tracking | Closes GKT-722; leaves GKT-355 open | **PASS** | PR body + commit message |
| B16 | Agent policy | No stacked bot review requests | **PASS** | CodeRabbit skipped/disabled; no Copilot/CodeRabbit review requested in spike |

### Section B RESULT

```
GKT-742 / #4475 review-gate audit @ 2026-10-05T19:41:13Z
Tip:     28ce1fc3ee703463fd0ef7e5fb0a5f3ce1fac6d4 (matches expected 28ce1fc3)
CI:      PASS — rspec, rubocop, brakeman, markdown-link-checker, CodeQL (all success at tip)
Locked:  NO  (locked=false)
Merge:   MERGEABLE; blocked only by draft + missing Approve
Checklist: 14/16 PASS; 2/16 FAIL (B12 draft, B13 review) — both expected pre-gate actions
Recommendation: GO — proceed undraft → @gktreviewer Approve → merge GO (not locked)
Parent GKT-355: remain open after merge
Idempotency: GKT-355:auto:4475-review-gate-checklist
```

---

## Live tip / CI re-verify (fresh)

Re-fetched via GitHub API / `gh` at audit time:

- **Head:** `28ce1fc3ee703463fd0ef7e5fb0a5f3ce1fac6d4`
- **Base (`main`):** `302c9a1db219f30c7b498e14323f112ac03b314e`
- **Draft:** `true`
- **Review decision:** `REVIEW_REQUIRED`
- **Mergeable:** `MERGEABLE`
- **Merge state:** `BLOCKED`
- **Locked:** `false`

Check runs on head (conclusion):

| Check | Conclusion |
| --- | --- |
| rspec | success |
| rubocop | success |
| brakeman | success |
| markdown-link-checker | success |
| Analyze (ruby) | success |
| Analyze (actions) | success |
| Analyze (javascript-typescript) | success |
| Analyze (python) | success |
| CodeQL | success |
| dependabot (auto-merge workflow) | skipped |

---

## Recommendation

**GO** — Treat [#4475](https://github.com/EBWiki/EBWiki/pull/4475) as **ready to enter the human review gate**, not as merge-blocked by CI, conflicts, or lock state.

Suggested sequence (human/automation, not done in this audit):

1. **Mark ready for review** (clear draft).
2. **`@gktreviewer` Approve** (CODEOWNERS).
3. **Mark merge GO** and merge to `main`.
4. Confirm **GKT-722** closed and **GKT-355** still open.

**Not locked:** PR is unlocked; do not treat `BLOCKED` merge state as a hard stop — it clears after undraft + Approve.

---

## Diff summary (audit note)

Root cause addressed: shared parent `before` posted `/cases/:id/versions/#{nil}/revert` when PaperTrail had no row, routing as `/versions/revert` and flaking order-dependent examples. Fix: `post_revert` helper, isolated contexts, fail-fast when update produces no version.

---

## Local spot-check (non-gating)

On fetched tip `28ce1fc3`:

- `bundle exec rubocop spec/requests/versions_spec.rb` — no offenses.
- `bundle exec rspec spec/requests/versions_spec.rb` — **not run successfully locally** (missing `config/database.yml` in cloud agent VM). CI rspec remains gate evidence.
