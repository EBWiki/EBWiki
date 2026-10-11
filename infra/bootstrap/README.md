# Bootstrap OpenTofu (run once)

Creates shared infrastructure secrets and stores them in Doppler **`ebwiki/infra`**. Mark runs this **once** with a high-privilege Cloudflare token and a Doppler token that can write the **`infra`** config.

## What bootstrap creates

- Cloudflare **DNS Edit** API token scoped to **ebwiki.org** only
- Private **R2** bucket and an account token with **object read/write on that bucket only** (S3-compatible keys derived for OpenTofu)
- **`TF_VAR_state_passphrase`** (random, 32 characters) for staging and cloudflare stacks
- Doppler **read/write service token** for **`ebwiki/stg`** (stored in **`infra`** as **`DOPPLER_TOKEN`** for staging OpenTofu apply)
- All of the above written into **`ebwiki/infra`**

## Inputs (Mark provides once)

| Input | How |
| --- | --- |
| **`TF_VAR_bootstrap_state_passphrase`** | 16+ characters; encrypts **local** bootstrap state only (also keep in a password manager) |
| **`TF_VAR_cloudflare_bootstrap_api_token`** | Cloudflare token that can create API tokens, account tokens, and R2 buckets |
| **`DOPPLER_TOKEN`** | Doppler token that can create **`infra`** config and secrets |
| **`terraform.tfvars`** | **`cloudflare_account_id`**, **`cloudflare_zone_id`** (gitignored) |

## State

Bootstrap uses **local**, **encrypted** state in this directory (gitignored). After the first successful apply, optionally migrate bootstrap state into the new R2 bucket under key **`bootstrap/terraform.tfstate`** using the credentials now in **`ebwiki/infra`**.

## Manual steps (no API)

After bootstrap and before staging apply:

1. **`RAILWAY_TOKEN`**: add to **`ebwiki/infra`** by hand (Railway has no read-only token API for OpenTofu).
2. **Railway GitHub app**: grant access to **EBWiki/EBWiki** in the Railway dashboard.

## Commands

```bash
make bootstrap
# or: ./scripts/bootstrap.sh
```

Then staging:

```bash
make plan
make apply
```

See repository **`scripts/`** helpers and **`infra/staging/README.md`**.
