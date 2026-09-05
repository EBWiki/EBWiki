# EBWiki Weekend Status Pack

**Date:** 2026-09-05  
**Linear:** [GKT-168](https://linear.app/gkt/issue/GKT-168/factory-ebwiki-weekend-status-pack-hosting-update-path)  
**Repo:** [EBWiki/EBWiki](https://github.com/EBWiki/EBWiki)  
**Base commit:** `202092e7` (main, 2026-08-31)

Analysis-only snapshot. No merges performed as part of this pack.

---

## Executive snapshot

| Signal | State |
| --- | --- |
| **Framework** | Ruby 3.4.2, Rails 8.1.3.1 on `main` |
| **CI on `main`** | Workflows trigger on **pull requests only** (not push-to-main); recent merges are Dependabot patch PRs with green CI at merge time |
| **Test suite** | 64 RSpec files (~2,573 lines); Elasticsearch 6.8.13 service still required in CI |
| **Open PRs** | 13 total (7 CloudAgent modernization/Hanami drafts, 3 Dependabot, 3 stale Copilot/exploration) |
| **Production hosting (documented)** | Heroku (`docs/DEPLOYING.md`, `Procfile`, `.buildpacks`) — no Render/Railway IaC on `main` |
| **Parallel experiment** | Hanami first slice (#4413) deployed to Railway with restored staging data; CI green |

---

## App health signals (from repo)

### What looks healthy

- **Rails 8.1 line is current.** Recent `main` history is Dependabot runtime/security patches (#4415, #4414, #4408, #4405, etc.) — no regressions reported in merge titles.
- **Core CI matrix is defined and exercised on PRs:** RSpec, Brakeman (non-blocking exit), RuboCop, markdown link check, CodeQL, Factory Droid (informational on many PRs).
- **Docker path exists:** `Dockerfile` (Ruby 3.4.2-slim), `publish_docker_image.yml` pushes `ebwiki/ebwiki:latest` on `main` (requires DockerHub secrets).
- **Modernization analysis is written and CI-green** on branch `cursor/hanami-migration-analysis-fe74` (#4409): `docs/HANAMI_MIGRATION.md` documents maintainer cuts and recommends Rails-first dependency reduction before any rewrite.

### Known gaps / drift

| Area | Detail |
| --- | --- |
| **Docs stale vs code** | `README.md` still cites Ruby 3.2 / Rails 7; `docs/PROJECT_STATUS.md` last updated March 2026; `brakeman_report.txt` is a 2023 Rails 5.2 scan |
| **CI blind spot** | `.github/workflows/ci.yml` has no `push:` trigger — post-merge `main` is not re-validated automatically |
| **Search stack** | `Gemfile` still pulls `elasticsearch`, `searchkick`; CI spins ES 6.8.13; `render.yaml` on unmerged `render` branch still lists `ELASTICSEARCH_URL` |
| **Hosting docs** | `docs/DEPLOYING.md` is Heroku-only; Render migration branches (`render`, `4204_migrate_ebwiki_staging_to_render`) never landed on `main` |
| **Large stale branch** | `cursor/rails-8-modernization-060d` (#4406): 161 files, **merge conflicts**, CI failing — largely superseded by incremental merges to `main` |
| **Dependabot backlog** | `docs/DEPENDABOT_BACKLOG_CLEANUP.md` (July 2026) lists cleanup actions; #4354 (rack patch) and #4398 (dev deps) still open with conflicts or RuboCop failures |

---

## Open pull requests (13)

Recommendations assume **draft = not merge-ready** unless noted. PR Manager owns merge queue.

| PR | Branch | Draft | CI (RSpec / RuboCop) | Recommendation | One-line rationale |
| --- | --- | --- | --- | --- | --- |
| [#4413](https://github.com/EBWiki/EBWiki/pull/4413) | `cursor/hanami-first-slice-fe74` | Yes | ✅ / ✅ | **Wait** | Parallel Hanami app + Railway demo; product/architecture decision before any merge to `main` |
| [#4412](https://github.com/EBWiki/EBWiki/pull/4412) | `cursor/staff-tools-replace-admin-fe74` | Yes | ❌ / ❌ | **Revise** | Rebase onto `main`, fix RSpec + RuboCop; third in agreed Rails-first cut sequence |
| [#4411](https://github.com/EBWiki/EBWiki/pull/4411) | `cursor/remove-mailbox-fe74` | Yes | ❌ / ✅ | **Revise** | Rebase and fix failing specs before merge; depends on search cut landing first |
| [#4410](https://github.com/EBWiki/EBWiki/pull/4410) | `cursor/pg-search-drop-elasticsearch-fe74` | Yes | ✅ / ✅ | **Merge** | Highest hosting ROI: drops ES from app + CI; aligns with #4409 maintainer decisions |
| [#4409](https://github.com/EBWiki/EBWiki/pull/4409) | `cursor/hanami-migration-analysis-fe74` | Yes | ✅ / ✅ | **Merge** | Docs-only feasibility study (+348 lines); behind `main` but mergeable — rebase preferred |
| [#4407](https://github.com/EBWiki/EBWiki/pull/4407) | `cursor/friendly-photos-search-dfb7` | Yes | ✅ / ❌ | **Wait** | Nice-to-have feature; fix RuboCop and confirm product scope before review |
| [#4406](https://github.com/EBWiki/EBWiki/pull/4406) | `cursor/rails-8-modernization-060d` | Yes | ❌ / ❌ | **Close** | Conflicting 161-file mega-PR; Playwright/importmap work should be re-scoped as small PRs off current `main` |
| [#4400](https://github.com/EBWiki/EBWiki/pull/4400) | `dependabot/.../bundler-security-...` | No | ✅ / ✅ | **Merge** | Routine security patch group when PR Manager slot available |
| [#4399](https://github.com/EBWiki/EBWiki/pull/4399) | `copilot/update-github-actions-workflow` | Yes | n/a | **Wait** | CI architecture refactor; needs maintainer review against current Droid/CodeRabbit setup |
| [#4398](https://github.com/EBWiki/EBWiki/pull/4398) | `dependabot/.../bundler-dev-...` | No | ✅ / ❌ | **Revise** | Fix RuboCop failures or close and let Dependabot recreate per backlog policy |
| [#4387](https://github.com/EBWiki/EBWiki/pull/4387) | `copilot/explore-codebase-implementation-plan` | Yes | n/a | **Close** | Stale Copilot exploration (May 2026); no actionable diff |
| [#4354](https://github.com/EBWiki/EBWiki/pull/4354) | `dependabot/bundler/rack-2.2.23` | No | n/a | **Revise** | Patch called out in backlog doc; **conflicts** — rebase or recreate |
| [#4326](https://github.com/EBWiki/EBWiki/pull/4326) | `copilot/sub-pr-4316` | Yes | n/a | **Close** | Conflicting RuboCop sub-PR; superseded by current toolchain on `main` |

### Suggested merge order (Rails-first cuts from #4409)

1. **#4410** — drop Elasticsearch / wire `pg_search`  
2. **#4411** — remove Mailboxer (after #4410 rebased)  
3. **#4412** — staff tools replace Administrate (after #4411)  
4. **#4409** — land analysis doc (anytime; no runtime impact)

Hanami slice **#4413** stays out of this queue until stakeholders choose parallel-stack vs Rails-only path.

---

## Branches that matter (not all have open PRs)

| Branch | Last activity | Notes |
| --- | --- | --- |
| `cursor/hanami-first-slice-fe74` | 2026-09-03 | #4413 — Hanami app under `apps/hanami`, Railway staging with restored case data |
| `cursor/hanami-migration-analysis-fe74` | 2026-08-20 | #4409 — `docs/HANAMI_MIGRATION.md` |
| `cursor/pg-search-drop-elasticsearch-fe74` | 2026-08-20 | #4410 — ES removal |
| `cursor/remove-mailbox-fe74` | 2026-08-20 | #4411 |
| `cursor/staff-tools-replace-admin-fe74` | 2026-08-20 | #4412 |
| `cursor/rails-8-modernization-060d` | 2026-08-15 | #4406 — large; conflicting |
| `render` / `render-staging` | 2024 | `render.yaml` exported; staging domain `staging-render.ebwiki.org`; not on `main` |
| `4204_migrate_ebwiki_staging_to_render` | — | Render migration spike for #4204 |
| `feature/docker-compose` | — | Local full-stack dev; predates current Ruby 3.4 stack |
| `rails_base_app_platform` | — | Rails 7 platform experiment |

---

## Hosting readiness vs ~$1,500 first-year ops budget

**Context:** External proposal targets ~**$1,500/year operating spend** (hosting + managed services — not build labor). Proposal lives outside this repo; gaps below are repo-observable only.

### Current production shape (from code/docs)

| Component | Required today | Hosting note |
| --- | --- | --- |
| Web | Puma (`Procfile`) | 1 web service |
| Database | Postgres 17 (CI pin) | Managed PG |
| Cache / jobs | Redis (`config/redis.yml`) | Managed Redis |
| Search | Elasticsearch 6.8 + Searchkick | **Highest cost/complexity driver**; removable via #4410 |
| Files | fog-aws / S3 (`carrierwave`) | AWS billing separate from PaaS |
| Email / analytics | SendGrid, New Relic, Rollbar, reCAPTCHA, etc. | Env vars in unmerged `render.yaml` |

### Railway vs DigitalOcean / Render style ops

| Topic | Gap |
| --- | --- |
| **No IaC on `main`** | `render.yaml` exists only on `render` branch (2024 export); no Railway/DO manifest in tree |
| **Heroku lock-in in docs** | `DEPLOYING.md`, `.buildpacks`, Heroku-specific release flow — cutover playbook not in repo |
| **Multi-service cost** | At ~$125/mo all-in, **Postgres + Redis + web + Elasticsearch** exceeds budget on most PaaS tiers; dropping ES (#4410) is prerequisite for $1,500/year feasibility |
| **Hanami Railway demo** | #4413 proves Railway can host a read-heavy slice; **not** a production Rails cutover |
| **Docker publish** | Image builds on `main` push but no documented deploy target binding |
| **Secrets / env parity** | `render.yaml` lists 40+ env vars; no checked-in `.env.example` refresh on `main` for non-Heroku hosts |
| **Post-cutover runbook** | `release-tasks.sh` only runs `db:migrate` — no search reindex strategy documented after ES removal |

### What $1,500/year likely supports (after #4410)

Rough envelope if Elasticsearch is removed and S3 stays on existing AWS account:

- **Railway or Render:** web + Postgres + Redis starter/small tiers (~$60–100/mo combined at low traffic)
- **DO App Platform alternative:** similar tiering; requires porting `Procfile`/build commands from Heroku/Render branches
- **Remaining budget headroom:** domain, backups, monitoring free tiers, modest S3 egress

**Blockers before any host switch:** merge #4410, refresh deploy docs, land Render/Railway config on `main`, validate staging with production-like env, migrate DNS from Heroku.

---

## Monday coding action (claimable)

**Primary:** Rebase [#4410](https://github.com/EBWiki/EBWiki/pull/4410) (`cursor/pg-search-drop-elasticsearch-fe74`) onto current `main`, confirm CI green, mark ready for review, and queue for PR Manager merge.

**Why this first:** Only open modernization PR that is CI-green, mergeable, and directly reduces hosting surface (no Elasticsearch cluster). Unblocks #4411/#4412 and makes any Render/Railway/DO migration financially plausible within the $1,500 ops envelope.

**Acceptance criteria:**

- [ ] Branch rebased; no conflicts with post-#4415 `main`
- [ ] CI: RSpec, RuboCop, Brakeman pass
- [ ] `docs/DEPLOYING.md` changes in PR reviewed for Heroku **and** future host (remove ES reindex step, document `pg_search` only)
- [ ] Draft flag removed when PR Manager approves scope

**Secondary (if #4410 blocked):** Rebase #4409 (docs-only Hanami analysis) — zero runtime risk, gives stakeholders the written decision record on `main`.

---

## Owners

| Role | Next step |
| --- | --- |
| **CloudAgent / factory** | Execute Monday action above |
| **PR Manager** | Merge queue for #4410 → #4409 → Dependabot #4400 |
| **Mark** | Send stakeholder update (Marshal drafts) |
| **Marshal** | Track GKT-168 exit criteria; no merge/force-push/spend from this agent run |

---

_Generated 2026-09-05 by Cursor Cloud Agent (GKT-168). No secrets, credentials, or client PII included._
