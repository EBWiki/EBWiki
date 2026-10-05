# GKT-784 → GKT-462 staging gate inventory (read-only)

**Idempotency:** `GKT-462:auto:staging-gate-inventory-20261005-1624`  
**Generated:** 2026-10-05T20:26Z (UTC)  
**Scope:** Railway spend posture, Doppler `ebwiki/stg`, `staging.ebwiki.org` DNS — zero mutations this run.

---

## Assumption

GKT-462 is the **human GO** that unblocks operator work (Doppler → Railway secret sync, Cloudflare DNS repoint, and explicit acceptance of ongoing Railway cost) before **merge** of staging deploy config (**#4446**) or friendly-photos staging walkthrough merge (**#4450**). This inventory does not substitute for that GO; it only records live connector state vs the bar.

Linear MCP was **not authenticated** in this environment; parent state below is from Notion Linear search index + factory Activity Backup (2026-10-05 ~8:54am ET), cross-checked with GitHub/Railway/Doppler/HTTP probes on 2026-10-05T20:25Z.

---

## Cited Linear GKT-462 state (parent)

| Field | Value |
| --- | --- |
| **Identifier** | [GKT-462](https://linear.app/gkt/issue/c3d9cfb2-1ef4-46d9-91fd-2c766d38ba5f) |
| **Title** | `[human] GO: Railway staging spend + ebwiki/stg secrets + staging.ebwiki.org DNS repoint` |
| **Creator** | mark@grandkru.com |
| **Created / updated** | 2026-10-05 (per Notion Linear index) |
| **Completed** | **No** (`completedAt` absent in index; factory gap list: “still needs Mark GO on Doppler→Railway secrets sync + staging DNS”) |
| **Disposition for this run** | **Parent stays open** — ticket Done ≠ parent Done |

**Related spikes (completed; inform bar only):**

- [GKT-459](https://linear.app/gkt/issue/44bee99c-2882-45ec-8f97-0cb2136c57d6) — Railway staging readiness checklist (repo report).
- [GKT-765](https://linear.app/gkt/issue/8a733eba-42f8-4a30-8f1d-5108466416b8) — deploy-on-merge readiness inventory (GKT-463).
- [GKT-756](https://linear.app/gkt/issue/df9768f6-0fd0-4448-94d5-f3c278b8e8e4) / [GKT-778](https://linear.app/gkt/issue/4772a983-d776-4090-9f90-0542e5242782) — #4446 Approve/merge packet **gated on GKT-462**.

---

## Pass / fail bar (GKT-462 GO)

| Gate | PASS (GO) | FAIL (WAIT) |
| --- | --- | --- |
| **A. Railway spend** | Human records explicit GO to run **ebwiki** Railway project (app + Postgres 17 + Redis) with expected monthly cost band acknowledged. | Spend not explicitly approved, or billing/usage unknown and not accepted. |
| **B. `ebwiki/stg` secrets** | Doppler config `ebwiki/stg` holds the **name set** required for Rails staging (see PR #4446 `docs/STAGING_RAILWAY.md` on branch `cursor/railway-staging-main-03ea`), and Railway service vars are synced from that SoT (or documented exception). | Doppler `stg`/`prd` empty of app secrets; Railway-only ad hoc vars; material name gaps vs checklist. |
| **C. `staging.ebwiki.org` DNS** | Cloudflare (or registrar) publishes Railway **CNAME** + ownership **TXT**; Railway domain **verified**; public `GET https://staging.ebwiki.org/up` returns **200** without basic auth (once #4446 deploy path is live). | DNS still points elsewhere; Railway `REQUIRES_UPDATE`; cert validating ownership; public host 503/404. |

**Overall GKT-462 recommendation encoding:** **GO** only if A ∧ B ∧ C are PASS; else **WAIT** (never “locked”).

---

## Evidence (connectors + probes)

### 1. Railway spend / runtime (`ebwiki` project `5e9fc613-b97c-4ed2-a721-966aa54490c8`)

**Known**

- Workspace user: mark@grandkru.com (Railway `whoami`).
- Single environment labeled **production** (`c410d298-f0da-4bcc-8140-2829830a9842`) — not a separate “staging” environment.
- **Live services (all SUCCESS, 2026-10-05):**
  - **ebwiki** — Docker image `ebwiki/ebwiki:184`, `us-west2`, 1 replica; latest deploy ~2026-10-05T06:00Z.
  - **Postgres 17** — 5 GB volume `postgres-data`, `us-west2`.
  - **Redis 7** — `us-west2`.
- **Resource metrics (ebwiki, ~1h window):** CPU ~0.0001 avg; memory ~0.24 GB avg — low utilization; **cost still accrues** for three always-on services.
- Custom domain **registered in Railway** on ebwiki service: `staging.ebwiki.org` (port 8080).
- Default Railway URL: `https://ebwiki-web-production-cc7e.up.railway.app` — `GET /up` → **404** (no Rails 8.1 health route on current image; main lacks merged #4446).

**Unknown**

- Dollar **billing / plan / month-to-date spend** — no billing API in connected Railway MCP tools; Activity Backup explicitly avoided Usage & Billing in its window.
- Whether human **GO for spend** was recorded in Linear (Linear MCP unavailable here).

**Prior spike alignment:** GKT-459/GKT-765 expected GitHub→`Dockerfile.railway` deploy; live service still uses root **`Dockerfile`** + Docker Hub tag, not merged #4446 path.

---

### 2. Doppler `ebwiki/stg` (and Railway variable names)

**Known**

- Doppler **`ebwiki/stg`**: only meta keys `DOPPLER_CONFIG`, `DOPPLER_ENVIRONMENT`, `DOPPLER_PROJECT` — **no application secrets** (read-only `secrets_names` / `secrets_list`).
- Doppler **`ebwiki/prd`**: same — meta keys only (unexpected if prd were production SoT; may indicate secrets live only in Railway or another config not queried).
- Railway **ebwiki** service defines **22** app-related variable **names** (values not exported), including: `DATABASE_URL`, `REDIS_URL`, `SECRET_KEY_BASE`, `RAILS_ENV`, `RACK_ENV`, `STAGING_USERNAME`, `STAGING_PASSWORD`, `HTTP_BASIC_AUTH_*`, AWS/S3, New Relic flags, etc.
- PR #4446 `docs/STAGING_RAILWAY.md` documents **~30+** staging names (e.g. `HOST`, `ELASTICSEARCH_URL`, `ROLLBAR_*`, `FOG_DIRECTORY`, …) — several **not** present in Railway name list above.

**Unknown**

- Secret **values** correctness (DB reachable, Redis, `RAILS_ENV=staging` vs production label on “production” environment).
- Whether inline Railway vars were copied from legacy Heroku/Render vs Doppler SoT.
- Doppler↔Railway sync automation state (not observed this run).

**Factory prior:** Activity Backup §5 — `CLOUDFLARE_ZONE_READ_API_TOKEN` read-only; **DNS edit token missing** → repoint blocked from automation side.

---

### 3. `staging.ebwiki.org` DNS / TLS / traffic

**Known**

- **Public HTTP** `GET https://staging.ebwiki.org/up` → **503**, headers `server: cloudflare`, **`x-render-routing: suspend`** (traffic hits **suspended Render**, not Railway).
- **DNS A records** (Cloudflare proxy): `104.21.84.142`, `172.67.193.207` — no CNAME to Railway visible from resolver.
- Railway **`domain-status`** for `staging.ebwiki.org`:
  - Verified: **no**
  - Certificate: **VALIDATING_OWNERSHIP**
  - Required **CNAME:** `staging.ebwiki.org` → `g6tfr1yl.up.railway.app` — status **`REQUIRES_UPDATE` (unset)**
  - Required **TXT:** `_railway-verify.staging.ebwiki.org` → `railway-verify=3ceca2cc…` — ownership not confirmed
- Railway **`GET https://ebwiki-web-production-cc7e.up.railway.app/up`** → **404** (app responds via `railway-hikari` / Puma, not public staging hostname).

**Unknown**

- Cloudflare dashboard record set (only side effects observed via public DNS + HTTP).
- Whether Render service should be deleted or left suspended after cutover.

---

### 4. GitHub merge gates (#4446, #4450)

| PR | State | CI / review | Merge vs GKT-462 |
| --- | --- | --- | --- |
| [#4446](https://github.com/EBWiki/EBWiki/pull/4446) Railway staging deploy on `main` | **OPEN**, mergeable | CI green; **gktreviewer Approved**; comment: *“Merge held until Mark merge GO.”* | **merge-WAIT** until **GKT-462 GO** (and explicit merge GO). Does not close staging alone — DNS + secrets + deploy path still required after merge. |
| [#4450](https://github.com/EBWiki/EBWiki/pull/4450) Friendly photo finder recreate | **OPEN**, **draft** | CI referenced on branch; not undrafted | **merge-WAIT** until **GKT-462 GO** (staging host for GKT-175 walkthrough). PR body: no deploy from this PR. |

Linear index: [GKT-759](https://linear.app/gkt/issue/48f3868c-b331-48aa-894d-d39fc524e6d9) / [GKT-774](https://linear.app/gkt/issue/053e11db-17ca-487c-89ff-f8a472d1b09d) explicitly mark #4450 **GKT-462 gated**.

---

## Known vs unknown summary

| Area | Known | Unknown |
| --- | --- | --- |
| GKT-462 Linear workflow state | Human gate ticket exists; not completed; factory expects Mark GO | Exact Linear **status** field (Todo vs In Progress) — Linear MCP needsAuth |
| Railway spend | Three live billable services; low CPU/RAM | USD/month, plan limits, human GO artifact |
| `ebwiki/stg` | Empty in Doppler; partial names on Railway | Full parity vs STAGING_RAILWAY checklist; sync pipeline |
| DNS | Render-suspended 503 at public host; Railway CNAME/TXT pending | Cloudflare change window; Render decommission |
| #4446 / #4450 | Open; #4446 approved but not merged; #4450 draft | N/A |

---

## Recommendation

**GKT-462: WAIT** (not GO).

| Gate | Result | Reason |
| --- | --- | --- |
| A. Spend | **WAIT** | Services already running but **no verified human spend GO** in accessible systems; billing numbers unknown. |
| B. Secrets | **WAIT** | Doppler **`ebwiki/stg` empty**; Railway vars incomplete vs #4446 staging name matrix; SoT not established. |
| C. DNS | **WAIT** | Public hostname still **Render/Cloudflare 503**; Railway CNAME **unset**; domain **unverified**. |

**Downstream (unchanged by this inventory):**

- **#4446** — remain **merge-WAIT** until GKT-462 **GO** (plus merge GO policy).
- **#4450** — remain **merge-WAIT** until GKT-462 **GO** and staging walkthrough prerequisites.
- **GKT-462** — **stay open**; completing GKT-784 does not close the parent.

**Smallest unlock sequence (human/operator; out of scope for this read-only run):**

1. Record Railway spend GO (GKT-462 acceptance).
2. Populate Doppler `ebwiki/stg` from checklist in #4446 `docs/STAGING_RAILWAY.md`; sync to Railway ebwiki service.
3. Apply Cloudflare **CNAME** + **TXT** per Railway `domain-status`; confirm verified cert.
4. Merge **#4446** when merge GO allows; redeploy from `main`/`Dockerfile.railway`; verify `GET /up` **200** on `staging.ebwiki.org`.
5. Re-run staging gate inventory (new idempotency key) → expect **GO** when A–C pass.

---

## Commands / API references (repro)

```bash
# Public staging host (2026-10-05)
curl -sI https://staging.ebwiki.org/up
curl -sI https://ebwiki-web-production-cc7e.up.railway.app/up

# DNS
dig +short staging.ebwiki.org A
```

Railway MCP (read-only): `list-projects`, `describe-environment`, `describe-service`, `list-variables`, `domain-status`, `get-service-metrics`.  
Doppler MCP (read-only): `secrets_names` / `secrets_list` for `project=ebwiki`, `config=stg`.

**Mark was not pinged** (per ticket instructions).
