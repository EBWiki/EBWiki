# Staging host OpenTofu (`staging.ebwiki.org`)

OpenTofu stack for [GKT-462](https://linear.app/gkt/issue/GKT-462). Adopts the existing Railway **ebwiki** project and service, points **staging.ebwiki.org** at Railway, and wires a read-only **DOPPLER_TOKEN** for runtime config. **No apply in CI.** Mark runs **apply** locally with Doppler **`ebwiki/infra`**.

## Behavior change (name before apply)

Live staging today runs Docker image **`ebwiki/ebwiki:184`** with a custom pre-deploy **`db:prepare`**. This stack sets **`source_repo`** to **EBWiki/EBWiki** on **`main`** with **`railway.toml`**, so pre-deploy becomes **`bash release-tasks.sh`** (**`db:migrate` only**). That switch must appear in deploy, test, and rollback plans. Grant the Railway GitHub app access to **EBWiki/EBWiki** before apply.

## Overlap with PR #4528 (GKT-1293)

| | **`infra/staging` (this change)** | **`infra/cloudflare` (#4528)** |
| --- | --- | --- |
| Purpose | Staging DNS, Railway service, Doppler runtime token | Cloudflare Access on **`/health`** |
| Cloudflare token | **`CLOUDFLARE_DNS_API_TOKEN`** (Zone DNS only) | **`CLOUDFLARE_ACCESS_API_TOKEN`** (Access + service tokens) |
| Shared input | **`CLOUDFLARE_ZONE_ID`** | Same |
| State key | `staging/terraform.tfstate` on R2 | Use the same R2 bucket with key `cloudflare/terraform.tfstate` |

Apply **this stack first**, then **#4528**. Access rules that mention **staging.ebwiki.org** only bite after DNS points at Railway.

## Remote state (Cloudflare R2)

Use a **private R2 bucket** and **`use_lockfile = true`** (OpenTofu **1.10+**). See `backend.hcl.example` for shape only. Bucket name, account ID, and R2 API credentials live in **Doppler `ebwiki/infra`** or the private GKT-462 tracker, not in git.

| Item | Detail |
| --- | --- |
| Who runs **apply** | Mark (local only; **RAILWAY_TOKEN** never in GitHub Actions). |
| Encryption | **`TF_VAR_state_passphrase`** (16+ characters) in Doppler **`ebwiki/infra`**. State and saved plans are **enforced** encrypted. |
| Stale lock | OpenTofu [#4405](https://github.com/opentofu/opentofu/issues/4405): after a failed run, **`tofu force-unlock <id>`** may be needed. |

## Secrets and variables (names only)

| Name | Where | Notes |
| --- | --- | --- |
| **`TF_VAR_state_passphrase`** | Doppler **`ebwiki/infra`** | State/plan encryption |
| **`RAILWAY_TOKEN`** | Doppler **`ebwiki/infra`** | Apply local only |
| **`DOPPLER_TOKEN`** | Doppler **`ebwiki/infra`** | Apply token with write on **`stg`** for OpenTofu |
| **`TF_VAR_cloudflare_dns_api_token`** | Doppler **`ebwiki/infra`** | Zone DNS Edit (apply); Read for optional CI plan |
| R2 **`AWS_ACCESS_KEY_ID`** / **`AWS_SECRET_ACCESS_KEY`** | Doppler **`ebwiki/infra`** | R2 S3-compatible API for backend |
| **`TF_VAR_railway_project_id`**, **`TF_VAR_railway_service_id`**, **`TF_VAR_railway_service_domain_fqdn`**, **`TF_VAR_cloudflare_staging_dns_record_id`** | GitHub repo variables or local **`terraform.tfvars`** | Not committed |
| **`CLOUDFLARE_ZONE_ID`** | GitHub repo variable | Zone ID for **ebwiki.org** |

Confirm Cloudflare zone SSL mode is **Full** (not Flexible) for proxied Railway.

## Doppler secrets

OpenTofu **adopts** existing **`STAGING_USERNAME`** and **`STAGING_PASSWORD`** in **`ebwiki/stg`** (`ignore_changes` on values). It sets **`HOST`** to **staging.ebwiki.org**. It does **not** rotate the staging password.

Runtime: see `scripts/doppler-at-runtime.md`.

## Adopting live resources

Import blocks in **`imports.tf`** adopt Railway project, environment, service, public **`*.up.railway.app`** domain, **staging.ebwiki.org** custom domain, Cloudflare **staging** CNAME, and Doppler auth secret names. Set IDs via **`terraform.tfvars`** (gitignored) or **`TF_VAR_*`** before **`tofu plan`**.

## Commands

```bash
cd infra/staging
tofu fmt -recursive

doppler run --project ebwiki --config infra -- \
  sh -c 'tofu init -backend-config=backend.hcl && tofu validate && tofu plan -input=false'
```

**Apply** (Mark, same Doppler **`infra`** config, after review):

```bash
doppler run --project ebwiki --config infra -- \
  sh -c 'tofu apply -input=false'
```

GitHub repo drift: **`scripts/railway-manual-settings.sh`**.

## Rollback pointers

Record the current Render CNAME target and image tag **`ebwiki/ebwiki:184`** in the private tracker before cutover. Revert DNS to that target to restore the old host. To restore the image, redeploy tag **184** in Railway or set **`source_image`** back in a follow-up change.
