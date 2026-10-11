# Bootstrap OpenTofu (run once)

Creates shared infrastructure secrets in Doppler environment **`ebwiki/infra`** (its own environment, not a branch of **`prd`**). Mark runs this once with a high-privilege Cloudflare token and a one-time Doppler bootstrap token.

## What bootstrap creates

- Cloudflare **DNS Write** API token scoped to **ebwiki.org** only
- Private **R2** bucket and bucket-scoped object read/write credentials for OpenTofu state
- **`TF_VAR_state_passphrase`** (random) for staging and cloudflare stacks
- Doppler **service account** with **Collaborator** on **`stg` only** (includes **Manage Service Tokens** per [Doppler project permissions](https://docs.doppler.com/docs/project-permissions)); its API key is stored as **`DOPPLER_TOKEN`** in **`infra`** for staging OpenTofu apply
- **`TF_VAR_bootstrap_state_passphrase`** copied into **`infra`** for later bootstrap state access
- **Required:** migrates bootstrap state from local encrypted storage into R2 in the same **`make bootstrap`** run

## Doppler service account and Collaborator role

Bootstrap uses project role **`collaborator`** on environment **`stg`** only. Doppler documents that Collaborators may **create, roll, and delete service tokens** for configs they can access (`enclave_project_config_service_tokens`). That is the smallest built-in role that lets staging OpenTofu create **`doppler_service_token.railway_runtime`** without a user personal token.

## Inputs (Mark provides once)

| Input | How |
| --- | --- |
| **`TF_VAR_bootstrap_state_passphrase`** | 16+ characters; encrypts bootstrap state (also stored in **`ebwiki/infra`**) |
| **`TF_VAR_cloudflare_bootstrap_api_token`** | One-time Cloudflare token (create in dashboard; see manual list) |
| **`DOPPLER_TOKEN`** | One-time Doppler bootstrap token, or **`doppler login`** for CLI |
| **`terraform.tfvars`** | **`cloudflare_account_id`**, **`cloudflare_zone_id`** (gitignored) |

## Manual, no API

1. **One-time Cloudflare bootstrap token.** The first token needs a dashboard login, because no token exists yet to create it with.
2. **One-time Doppler bootstrap token**, or **`doppler login`**, for the same reason.
3. **`terraform.tfvars`** in this directory with Cloudflare account and zone IDs (gitignored).
4. **`RAILWAY_TOKEN`** in **`ebwiki/infra`** after bootstrap. Railway tokens are created in the dashboard. The OpenTofu provider cannot create them.
5. **Railway GitHub app:** install on the EBWiki org in the browser if it is not installed yet. If it is already installed, run **`scripts/railway-github-access.sh`** to grant **EBWiki/EBWiki**.

## Commands

```bash
make bootstrap
```

Then complete manual step 4 (and 5 if needed), set **`TF_VAR_staging_basic_auth_username`** in **`ebwiki/infra`**, take a DB snapshot (see **`infra/staging/MIGRATIONS_ROLLBACK.md`**), and run **`make plan`** / **`make apply`**.

OpenTofu **plan** for staging is **local only** (no CI plan job).
