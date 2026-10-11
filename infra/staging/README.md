# Staging host OpenTofu (`staging.ebwiki.org`)

OpenTofu stack for [GKT-462](https://linear.app/gkt/issue/GKT-462). Adopts the existing Railway **ebwiki** project and service, points **staging.ebwiki.org** at Railway, and wires a read-only **DOPPLER_TOKEN** on Railway for runtime config.

**Prerequisite:** run **`make bootstrap`** once (`infra/bootstrap/`) so **`ebwiki/infra`** holds R2 credentials, DNS token, state passphrase, and **`DOPPLER_TOKEN`** for this stack.

## Manual steps (no API)

Only these stay outside OpenTofu:

1. **`RAILWAY_TOKEN`**: add to **`ebwiki/infra`** by hand after bootstrap (Railway has no token-creation API for OpenTofu).
2. **Railway GitHub app**: in the Railway dashboard, grant the GitHub app access to **EBWiki/EBWiki** before switching the service to **`source_repo`**.

## Behavior change (name before apply)

Live staging today runs Docker image **`ebwiki/ebwiki:184`** with pre-deploy **`db:prepare`**. This stack sets **`source_repo`** to **EBWiki/EBWiki** on **`main`** with **`railway.toml`**, so pre-deploy becomes **`bash release-tasks.sh`** (**`db:migrate` only**). That switch must appear in deploy, test, and rollback plans.

## Commands

From the repository root (loads **`ebwiki/infra`** via Doppler CLI auth):

```bash
make plan
make apply
```

Equivalent: **`./scripts/staging-plan.sh`** and **`./scripts/staging-apply.sh`**. These write **`backend.hcl`** from Doppler, then run OpenTofu with **`AWS_*`**, **`TF_VAR_state_passphrase`**, and provider tokens from **`infra`**.

Set Railway and Cloudflare staging IDs in gitignored **`infra/staging/terraform.tfvars`** or **`TF_VAR_*`** (see **`terraform.tfvars.example`**). Do not commit real IDs.

## Overlap with PR #4528 (GKT-1293)

Apply **this stack first**, then **#4528**. Shared R2 bucket (from bootstrap); staging state key **`staging/terraform.tfstate`**, cloudflare key **`cloudflare/terraform.tfstate`**. DNS token name **`CLOUDFLARE_DNS_API_TOKEN`** vs Access token **`CLOUDFLARE_ACCESS_API_TOKEN`** for #4528.

## Remote state

R2 bucket and S3 credentials come from **`ebwiki/infra`** (bootstrap). State encryption uses **`TF_VAR_state_passphrase`** from the same config. Stale lock: **`tofu force-unlock`** (OpenTofu [#4405](https://github.com/opentofu/opentofu/issues/4405)).

## Doppler

OpenTofu **adopts** **`STAGING_USERNAME`** and **`STAGING_PASSWORD`** (`ignore_changes` on values). Sets **`HOST`**. Runtime: **`scripts/doppler-at-runtime.md`**.

## Adopting live resources

Import blocks in **`imports.tf`** adopt Railway and Cloudflare resources. Confirm **`terraform.tfvars`** IDs against live Railway and Cloudflare before apply.

GitHub source drift: **`scripts/railway-manual-settings.sh`**.
