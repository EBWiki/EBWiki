# Staging host OpenTofu (`staging.ebwiki.org`)

OpenTofu stack for [GKT-462](https://linear.app/gkt/issue/GKT-462). Adopts the existing Railway **ebwiki** project and service, points **staging.ebwiki.org** at Railway, and wires runtime **`DOPPLER_TOKEN`** on Railway.

**Prerequisite:** **`make bootstrap`** so **`ebwiki/infra`** holds R2 credentials, DNS token, passphrases, **`RAILWAY_TOKEN`**, staging basic-auth username, Postgres DB name, and apply **`DOPPLER_TOKEN`**. PR Manager runs bootstrap, plan, and apply from the PR Manager machine.

## Manual, no API

1. **Railway GitHub app:** browser install if needed; else PR Manager runs **`scripts/railway-github-access.sh`**.
2. **Railway CLI** on the PR Manager machine, plus an **SSH key registered** with Railway (`railway ssh keys add`) so **`railway ssh`** can run **`pg_dump` inside the Postgres service** (`postgres:17`, service name **`Postgres`** by default). This works before apply while staging still runs image **`ebwiki/ebwiki:184`** (that image has no **`pg_dump`**).

Bootstrap seeds **`RAILWAY_TOKEN`**, **`TF_VAR_staging_basic_auth_username`**, and **`STAGING_EXPECTED_POSTGRES_DB=ebwiki`** in **`ebwiki/infra`**. OpenTofu still creates **`STAGING_PASSWORD`** in **`stg`** at apply time.

**`terraform.tfvars`** is written by **`scripts/write-staging-tfvars.sh`** before **`make plan`** and **`make apply`** (Railway GraphQL plus Cloudflare DNS API, using Doppler **`ebwiki/infra`**).

## Behavior change

Live staging runs image **`ebwiki/ebwiki:184`** with **`db:prepare`**. Apply switches to **main** with **`railway.staging.toml`** (**`release-tasks.sh`**, migrate only). Root **`railway.toml`** stays unchanged so other Railway services in this repo are unaffected.

**Database:** **`scripts/staging-apply.sh`** (and **`make apply`**) runs **`staging-db-snapshot.sh`** first: **`pg_dump`** on the **Postgres** service via **`railway ssh`**, streamed to R2 **`staging/db-snapshots/`** with no local temp file. After snapshot, verify with **`pg_restore --list`** on the object (see **`MIGRATIONS_ROLLBACK.md`**). See **`MIGRATIONS_ROLLBACK.md`** for restore guards (**`CONFIRM_RESTORE`** must match the project id).

## Commands

PR Manager, from the repo root on the PR Manager machine:

```bash
make plan
make snapshot   # optional alone; staging-apply.sh always snapshots first
make apply
```

Plan and apply run on the PR Manager machine via Doppler **`ebwiki/infra`** (not in PR CI).

## Doppler secrets

OpenTofu **creates** **`STAGING_USERNAME`** and **`STAGING_PASSWORD`** in **`ebwiki/stg`**. Runtime: **`scripts/doppler-at-runtime.md`**.

## Overlap with PR #4528

Apply **this stack first**, then **#4528**.
