# Staging host OpenTofu (`staging.ebwiki.org`)

OpenTofu stack for [GKT-462](https://linear.app/gkt/issue/GKT-462). Adopts the existing Railway **ebwiki** project and service, points **staging.ebwiki.org** at Railway, and wires runtime **`DOPPLER_TOKEN`** on Railway.

**Prerequisite:** **`make bootstrap`** so **`ebwiki/infra`** holds R2 credentials, DNS token, passphrases, and apply **`DOPPLER_TOKEN`**.

## Manual, no API

1. **One-time Cloudflare bootstrap token** (dashboard) for **`make bootstrap`** only.
2. **One-time Doppler bootstrap token** or **`doppler login`** for **`make bootstrap`** only.
3. **`RAILWAY_TOKEN`** in **`ebwiki/infra`** after bootstrap (Railway dashboard).
4. **Railway GitHub app:** browser install if needed; else **`scripts/railway-github-access.sh`**.

Also set **`TF_VAR_staging_basic_auth_username`** in **`ebwiki/infra`** before apply (generated password is new in Doppler **`stg`**).

**`terraform.tfvars`** is written by **`scripts/write-staging-tfvars.sh`** before **`make plan`** and **`make apply`** (Railway GraphQL plus Cloudflare DNS API, using Doppler **`ebwiki/infra`**).

## Behavior change

Live staging runs image **`ebwiki/ebwiki:184`** with **`db:prepare`**. Apply switches to **main** with **`railway.staging.toml`** (**`release-tasks.sh`**, migrate only). Root **`railway.toml`** stays unchanged so other Railway services in this repo are unaffected.

**Database:** **`make apply`** runs **`make snapshot`** first ( **`pg_dump`** to R2 **`staging/db-snapshots/`** ). See **`MIGRATIONS_ROLLBACK.md`**.

## Commands

```bash
make plan
make snapshot   # optional alone; always runs before apply
make apply
```

Plan runs only on Mark's machine via Doppler **`ebwiki/infra`** (not in PR CI).

## Doppler secrets

OpenTofu **creates** **`STAGING_USERNAME`** and **`STAGING_PASSWORD`** in **`ebwiki/stg`**. Runtime: **`scripts/doppler-at-runtime.md`**.

## Overlap with PR #4528

Apply **this stack first**, then **#4528**.
