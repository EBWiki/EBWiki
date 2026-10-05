# GKT-714 — EBWiki #4472 supersede map (forks #4467 / #4468 / #4470)

**Linear:** GKT-714 (this report). **Parent:** GKT-176 stays **OPEN**.  
**Idempotency:** `GKT-176:auto:4472-supersede-map`  
**Kind:** read-only-repo-report — no CODE PR on EBWiki, no merge, no PR comments, no messaging.

**Question:** Does [EBWiki #4472](https://github.com/EBWiki/EBWiki/pull/4472) (GKT-707, tip `ebd204b9`) fully absorb fork PRs [#4467](https://github.com/EBWiki/EBWiki/pull/4467), [#4468](https://github.com/EBWiki/EBWiki/pull/4468), and [#4470](https://github.com/EBWiki/EBWiki/pull/4470)?

**Stack context:** #4472 bases on #4466 tip `98e99865` (`cursor/hanami-candidate-search-source-policy-gate-c0e4`). Forks #4468 and #4470 share that base. #4467 bases on `cursor/hanami-cutover-bf84` at `1f989917` (pre–SourcePolicy-gate stack).

**Evidence fetched:** 2026-10-05 (UTC) via `git fetch` PR heads + `git diff` + `gh api` check-runs + GitHub MCP `pull_request_read` (second source).

---

## Executive summary (Mark / GO)

| Fork PR | Verdict | Confidence |
|---------|---------|------------|
| **#4467** (client extract, GKT-691) | **Close as superseded by #4472** | High — client modules byte-identical at tips; orchestration absorbed with intentional upgrades |
| **#4468** (homonym stack, GKT-693) | **Close as superseded by #4472** | High — prod + unit specs match; one request-spec assertion not carried forward (optional follow-up on #4472) |
| **#4470** (mugshot stack, GKT-694) | **Close as superseded by #4472** | High — `MugshotClassifier` + wiring identical at tips |

**Integrated stack to ship:** #4466 → #4472 (not the three forks). #4472 is a single commit (`ebd204b9`) that replays fork intent on the SourcePolicy gate base.

---

## Method

1. `git fetch origin pull/{4466,4467,4468,4470,4472}/head`
2. Per fork: `git diff <fork-base>..<fork-head>` (hunk inventory)
3. Compare fork tip file trees to `pr-4472` tip (`git diff`, `diff -u`)
4. Classify each hunk: **COVERED** (same or strict superset in #4472), **DIVERGED** (intentional semantic change in #4472), **MISSING** (fork behavior absent in #4472)

---

## Live PR state (second-source: `gh api` + GitHub MCP)

| PR | Role | Draft | mergeable_state | Tip SHA | Base (ref @ SHA) | CI (required jobs) |
|----|------|-------|-----------------|---------|------------------|---------------------|
| [#4466](https://github.com/EBWiki/EBWiki/pull/4466) | SourcePolicy gate (parent of #4472) | yes | `clean` | `98e99865` | `cursor/hanami-source-policy-attach-parity-9998` | rspec, rubocop, brakeman, dawnscanner, markdown-link-checker — **success** |
| [#4467](https://github.com/EBWiki/EBWiki/pull/4467) | Client extract fork | yes | `clean` | `06d82902` | `cursor/hanami-cutover-bf84` @ `1f989917` | rspec, rubocop, brakeman, dawnscanner, markdown-link-checker — **success** |
| [#4468](https://github.com/EBWiki/EBWiki/pull/4468) | Homonym fork | yes | `clean` | `83fd0c64` | #4466 branch @ `98e99865` | same — **success** |
| [#4470](https://github.com/EBWiki/EBWiki/pull/4470) | Mugshot fork | yes | `clean` | `ea3e639a` | #4466 branch @ `98e99865` | same — **success** |
| [#4472](https://github.com/EBWiki/EBWiki/pull/4472) | **Integrated stack (GKT-707)** | yes | `clean` | `ebd204b9` | #4466 branch @ `98e99865` | same — **success** |

All four target PRs are **draft**, **mergeable**, **`mergeable_state: clean`**, with green **rspec** / **rubocop** / **brakeman** on tips (bots skipped).

---

## Intentional divergences (#4472 vs forks)

These are **expected** consolidation choices, not gaps:

| Topic | Fork behavior | #4472 behavior | Classification |
|-------|---------------|----------------|----------------|
| SourcePolicy filter | #4467 still on cutover base (pre–#4466); #4470 inherits #4466 `allowed_hit?` | `.select { SourcePolicy.allowed_hit?(hit) }` on #4466 base | **DIVERGED** vs #4467 base only; **COVERED** vs #4466/#4468/#4470 intent |
| Mugshot detection | #4467: inline `MUGSHOT_TEXT` / `mugshot?` | `MugshotClassifier.call(...)` (#4470 parity + #4472) | **DIVERGED** (upgrade) — fork #4470 absorbed |
| `CandidateSearch#initialize` | #4467/#4470: `name`, `city`, clients | Adds **`case_year:`** for homonym detector | **DIVERGED** (strict superset for #4468) |
| HTTP client extract | #4467 only | Same three files at identical content | **COVERED** |
| Request spec homonym | #4468 adds `expect(body).to include("Possible historical homonym")` | UI template **still renders** homonym warning; assertion **removed** from request spec | **MISSING** test-only (see #4468 verdict) |

---

## Coverage matrix — #4467 (base `1f989917` → `06d82902`)

5 files, 13 hunks.

| File | Hunks | Status in #4472 tip | Notes |
|------|-------|---------------------|-------|
| `apps/hanami/lib/eb_wiki/friendly_photos/openverse_search_client.rb` | 1 (new file) | **COVERED** | Byte-identical to #4472 tip |
| `apps/hanami/lib/eb_wiki/friendly_photos/remote_get.rb` | 1 (new file) | **COVERED** | Byte-identical |
| `apps/hanami/lib/eb_wiki/friendly_photos/wikimedia_search_client.rb` | 1 (new file) | **COVERED** | Byte-identical |
| `apps/hanami/lib/eb_wiki/friendly_photos/candidate_search.rb` | 9 | **COVERED** (7) + **DIVERGED** (2) | Extract/delegate hunks **COVERED**. **`MUGSHOT_TEXT` / `mugshot?` retained in #4467** → **DIVERGED**: #4472 uses `MugshotClassifier` (#4470). **`initialize`**: #4472 adds `case_year` (**DIVERGED** superset). On #4466 base, #4472 uses `allowed_hit?` not cutover-era policy (**DIVERGED** vs #4467 base, aligned with #4466). |
| `apps/hanami/spec/lib/eb_wiki/friendly_photos/candidate_search_spec.rb` | 1 (new file) | **COVERED** (superset) | #4472 file is a strict **superset**: includes blank-name, mugshot annotation, client delegation from #4467, plus SourcePolicy + homonym examples from #4466/#4468 stack |

**#4467 recommendation:** **Close as superseded by #4472.** No unique production code remains on the fork tip.

---

## Coverage matrix — #4468 (base `98e99865` → `83fd0c64`)

8 files, 16 hunks.

| File | Hunks | Status in #4472 tip | Notes |
|------|-------|---------------------|-------|
| `apps/hanami/app/templates/friendly_photos/show.html.erb` | 2 | **COVERED** | Byte-identical (homonym + mugshot warnings, `photo-card-warn`) |
| `apps/hanami/app/views/friendly_photos/show.rb` | 1 | **COVERED** | Byte-identical (`case_year` → `CandidateSearch`) |
| `apps/hanami/lib/eb_wiki/friendly_photos/homonym_detector.rb` | 1 (new) | **COVERED** | Byte-identical |
| `apps/hanami/spec/lib/eb_wiki/friendly_photos/homonym_detector_spec.rb` | 1 (new) | **COVERED** | Byte-identical |
| `apps/hanami/lib/eb_wiki/friendly_photos/hit.rb` | 1 | **COVERED** | Byte-identical (`likely_homonym` attribute) |
| `apps/hanami/lib/eb_wiki/friendly_photos/candidate_search.rb` | 6 | **COVERED** | Homonym require, stub homonym hit, `annotate` homonym path present in #4472. #4472 also adds client extract + mugshot classifier (**superset**). |
| `apps/hanami/spec/lib/eb_wiki/friendly_photos/candidate_search_spec.rb` | 3 | **COVERED** | #4472 includes homonym + allow-gate examples from #4468; adds mugshot annotation + live-client delegation |
| `apps/hanami/spec/requests/friendly_photos_spec.rb` | 1 | **MISSING** (test only) | #4468 **adds** homonym body assertion; #4472 **drops** it while template still shows homonym copy |

**#4468 recommendation:** **Close as superseded by #4472.** Optional **needs follow-up CODE** (name only, on **#4472**, not a fork): restore request spec line `expect(last_response.body).to include("Possible historical homonym")` if Mark wants parity with #4468’s E2E assertion — **not blocking** supersede (UI + lib specs already cover homonym).

---

## Coverage matrix — #4470 (base `98e99865` → `ea3e639a`)

3 files, 6 hunks.

| File | Hunks | Status in #4472 tip | Notes |
|------|-------|---------------------|-------|
| `apps/hanami/lib/eb_wiki/friendly_photos/mugshot_classifier.rb` | 1 (new) | **COVERED** | Byte-identical |
| `apps/hanami/spec/lib/eb_wiki/friendly_photos/mugshot_classifier_spec.rb` | 1 (new) | **COVERED** | Byte-identical |
| `apps/hanami/lib/eb_wiki/friendly_photos/candidate_search.rb` | 4 | **COVERED** | `MugshotClassifier` require, `annotate` wiring, removal of `MUGSHOT_TEXT` / `mugshot?` — matches #4472. #4472 keeps **`allowed_hit?`** gate from #4466 (same as #4470 on this base). |

**#4470 recommendation:** **Close as superseded by #4472.** No unique hunks.

---

## Commit / ancestry check

| Comparison | Result |
|------------|--------|
| `pr-4468..pr-4472` | #4472 adds integrated commit only; fork commits not ancestors of #4472 (parallel replay) |
| `pr-4470..pr-4472` | Same |
| `pr-4467` vs `pr-4472` | Different base branch; merge-base `1f989917`; #4472 built on #4466 gate, not cutover-only #4467 base |

Semantic absorption does **not** require git ancestry; file-tip and hunk analysis above is the proof bar.

---

## What #4472 adds beyond the three forks (expected)

Single landing PR includes **all** of:

- Client extract (#4467)
- Homonym detector + UI (#4468)
- Mugshot classifier (#4470)
- SourcePolicy **`allowed_hit?`** gate + expanded `candidate_search_spec` (#4466 lineage)
- One integrated spec file and unified `CandidateSearch` orchestration

---

## Per-fork verdicts (action for Mark — report only; agent did not close/comment)

| Fork | Recommendation |
|------|----------------|
| **#4467** | **Close as superseded by #4472** |
| **#4468** | **Close as superseded by #4472** (optional tiny test follow-up on #4472: homonym request assertion) |
| **#4470** | **Close as superseded by #4472** |

**Keep open:** #4466 (gate), #4472 (integrated stack). **Do not merge** any PR from this report.

---

## Linear RESULT (paste)

**GKT-714:** File/hunk analysis shows #4472 tip `ebd204b9` **fully absorbs** production and spec intent of #4467, #4468, and #4470. Client modules and classifier/detector files are **identical** where fork-only; `CandidateSearch` is a **superset** with intentional upgrades (`allowed_hit?`, `MugshotClassifier`, `case_year`, homonym stub hit). **One test-only gap:** #4468’s request spec homonym assertion not in #4472 (UI unchanged). **Verdict:** Mark can **close forks #4467/#4468/#4470 as superseded by #4472** with high confidence; optional homonym request spec on #4472 only. Live CI green on all four tips. **GKT-176 remains OPEN.**

---

## Commands (reproduce)

```bash
git fetch origin \
  pull/4466/head:pr-4466 pull/4467/head:pr-4467 pull/4468/head:pr-4468 \
  pull/4470/head:pr-4470 pull/4472/head:pr-4472

git diff --stat 98e99865..pr-4472
git diff --stat 98e99865..pr-4468
git diff --stat 98e99865..pr-4470
git diff --stat 1f989917..pr-4467

for p in 4467 4468 4470 4472; do
  gh api "repos/ebwiki/ebwiki/commits/$(git rev-parse pr-$p)/check-runs?per_page=20" \
    --jq '.check_runs[] | select(.name|test("rspec|rubocop|brakeman")) | {name,conclusion}'
done
```
