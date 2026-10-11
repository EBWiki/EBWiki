# Bootstrap OpenTofu (run once)

Creates shared infrastructure secrets in Doppler environment **`ebwiki/infra`** (its own environment, not a branch of **`prd`**). **PR Manager** runs **`make bootstrap`** once from the PR Manager machine. **Mark** supplies only the one-day **Cloudflare bootstrap token** (created in the Cloudflare dashboard; there is no API to mint the first token).

## What bootstrap creates

- Cloudflare **DNS Write** API token scoped to **ebwiki.org** only
- Private **R2** bucket and bucket-scoped object read/write credentials for OpenTofu state
- **`TF_VAR_state_passphrase`** (random) for staging and cloudflare stacks
- Doppler **service account** with **Collaborator** on **`stg` only** (includes **Manage Service Tokens** per [Doppler project permissions](https://docs.doppler.com/docs/project-permissions)); its API key is stored as **`DOPPLER_TOKEN`** in **`infra`** for staging OpenTofu apply
- **`TF_VAR_bootstrap_state_passphrase`** copied into **`infra`** for later bootstrap state access
- **Required:** migrates bootstrap state from local encrypted storage into R2 in the same **`make bootstrap`** run

## Doppler service account and Collaborator role

Bootstrap uses project role **`collaborator`** on environment **`stg`** only. Doppler documents that Collaborators may **create, roll, and delete service tokens** for configs they can access (`enclave_project_config_service_tokens`). That is the smallest built-in role that lets staging OpenTofu create **`doppler_service_token.railway_runtime`** without a user personal token.

**Confirm the Doppler plan includes role-based access** (Team or Enterprise) before bootstrap. Limiting a service account to the **`stg`** environment relies on that feature.

## Inputs

| Input | Who | How |
| --- | --- | --- |
| **`TF_VAR_cloudflare_bootstrap_api_token`** | Mark (once) | One-day Cloudflare token from the dashboard (see Manual, no API) |
| **`TF_VAR_bootstrap_state_passphrase`** | PR Manager | 16+ characters; encrypts bootstrap state (also stored in **`ebwiki/infra`**) |
| **`doppler login`** or **`DOPPLER_TOKEN`** | PR Manager | Bootstrap auth to write **`ebwiki/infra`** on the PR Manager machine |

## Manual, no API

1. **Mark:** one-time **Cloudflare bootstrap token** (dashboard login only; no API exists to create this first token).
2. **PR Manager:** **Doppler bootstrap token** or **`doppler login`** on the PR Manager machine before **`make bootstrap`**.
3. **`RAILWAY_TOKEN`** in **`ebwiki/infra`** after bootstrap (Railway dashboard). PR Manager adds this when ready for staging plan/apply.
4. **Railway GitHub app:** install on the EBWiki org in the browser if it is not installed yet. If it is already installed, PR Manager runs **`scripts/railway-github-access.sh`** to grant **EBWiki/EBWiki**.

**`terraform.tfvars` for bootstrap and staging** is generated on the PR Manager machine by **`scripts/write-bootstrap-tfvars.sh`** and **`scripts/write-staging-tfvars.sh`** (Cloudflare and Railway lookups via API). Files stay gitignored.

## Commands

PR Manager, from the repo root on the PR Manager machine:

```bash
make bootstrap
```

Then complete manual steps 3 and 4 if needed, set **`TF_VAR_staging_basic_auth_username`** in **`ebwiki/infra`**, and run **`make plan`** / **`make apply`**. **`make apply`** runs **`make snapshot`** first (Postgres dump to R2; see **`infra/staging/MIGRATIONS_ROLLBACK.md`**).

OpenTofu **plan** for staging runs on the PR Manager machine via Doppler **`ebwiki/infra`** (not in PR CI).
