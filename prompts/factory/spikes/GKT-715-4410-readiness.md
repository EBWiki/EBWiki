# GKT-715 — EBWiki #4410 second-source readiness (pg_search / drop Elasticsearch)

| Field | Value |
| --- | --- |
| **Linear** | [GKT-715](https://linear.app/grandkru/issue/GKT-715) (child); parent [GKT-355](https://linear.app/grandkru/issue/GKT-355) stays **OPEN** |
| **Idempotency** | `GKT-355:auto:4410-readiness` |
| **Kind** | `[auto]` read-only-repo-report — no CODE PR, no merge, no PR comments, no messaging |
| **Mirror** | GKT-711 / [#4449](https://github.com/EBWiki/EBWiki/pull/4449) (Harbor 0) |
| **PR** | [#4410](https://github.com/EBWiki/EBWiki/pull/4410) — *Search cases with pg_search and remove Elasticsearch* |
| **Fetched (UTC)** | 2026-10-05T19:23:07Z |
| **Second-source** | Live `gh api` + local read-only checkout of tip `b76460b` |

---

## Verdict (technical readiness only — not merge GO)

**Technically ready:** **YES** (prefer **GO**, not locked).

| Signal | Status |
| --- | --- |
| Tip CI (required checks on `b76460b`) | All reported checks **success** (or **skipped** where expected) |
| `mergeable` / GitHub merge graph | **MERGEABLE** |
| vs `main` | **0 behind**, **3 ahead** — rebased to current `main` |
| Scope | Search-stack swap only — **no Harbor, no Hanami** |
| vs #4449 (Harbor 0) | **Zero file overlap**; `git merge-tree` **clean merge** |
| vs #4425 (Harbor spike) | **Full 18-file overlap**; merge-tree shows **content conflicts** — do not co-land |
| Local RSpec subset | **Not run** (missing `config/database.yml` in agent env); **CI `rspec` success** on tip |

**Not granted here:** merge GO (Mark only), CODEOWNERS Approve, undrafting, or landing order commitment beyond technical sequencing notes below.

---

## 1. Live PR table (#4410)

| Field | Value |
| --- | --- |
| **draft** | `true` |
| **locked** | `false` |
| **base ref / SHA** | `main` @ `302c9a1db219f30c7b498e14323f112ac03b314e` |
| **head ref / SHA** | `cursor/pg-search-drop-elasticsearch-fe74` @ `b76460bbc8e0d798ad7f9bc2e67ed42d7480c0d9` |
| **ahead / behind `main`** | **3 / 0** (`compare/main...b76460b`, status `ahead`) |
| **mergeable** | `true` |
| **mergeable_state** | `blocked` (branch protection / reviews — not dirty) |
| **reviewDecision** | `REVIEW_REQUIRED` |
| **changed_files** | 18 (+175 / −109 per PR metadata) |
| **commits on PR** | 3 |

**Commits (tip → base):**

1. `68f7762` — Use pg_search for cases and drop Elasticsearch  
2. `fc0ce2e` — Fix CaseSearch date ordering and add pg_search parity specs  
3. `b76460b` — Add Case.find_by_search delegation specs to case_spec  

**Reviews:** COMMENTED only (factory-droid, github-advanced-security bots) — no APPROVE / CHANGES_REQUESTED from humans on record.

---

## 2. CI table (check runs on tip `b76460bbc8e0d798ad7f9bc2e67ed42d7480c0d9`)

| Check | Status | Conclusion |
| --- | --- | --- |
| rspec | completed | **success** |
| rubocop | completed | **success** |
| brakeman | completed | **success** |
| markdown-link-checker | completed | **success** |
| CodeQL | completed | **success** |
| Analyze (ruby) | completed | **success** |
| Analyze (actions) | completed | **success** |
| Analyze (javascript-typescript) | completed | **success** |
| Analyze (python) | completed | **success** |
| dependabot | completed | **skipped** |

Source: `GET /repos/EBWiki/EBWiki/commits/b76460b/check-runs` (paginated), 2026-10-05T19:23:07Z.

---

## 3. Diff summary and scope check

### Totals (vs `main`)

| Metric | Value |
| --- | --- |
| Files | 18 |
| Additions | 175 |
| Deletions | 109 |
| Commits | 3 |

### Areas touched

| Area | Files | Notes |
| --- | ---: | --- |
| **App / search** | 2 | `app/search/case_search.rb`, `app/models/case.rb` |
| **Deps** | 2 | `Gemfile`, `Gemfile.lock` — removes searchkick / elasticsearch |
| **CI / infra** | 4 | `.github/workflows/ci.yml`, `Makefile`, dev_provisions (3) |
| **Config** | 2 | `.env.example`, delete `config/initializers/searchbox.rb` |
| **Docs** | 4 | `README.md`, `docs/DEPLOYING.md`, `docs/DEVELOPMENT.md`, `docs/SETUP_LOCALLY_FULLSTACK.md` |
| **Specs** | 3 | `spec/search/case_search_spec.rb` (new), `spec/models/case_spec.rb`, `spec/rails_helper.rb` |

### Scope gate: search swap only?

| Forbidden scope | Present? |
| --- | --- |
| Harbor (`harbor/`, Harbor workflows, SPIKE_HARBOR) | **No** |
| Hanami | **No** |
| Unrelated archive / mailbox / staff-tools | **No** (per PR body and diff) |

**Conclusion:** Diff matches stated intent — route `CaseSearch` through existing `pg_search` / `search_text`, remove Elasticsearch/Searchkick and provisioning, add parity specs.

---

## 4. Ordering vs #4449 (Harbor 0) and #4425

### #4449 snapshot (same fetch window)

| Field | #4449 |
| --- | --- |
| Title | Harbor 0: in-tree Harbor tasks and layout-only CI (no search stack) |
| draft | `true` |
| head SHA | `6093fca7d405f13719f6628abf88a364a05619a8` |
| vs `main` | **1 ahead / 0 behind**, 31 files |
| mergeable | `true` |
| mergeable_state | `blocked` |
| reviewDecision | `REVIEW_REQUIRED` |
| CI on tip | rspec, rubocop, brakeman, Harbor layout check, CodeQL, Analyzes — **success** |

### File overlap

| Pair | Overlapping paths |
| --- | --- |
| **#4410 ∩ #4449** | **None** (disjoint path sets) |
| **#4410 ∩ #4425** | **All 18** #4410 paths (Harbor eval spike touches same search/Gemfile/CI surface) |

### Merge simulation (local read-only)

| Integration | Result |
| --- | --- |
| **#4449 tip + #4410 tip** (`git merge-tree` on merge-base) | **Clean** — no conflict markers |
| **#4410 tip + #4425 tip** | **Conflicts** (`<<<<<<<` in merge-tree output) |

### Suggested landing order (technical, not merge authorization)

1. **[#4449](https://github.com/EBWiki/EBWiki/pull/4449) (Harbor 0)** first — adds Harbor tree + `harbor.yml`; independent of search stack per title/body.  
2. **[#4410](https://github.com/EBWiki/EBWiki/pull/4410)** second — rebase onto post-4449 `main` expected **low friction** (no shared files; clean merge-tree today).  
3. **[#4425](https://github.com/EBWiki/EBWiki/pull/4425)** — **not** in the same lane as #4410; `mergeable: false`, `mergeable_state: dirty`, full file collision with #4410. Treat as spike / alternate stack, not a prerequisite for #4410.

Aligns with GKT-700 path (#4449 + #4410) and GKT-711 mirror for Harbor readiness.

---

## 5. Local verification notes

```bash
git fetch origin pull/4410/head:pr-4410-tip
git checkout b76460bbc8e0d798ad7f9bc2e67ed42d7480c0d9
bundle exec rspec spec/search/case_search_spec.rb spec/models/case_spec.rb
```

**Outcome:** RSpec did not execute examples — `Could not load database configuration … config/database.yml`. **CI rspec on tip is the authoritative green signal** for this report.

---

## 6. Suggested Mark GO line (Mark grants only)

> **Mark GO:** [#4410](https://github.com/EBWiki/EBWiki/pull/4410) — pg_search case search, remove Elasticsearch — tip `b76460b`, CI green, 0 behind `main`, unlocked draft — **land after [#4449](https://github.com/EBWiki/EBWiki/pull/4449)** (no path overlap; merge-tree clean) — **do not pair with [#4425](https://github.com/EBWiki/EBWiki/pull/4425)** (conflicting spike).

---

## 7. Linear RESULT (paste / attach)

**GKT-715:** Second-source readiness for #4410 — **technically ready (GO preferred, not locked)**. Tip `b76460b`: mergeable, 3↑/0↓ vs `main`, all CI success on tip. Scope: search swap only. Order: #4449 then #4410; avoid #4425 collision. Parent **GKT-355** remains open.

**Ticket Done ≠ parent Done.**

---

## API audit trail

```text
gh api repos/EBWiki/EBWiki/pulls/4410
gh api repos/EBWiki/EBWiki/compare/main...b76460bbc8e0d798ad7f9bc2e67ed42d7480c0d9
gh api repos/EBWiki/EBWiki/commits/b76460bbc8e0d798ad7f9bc2e67ed42d7480c0d9/check-runs --paginate
gh api graphql (reviewDecision, mergeStateStatus for #4410, #4449)
```
