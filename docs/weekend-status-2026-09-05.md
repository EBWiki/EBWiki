# EBWiki Weekend Status Pack

**Date:** 2026-09-05 (~3:26pm ET)  
**Linear:** [GKT-168](https://linear.app/gkt/issue/GKT-168/factory-ebwiki-weekend-status-pack-hosting-update-path)  
**Repo:** [EBWiki/EBWiki](https://github.com/EBWiki/EBWiki)  
**Base commit:** `202092e7` (main, 2026-08-31)  
**Inventory source:** PR Manager read-only pass (2026-09-05) — ground truth for this doc.

Analysis-only snapshot. **No merges performed.**

---

## Executive snapshot

| Signal | State |
| --- | --- |
| **Framework** | Ruby 3.4.2, Rails 8.1.3.1 on `main` |
| **CI on `main`** | Workflows trigger on **pull requests only** (not push-to-main) |
| **Test suite** | 64 RSpec files (~2,573 lines); Elasticsearch 6.8.13 still required in CI |
| **Open PRs** | 13 total — see inventory below |
| **Production hosting (documented)** | Heroku (`docs/DEPLOYING.md`, `Procfile`, `.buildpacks`); no Render/Railway IaC on `main` |
| **Docs source of truth** | [#4409](https://github.com/EBWiki/EBWiki/pull/4409) — Hanami feasibility + Rails-first cut plan |
| **Live hosting slice** | [#4413](https://github.com/EBWiki/EBWiki/pull/4413) — Hanami app on Railway (`hanami-web-production-dd15`); PR Manager babysits |

---

## Two-track framing (do not conflate)

| Track | PR | Role | Next |
| --- | --- | --- | --- |
| **Docs / strategy** | **#4409** | Analysis only (+348 / 3 files). `docs/HANAMI_MIGRATION.md` is the **source of truth** for maintainer cuts and points at #4410–#4412. Last touch **Aug 20**. Behind `main`, draft, CI green. | Rebase and merge when PR Manager slot open — zero runtime risk |
| **Live slice / hosting experiment** | **#4413** | Hanami first slice (+7k lines). Railway staging **live** at `hanami-web-production-dd15`. CI green on `98deac5` (**Sep 3**). Behind `main`, draft. **Not docs.** | PR Manager babysits; no merge to `main` until product/architecture sign-off |

Everything else below is Rails modernization, hosting prep, or maintenance — sequenced per #4409.

---

## App health signals (from repo)

### Healthy

- Rails 8.1.3.1 line current; recent `main` merges are Dependabot runtime/security patches (#4415, #4414, #4408, #4405).
- PR CI matrix: RSpec, Brakeman, RuboCop, markdown link check, CodeQL.
- Docker publish path on `main` (`Dockerfile`, `publish_docker_image.yml` → `ebwiki/ebwiki:latest`).

### Gaps / drift

| Area | Detail |
| --- | --- |
| **Docs stale vs code** | `README.md` cites Ruby 3.2 / Rails 7; `docs/PROJECT_STATUS.md` last updated March 2026 |
| **CI blind spot** | No `push:` trigger on `ci.yml` — post-merge `main` not auto-revalidated |
| **Search stack** | `elasticsearch` + `searchkick` still in `Gemfile`; CI spins ES 6.8.13 |
| **Hosting docs** | Heroku-only deploy guide; `render.yaml` on unmerged 2024 branches |
| **Mega-PR overlap** | #4406 duplicates scope now split across #4410–#4412 |

---

## Open PR inventory (PR Manager ground truth)

### Rails modernization / hosting-related (all draft, all behind `main`)

| PR | Scope | CI last check | One-line next |
| --- | --- | --- | --- |
| [#4406](https://github.com/EBWiki/EBWiki/pull/4406) | Rails 8.1 modernization mega-PR (Playwright, importmap, ~161 files). Overlaps ES→pg_search, Mailboxer, CarrierWave work now in #4410–#4412. | **Red** + dirty conflicts | **Close** — re-scope any salvageable pieces as small PRs off `main`; do not merge as-is |
| [#4410](https://github.com/EBWiki/EBWiki/pull/4410) | `pg_search` / drop Elasticsearch | **Green** | **Rebase → ready for review → queue merge** — first Rails-first cut per #4409; highest hosting ROI |
| [#4411](https://github.com/EBWiki/EBWiki/pull/4411) | Remove Mailboxer | **RSpec red** | **Revise** — rebase after #4410 lands; fix failing specs |
| [#4412](https://github.com/EBWiki/EBWiki/pull/4412) | Replace Administrate with staff tools | **RSpec + RuboCop red** | **Revise** — rebase after #4411; fix CI |
| [#4407](https://github.com/EBWiki/EBWiki/pull/4407) | Wikimedia friendly photos search | **Red** + GHAS threads open | **Wait** — resolve security threads and CI before any review |

### Docs + live slice (see framing above)

| PR | One-line next |
| --- | --- |
| **#4409** (docs SoT) | Rebase onto `main`, merge when slot open — lands `HANAMI_MIGRATION.md` and cut sequence |
| **#4413** (live slice) | PR Manager continues Railway babysit; stakeholder decision before `main` merge |

### Lower priority

| PR | One-line next |
| --- | --- |
| [#4400](https://github.com/EBWiki/EBWiki/pull/4400) Dependabot security | Merge when routine slot available (CI green) |
| [#4398](https://github.com/EBWiki/EBWiki/pull/4398) Dependabot dev deps | Revise RuboCop or close per backlog policy |
| [#4354](https://github.com/EBWiki/EBWiki/pull/4354) rack 2.2.23 patch | Rebase (conflicts) or recreate |
| [#4399](https://github.com/EBWiki/EBWiki/pull/4399) Copilot CI refactor | Wait — maintainer review vs Droid/CodeRabbit |
| [#4387](https://github.com/EBWiki/EBWiki/pull/4387) Copilot exploration | Close — stale, no actionable diff |
| [#4326](https://github.com/EBWiki/EBWiki/pull/4326) Copilot RuboCop sub-PR | Close — conflicting, superseded |

### Rails-first merge order (from #4409 docs SoT)

1. **#4410** — drop ES / wire `pg_search`
2. **#4411** — remove Mailboxer
3. **#4412** — staff tools replace Administrate
4. **#4409** — land analysis doc (parallel-safe anytime)

**#4413** stays outside this queue until parallel-stack vs Rails-only path is decided.

---

## Branches that matter

| Branch | PR | Notes |
| --- | --- | --- |
| `cursor/hanami-migration-analysis-fe74` | #4409 | Docs SoT — `docs/HANAMI_MIGRATION.md` |
| `cursor/hanami-first-slice-fe74` | #4413 | Live Railway slice; head `98deac5` |
| `cursor/pg-search-drop-elasticsearch-fe74` | #4410 | ES removal |
| `cursor/remove-mailbox-fe74` | #4411 | Mailboxer removal |
| `cursor/staff-tools-replace-admin-fe74` | #4412 | Administrate replacement |
| `cursor/rails-8-modernization-060d` | #4406 | Conflicting mega-PR — close candidate |
| `render` / `render-staging` | — | 2024 `render.yaml`; not on `main` |

---

## Hosting readiness vs ~$1,500 first-year ops

External proposal: ~**$1,500/year** operating spend (not build labor). Proposal is outside repo; gaps are repo-observable only.

| Component | Today | After #4410 |
| --- | --- | --- |
| Web + PG + Redis | Required (Heroku today) | Same on Railway/Render/DO |
| Elasticsearch | Required — **budget killer** | Removed |
| S3 (CarrierWave) | AWS, separate billing | Unchanged |
| Railway Hanami demo (#4413) | Proves PaaS can host read-heavy slice | Not production Rails cutover |

**Gaps before host switch:** no IaC on `main`, Heroku-only deploy docs, ES still in CI until #4410 merges, 40+ env vars in unmerged `render.yaml` with no refreshed `.env.example` on `main`.

At ~$125/mo all-in, **Postgres + Redis + web + ES** exceeds most PaaS starter tiers. Dropping ES (#4410) is prerequisite for fitting the $1,500/year envelope.

---

## Monday claimable coding action

**Claim:** Rebase [#4410](https://github.com/EBWiki/EBWiki/pull/4410) (`cursor/pg-search-drop-elasticsearch-fe74`) onto current `main`, confirm CI green, mark ready for review.

**Owner kind:** CloudAgent (code) → PR Manager (merge queue) — **no merge by CloudAgent.**

**Why:** Only Rails modernization PR that is CI-green, behind but mergeable, and directly aligned with #4409 docs SoT. Drops Elasticsearch from app + CI — unblocks #4411/#4412 and makes Railway/Render/DO migration financially plausible.

**Acceptance criteria:**

- [ ] Rebased onto post-#4415 `main`; conflicts resolved
- [ ] CI green: RSpec, RuboCop, Brakeman
- [ ] `docs/DEPLOYING.md` changes drop ES reindex step
- [ ] Draft cleared only when PR Manager approves

**If blocked:** Rebase **#4409** (docs-only, +348 lines) — lands strategy doc on `main` with zero runtime risk.

**Not Monday factory work:** #4413 Railway babysit stays with PR Manager; no code changes unless staging breaks.

---

## Owners

| Role | Responsibility |
| --- | --- |
| **CloudAgent** | Monday #4410 rebase + CI |
| **PR Manager** | Merge queue; #4413 Railway babysit |
| **Mark** | Stakeholder send (Marshal drafts) |
| **Marshal** | GKT-168 exit tracking |

---

_Generated 2026-09-05 by Cursor Cloud Agent (GKT-168). PR Manager inventory is ground truth. No secrets, credentials, or client PII._
