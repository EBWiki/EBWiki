# GKT-794 → EBWiki #4446 tip reconfirm (read-only)

**Idempotency:** `GKT-175:auto:4446-reconfirm-after-462-inventory-20261005`  
**Generated:** 2026-10-05T20:32Z (UTC)  
**Scope:** Reconfirm PR [#4446](https://github.com/EBWiki/EBWiki/pull/4446) branch tip after [GKT-462](https://linear.app/gkt/issue/c3d9cfb2-1ef4-46d9-91fd-2c766d38ba5f) staging-gate inventory ([GKT-784](https://linear.app/gkt/issue/GKT-784) / `artifacts/GKT-784-462-staging-gate-inventory.md` on branch `cursor/gkt-784-staging-gate-inventory-0c84`, PR [#4481](https://github.com/EBWiki/EBWiki/pull/4481) closed without merge). Zero infra mutations this run.

**Parent [GKT-175](https://linear.app/gkt/issue/GKT-175):** stays **open** (this reconfirm does not close it).

Linear MCP was **not authenticated** in this environment; ticket text below follows operator instructions plus live GitHub/Railway/Doppler/HTTP probes.

---

## Question

After GKT-462 inventory recorded **WAIT** (Render-suspended public DNS, empty Doppler `ebwiki/stg`), is PR **#4446** still the correct, review-ready **tip** for Railway staging deploy on `main`, and is **merge** still appropriately gated?

---

## #4446 tip reconfirm (code / CI / review)

| Check | Result | Evidence (2026-10-05 UTC) |
| --- | --- | --- |
| **Tip SHA** | **PASS** | `headRefOid` = `af37a490c2e785870c577efd55490c88f0c8170e` — matches PR body **Tip SHA:** `af37a490` |
| **vs `main`** | **PASS** | Compare `main...af37a490`: **ahead 5**, **behind 0**, **mergeable**, 13 files (Railway deploy path only) |
| **CI** | **PASS** | `gh pr checks 4446`: rspec, rubocop, brakeman, markdown-link-checker, CodeQL — **pass** on tip commit workflow runs |
| **Human review** | **PASS** | `@gktreviewer` **APPROVED** — *“Merge held until Mark merge GO.”* |
| **Scope** | **PASS** | Named change: `Dockerfile.railway`, `railway.toml`, `/up`, staging boot fixes, `docs/STAGING_RAILWAY.md` — unchanged file set vs inventory snapshot |

**#4446 tip recommendation:** **GO** — tip is stable, current with `main`, CI green, and review-approved; no newer commits on `cursor/railway-staging-main-03ea` since inventory.

---

## GKT-462 gate reconfirm (staging GO — cited inventory + fresh probes)

Inventory source: GKT-784 artifact (**GKT-462: WAIT**). This run **re-probed** connectors; state **unchanged**.

| Gate | Inventory (GKT-784) | Reconfirm (this run) | Result |
| --- | --- | --- | --- |
| **A. Railway spend GO** | No verified human spend GO in accessible systems | Not re-litigated (read-only; no billing API) | **WAIT** |
| **B. Doppler `ebwiki/stg`** | Empty — meta keys only | `secrets_names` → `DOPPLER_CONFIG`, `DOPPLER_ENVIRONMENT`, `DOPPLER_PROJECT` only | **WAIT** |
| **C. `staging.ebwiki.org` DNS** | Public **503**, `x-render-routing: suspend`; Railway CNAME **REQUIRES_UPDATE** | `curl -sI https://staging.ebwiki.org/up` → **503**, `x-render-routing: suspend`, `server: cloudflare`; Railway `domain-status`: verified **no**, cert **VALIDATING_OWNERSHIP**, CNAME `staging.ebwiki.org` → `g6tfr1yl.up.railway.app` **REQUIRES_UPDATE (unset)** | **WAIT** |

**Live app note:** `GET https://ebwiki-web-production-cc7e.up.railway.app/up` → **404** (pre-#4446 image; expected until merge + redeploy on Railway path).

**GKT-462 recommendation (reconfirmed):** **WAIT** — same blockers as inventory: **Render-suspended DNS** at the public host, **empty Doppler `ebwiki/stg`**, Railway domain **unverified**.

---

## Merge disposition for #4446

| Action | Recommendation | Rationale |
| --- | --- | --- |
| **Keep PR open as staging deploy tip** | **GO** | Tip integrity and CI/review bar still met |
| **Merge #4446 to `main`** | **WAIT** | GKT-462 **WAIT**; `@gktreviewer` explicitly holds merge until Mark merge GO; merging without DNS/secrets/spend GO does not deliver working `staging.ebwiki.org` |

**Overall (operator-facing):** **WAIT** on merge; **GO** on tip reconfirm.

---

## Downstream (unchanged)

- **GKT-462** — parent human gate; **stay open** until A ∧ B ∧ C pass.
- **GKT-175** — parent epic; **stay open**.
- **#4450** — remains **merge-WAIT** on GKT-462 per inventory (out of scope except as cross-reference).
- **Mark was not pinged** (per ticket instructions).
- **No EBWiki PR opened** for this report (artifact-only).

---

## Repro commands

```bash
# Tip + CI
gh pr view 4446 --repo EBWiki/EBWiki --json headRefOid,mergeable,state,reviews
gh pr checks 4446 --repo EBWiki/EBWiki
gh api repos/EBWiki/EBWiki/compare/main...af37a490c2e785870c577efd55490c88f0c8170e \
  --jq '{ahead_by, behind_by, status, files: (.files|length)}'

# Staging host
curl -sI https://staging.ebwiki.org/up
curl -sI https://ebwiki-web-production-cc7e.up.railway.app/up
```

Railway MCP: `domain-status` — project `5e9fc613-b97c-4ed2-a721-966aa54490c8`, service `745e0c67-a192-44d1-ad5e-e4dc616720b7`, domain `staging.ebwiki.org`.  
Doppler MCP: `secrets_names` — `project=ebwiki`, `config=stg`.
