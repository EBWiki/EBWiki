# Staging host OpenTofu (`staging.ebwiki.org`)

OpenTofu stack for [GKT-462](https://linear.app/gkt/issue/GKT-462): Railway service **ebwiki-web** in **ebwiki-maps-preview**, Doppler **`ebwiki/stg`** basic auth secrets, and Cloudflare DNS for **staging.ebwiki.org**.

This PR does **not** apply anything. Operators run **`tofu fmt`**, **`tofu validate`**, and **`tofu plan`** locally or in CI when tokens exist.

## Layout overlap with PR #4528 (GKT-1293)

| | **`infra/staging` (this change)** | **`infra/cloudflare` (#4528)** |
| --- | --- | --- |
| Purpose | Staging hostname, Railway service, Doppler staging auth, DNS CNAME | Cloudflare Access on **`/health`** only |
| Cloudflare provider | `~> 5.0`, `cloudflare_dns_record` | Same pin, Zero Trust Access resources |
| Shared inputs | `CLOUDFLARE_API_TOKEN`, `TF_VAR_cloudflare_zone_id` | Same |
| State | S3 key `staging/terraform.tfstate` | S3 key `cloudflare/terraform.tfstate` (recommended) |
| CI | `.github/workflows/infra-staging.yml` | `.github/workflows/infra-cloudflare.yml` |

Both stacks can touch **staging.ebwiki.org** (DNS here; Access path rules in #4528). Apply **staging** before or with DNS stable; Access rules are independent of the CNAME target.

## Remote state and encryption

**Recommendation:** private **S3** bucket + **DynamoDB** lock table (see `backend.hcl.example`), plus **OpenTofu state encryption** (`encryption` block in `versions.tf`).

| Item | Detail |
| --- | --- |
| Who runs **apply** | Mark or another operator with Doppler, Railway, and Cloudflare write tokens (not CI on first landing). |
| Where state lives | S3 object `staging/terraform.tfstate` in the team bucket (name in `backend.hcl.example`). |
| Encryption passphrase | **`TOFU_STATE_PASSPHRASE`** in Doppler (infra config only). Never commit or log it. |
| Why encrypt | State includes Doppler secret metadata and Railway variable material from provider reads. |

```bash
cp backend.hcl.example backend.hcl   # edit bucket/region/table
export TOFU_STATE_PASSPHRASE='…'     # from Doppler
tofu init -backend-config=backend.hcl
```

## Secrets and variables (names only)

| Name | Where | Plan scope (read-only) |
| --- | --- | --- |
| `DOPPLER_TOKEN` | Doppler service token | Project read; config/secret read (apply needs write) |
| `RAILWAY_TOKEN` | Railway account/workspace token | Project/service read |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token | Zone DNS Read |
| `TF_VAR_cloudflare_zone_id` | GitHub var or shell | Zone ID for `ebwiki.org` |
| `TOFU_STATE_PASSPHRASE` | Doppler / operator shell | Local only (state decrypt) |

Never commit token values or `terraform.tfvars` with real IDs if they are sensitive.

## Adopting existing resources

Import blocks in `imports.tf` adopt the Railway **project**, **production** environment, **ebwiki-web** service, and the **public** `*.up.railway.app` hostname. Before apply, confirm `railway_service_domain_fqdn` in Railway (Settings → Networking).

**Cloudflare:** if `staging.ebwiki.org` already exists, add:

```hcl
import {
  to = cloudflare_dns_record.staging
  id = "<zone_id>/<dns_record_id>"
}
```

**Railway custom domain:** if `staging.ebwiki.org` is already on the service, import:

```shell
tofu import railway_custom_domain.staging '<service_id>:production:staging.ebwiki.org'
```

## Doppler → Railway

OpenTofu manages **`STAGING_USERNAME`**, **`STAGING_PASSWORD`** (from `random_password`), and **`HOST`** in Doppler `ebwiki/stg`. Sync the full config to Railway with the **Doppler Railway integration** (see `scripts/doppler-railway-sync.md`).

## Commands

```bash
cd infra/staging
tofu fmt -recursive
tofu init -backend=false
export TOFU_STATE_PASSPHRASE="${TOFU_STATE_PASSPHRASE:-ci-validate-only}"
tofu validate

# Plan (credentials required)
doppler run --project ebwiki --config prd -- \
  env TF_VAR_cloudflare_zone_id="$CLOUDFLARE_ZONE_ID" \
      TOFU_STATE_PASSPHRASE="$TOFU_STATE_PASSPHRASE" \
  sh -c 'tofu init -backend-config=backend.hcl && tofu plan -input=false'
```

GitHub repo connection drift: run `scripts/railway-manual-settings.sh`.

## Rollback pointers

Revert the merge and run a planned destroy only with explicit operator approval (`prevent_destroy` guards on DNS and the Railway service). See the PR rollback section for DNS target restoration.
