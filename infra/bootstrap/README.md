# Bootstrap OpenTofu (run once)

Creates shared infrastructure secrets in Doppler environment **`ebwiki/infra`** (its own environment, not a branch of **`prd`**). **PR Manager** runs **`make bootstrap`** once from the PR Manager machine. PR Manager mints the short-lived Cloudflare bootstrap API token from **`CLOUDFLARE_TOKEN_MAKER`** (Doppler **`grandkru/prd`**) and uses **`DOPPLER_TOKEN_MAKER`** from the same config for Doppler writes that create **`ebwiki/infra`**.

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

| Input | How |
| --- | --- |
| **`CLOUDFLARE_TOKEN_MAKER`** | Doppler **`grandkru/prd`**; PR Manager uses it to mint **`TF_VAR_cloudflare_bootstrap_api_token`** for bootstrap |
| **`DOPPLER_TOKEN_MAKER`** | Doppler **`grandkru/prd`**; exported as **`DOPPLER_TOKEN`** (or equivalent) so OpenTofu can write **`ebwiki/infra`** |
| **`TF_VAR_bootstrap_state_passphrase`** | PR Manager chooses 16+ characters; encrypts bootstrap state (also stored in **`ebwiki/infra`**) |

## Manual, no API

1. **`RAILWAY_TOKEN`** in **`ebwiki/infra`** after bootstrap (Railway dashboard). PR Manager adds this when ready for staging plan/apply.
2. **Railway GitHub app:** install on the EBWiki org in the browser if it is not installed yet. If it is already installed, PR Manager runs **`scripts/railway-github-access.sh`** to grant **EBWiki/EBWiki**.

**`terraform.tfvars` for bootstrap and staging** is generated on the PR Manager machine by **`scripts/write-bootstrap-tfvars.sh`** and **`scripts/write-staging-tfvars.sh`** (Cloudflare and Railway lookups via API). Files stay gitignored.

## Commands

PR Manager, from the repo root on the PR Manager machine (with **`grandkru/prd`** maker secrets loaded):

```bash
make bootstrap
```

Then complete manual steps 1 and 2 if needed, set **`TF_VAR_staging_basic_auth_username`** in **`ebwiki/infra`**, and run **`make plan`** / **`make apply`**. **`make apply`** runs **`make snapshot`** first (Postgres dump to R2; see **`infra/staging/MIGRATIONS_ROLLBACK.md`**).

OpenTofu **plan** for staging runs on the PR Manager machine via Doppler **`ebwiki/infra`** (not in PR CI).
