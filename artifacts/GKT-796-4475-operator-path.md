# GKT-796 — Operator path: EBWiki PR #4475 @ `28ce1fc3`

**Mode:** read-only assessment (no repo PR opened or updated by this run)  
**Assessed:** 2026-10-05 (UTC)  
**Idempotency:** `GKT-175:auto:4475-operator-path-28ce1fc3-20261005-b`

## Verdict

**WAIT**

CI and landing-PR shape are ready; merge is blocked by **draft status**, **required CODEOWNERS review**, and a **duplicate open PR** with the same diff. Resolve those before treating this as **GO**.

---

## Named change (one sentence)

Re-land the `spec/requests/versions_spec.rb` PaperTrail routing flake fix from Harbor spike #4425 commit `8609c999` as a single-file change on `main`.

---

## GitHub snapshot — PR #4475

| Field | Value |
|--------|--------|
| URL | https://github.com/EBWiki/EBWiki/pull/4475 |
| Title | Fix versions revert request spec PaperTrail routing flake (GKT-722) |
| State | Open, **draft** |
| Base → head | `main` ← `cursor/versions-spec-papertrail-flake-b537` |
| Tip (head) | `28ce1fc3ee703463fd0ef7e5fb0a5f3ce1fac6d4` (`28ce1fc3`) |
| Diff size | 1 file, +17 / −17 (`spec/requests/versions_spec.rb` only) |
| Mergeable | Yes (`MERGEABLE`, `mergeStateStatus`: **BLOCKED**) |
| Review | `REVIEW_REQUIRED`; no submitted reviews |
| Author | `mnyon-grandkru` (commit also lists `cursoragent`; co-authored-by Mark in message) |

### Tip commit message (summary)

- Isolates revert examples via `post_revert`; fails fast if PaperTrail did not record a version.
- Stated intent: closes **GKT-722**; residual from **#4425** (`8609c999`).
- PR body idempotency (agent): `GKT-355:auto:versions-spec-papertrail-flake` (distinct from this operator-path idempotency key).

---

## Landing-PR bar

| Check | Result |
|--------|--------|
| One named change | Pass — request-spec flake fix only |
| Smallest unlock | Pass — no extra files |
| Reviewability | Pass — single file, small diff |
| Mixed concerns | Pass — no views, CI hygiene, or unrelated docs |

---

## CI / quality gates (tip `28ce1fc3`)

All required checks on the PR head were **green** at assessment time:

| Check | Result |
|--------|--------|
| rspec | pass |
| rubocop | pass |
| brakeman | pass |
| markdown-link-checker | pass |
| CodeQL (actions, js/ts, python, ruby) | pass |
| dependabot auto-merge | skipped (expected) |
| CodeRabbit | skipped (auto review disabled on repo) |

No failing CI on this tip. **Draft + review policy** drive `BLOCKED`, not test failure.

---

## Duplication — must resolve before GO

**PR #4452** ([Fix versions revert request spec routing flake (GKT-667)](https://github.com/EBWiki/EBWiki/pull/4452)) is also **open**, **draft**, and **`git diff` against `main` is byte-identical** to #4475 for `spec/requests/versions_spec.rb`.

| PR | Linear (from body/title) | Head tip | Notes |
|----|---------------------------|----------|--------|
| #4452 | GKT-667 (parent inventory GKT-664) | `5d07759` | Opened earlier same day |
| #4475 | GKT-722 | `28ce1fc3` | This operator path; re-land from #4425 |

**Operator rule:** Keep **one** landing PR for this blob (`256edec0` on `main` index). For GKT-796 scope, **canonical candidate is #4475 / GKT-722**; close **#4452** as duplicate *after* confirming Linear ownership (GKT-667 ↔ GKT-722) with whoever owns the epic queue — **without pinging Mark** (see non-actions).

Do **not** merge both; the second merge would conflict or be empty.

---

## Relationship to spike #4425 and parent GKT-175

- **#4425** ([Spike: Harbor evaluation harness](https://github.com/EBWiki/EBWiki/pull/4425)) remains **open**, **draft**, **58 files** — includes the same `versions_spec.rb` hunk at tip `8609c999`. It is **not** a landing PR for this fix alone.
- **GKT-175** (parent): leave **open**; merging #4475 closes **GKT-722** per PR text, not the epic.
- PR #4475 body references **GKT-355** as parent epic for the flake idempotency line; do not infer GKT-175 closure from this merge.

---

## WAIT — why not GO now

1. **Draft** — GitHub will not complete a normal merge workflow until the PR is marked ready for review (project policy).
2. **CODEOWNERS** — `*` → `@gktreviewer`; human **Approve** required ([`.github/CODEOWNERS`](../.github/CODEOWNERS)). No approval on record.
3. **Duplicate #4452** — two draft PRs for the same single-file fix increases review noise and merge risk.

---

## GO path (after WAIT clears)

Execute in order when operating #4475:

1. **Dedup:** Close **#4452** (or abandon its branch) once GKT-667 / GKT-722 ownership is aligned on **#4475** as the landing PR.
2. **Ready:** Mark **#4475** ready for review (clear draft).
3. **Review queue:** Rely on GitHub review request / CODEOWNERS (`@gktreviewer`) — **do not** Slack/email ping Mark (`mnyon-grandkru`) for this step.
4. **Merge:** After **Approve** from CODEOWNERS, merge to `main` (squash or project default).
5. **Linear:** Let **GKT-722** close from PR merge linkage; confirm **GKT-175** remains open; mark **GKT-796** done when this operator path is executed.
6. **Do not** open a new EBWiki PR for the same `versions_spec.rb` blob; tip `28ce1fc3` is already the proposed landing commit.

### Optional local spot-check (not required if CI trusted)

```bash
git fetch origin cursor/versions-spec-papertrail-flake-b537
git checkout 28ce1fc3
bundle exec rspec spec/requests/versions_spec.rb
bundle exec rubocop spec/requests/versions_spec.rb
```

---

## Explicit non-actions (this run and operator queue)

- **Do not** create or push any **pull request** on EBWiki/EBWiki for this fix (work lives on #4475).
- **Do not ping Mark** for review nudges; use GitHub CODEOWNERS / review assignment only.
- **Do not** close **GKT-175** when #4475 merges.
- **Do not** merge **#4425** as a substitute for this single-concern land.

---

## Linear (GKT-796)

Linear MCP was **not authenticated** in this cloud environment; issue **GKT-796** text was not fetched. This document is grounded in public GitHub state for **#4475** @ **`28ce1fc3`** and repo policy files on `main`.

---

## Evidence log

- `gh pr view 4475 --json …` — draft, blocked, tip `28ce1fc3`, CI rollup.
- `gh pr diff 4475` vs `gh pr diff 4452` — identical.
- `gh pr checks 4475` — all pass (2026-10-05 UTC).
- Parent #4425 — open draft, 58 files, includes same spec hunk at `8609c999`.
