# Bootstrap OpenTofu (run once)

Creates shared infrastructure secrets in Doppler environment **`ebwiki/infra`**.

Run **`make bootstrap`** once from a trusted machine. **`scripts/bootstrap.sh`** wraps the run in **`doppler run --project grandkru --config prd`** and maps maker secrets into the environment.

## Maker secrets (grandkru/prd)

| Secret | Role |
| --- | --- |
| **`CLOUDFLARE_TOKEN_MAKER`** | Authenticates provider **`cloudflare.token_maker`** only |
| **`DOPPLER_TOKEN_MAKER`** | Authenticates the Doppler provider (**`DOPPLER_TOKEN`**) |
| **`CLOUDFLARE_ZONE_READ_API_TOKEN`** | Read-only zone lookup (covers **ebwiki.org** and **grandkru.com**; account ID and both zone IDs) |
| **`RAILWAY_API_TOKEN`** | Copied into **`infra`** as **`RAILWAY_TOKEN`** |

Seed **`RAILWAY_API_TOKEN`**, **`ROLLBAR_ACCOUNT_API_KEY`**, and **`CLOUDFLARE_ZONE_READ_API_TOKEN`** in **`grandkru/prd`** before the first **`make bootstrap`** run.

Export **`TF_VAR_bootstrap_state_passphrase`** locally (16+ characters) before **`make bootstrap`**.

## How Cloudflare tokens are created

**`CLOUDFLARE_TOKEN_MAKER`** has only **User > API Tokens: Edit** (Create Additional Tokens). It cannot read accounts or zones, and Cloudflare will not allow a **created** token to manage other tokens.

OpenTofu uses the maker as **`cloudflare.token_maker`** and creates **final** user API tokens directly (**`cloudflare_api_token`** resources). Each created token has a fixed job (DNS, R2 admin, or R2 state). None of them receive API Tokens Edit or any token-management permission.

| Minted token | Permission (summary) | Used by |
| --- | --- | --- |
| **`staging_ebwiki_dns`** | DNS Write, Dynamic URL Redirects Write and Read on **ebwiki.org** | Staging provider **`cloudflare.ebwiki`** |
| **`staging_grandkru_dns`** | DNS Write on **grandkru.com** only | Staging provider **`cloudflare.grandkru`** |
| **`r2_admin`** | Workers R2 Storage Write on the **grandkru.com** Cloudflare account (short-lived; removed after bucket creation) | Provider **`cloudflare.r2_admin`** to create the bucket once |
| **`r2_state`** | Workers R2 Storage Bucket Item Write on the state bucket (same account) | S3-compatible credentials in **`infra`** |

DNS tokens stay scoped to their zones. Shared object storage (OpenTofu state and DB snapshots) uses the **grandkru.com** account ID from zone lookup (**`cloudflare_r2_account_id`**), because object storage is enabled there.

Zone and account IDs in **`terraform.tfvars`** come from the **zone read** token, not from the token maker.

## What bootstrap creates

- Private object storage bucket on the **grandkru.com** Cloudflare account (OpenTofu state and staging DB snapshots). **`R2_BUCKET_NAME`**, **`R2_S3_ENDPOINT`**, and **`CLOUDFLARE_ACCOUNT_ID`** in **`infra`** update in place when the account changes; resource addresses in OpenTofu state stay the same.
- Minted Cloudflare tokens above, stored in **`ebwiki/infra`**
- **`TF_VAR_state_passphrase`** (random) for staging stacks
- Config-scoped **Doppler service tokens** on **`stg` only**: read/write **`DOPPLER_TOKEN`** in **`infra`** for staging apply, and a read-only **`STAGING_RUNTIME_DOPPLER_TOKEN`** for Railway
- **`BOOTSTRAP_STATE_PASSPHRASE`**, **`STATE_PASSPHRASE`**, **`RAILWAY_TOKEN`**, **`STAGING_BASIC_AUTH_USERNAME`** (generated), Cloudflare DNS tokens, and **`STAGING_EXPECTED_POSTGRES_DB=ebwiki`** in **`infra`**. OpenTofu variables are exported from these names by **`scripts/infra-with-tf-vars.sh`** (see **`scripts/lib/infra-export-tf-vars.sh`**).
- Migrates bootstrap state from local encrypted storage into R2 in the same **`make bootstrap`** run

## Two apply stages

**Stage 1:** **`cloudflare.token_maker`** mints DNS and R2 admin tokens, creates **`ebwiki/infra`**, and writes Doppler secrets that do not need the bucket yet.

**Stage 2:** **`cloudflare.r2_admin`** (the minted admin token, not the maker) creates the R2 bucket; **`cloudflare.token_maker`** mints the bucket-scoped **`r2_state`** token; R2 credentials land in **`infra`**. Then **`scripts/bootstrap.sh`** deletes the ephemeral R2 admin token in Cloudflare and removes the admin token and bucket from bootstrap state (the bucket remains in the account). The admin token expiry is pinned after the first apply so later plans do not rotate it. Later bucket changes require minting a fresh admin token by hand.

Both stages run from **`make bootstrap`** (stage 1 uses OpenTofu **`-exclude`** on bucket-dependent resources).

## Resuming a partial first-time setup

If a run stopped after Cloudflare tokens and random values were written to encrypted local state, run **`make bootstrap`** again with the same **`TF_VAR_bootstrap_state_passphrase`**. OpenTofu updates existing resources instead of minting duplicate DNS tokens. Stage 2 creates a new short-lived R2 admin token whenever that token is missing from state (normal after a completed stage 2 cleanup, or if stage 2 never ran).

If local state still references removed **`doppler_service_account_*`** resources from an older revision, remove those addresses with **`tofu state rm`** before resuming.

## Remaining manual steps

These are not automated by OpenTofu:

1. **Railway GitHub app** in the EBWiki org (browser), or run **`scripts/railway-github-access.sh`** if the app is already installed.
2. **Railway CLI** and an **SSH key registered** with Railway (**`railway ssh keys add`**) before staging **`make apply`** (Postgres snapshots).

**`terraform.tfvars`** (zone and account IDs) is generated by **`scripts/write-bootstrap-tfvars.sh`**. Staging **`terraform.tfvars`** is generated by **`scripts/write-staging-tfvars.sh`** before plan/apply.

## Commands

From the repo root:

```bash
export TF_VAR_bootstrap_state_passphrase='your-16-char-passphrase'
make bootstrap
```

Then **`make plan`** and **`make apply`** ( **`scripts/staging-*.sh`** use **`doppler run --project ebwiki --config infra`** ).

OpenTofu **plan** for staging runs locally (not in PR CI).
