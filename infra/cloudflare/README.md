# Cloudflare infrastructure (OpenTofu)

OpenTofu configs for EBWiki at the Cloudflare edge. Today this stack protects the **`/health`** readiness page with [Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/policies/access/) while leaving **`/up`** open for Railway health checks.

## Secrets and variables

| Name | Where | Purpose |
|------|--------|---------|
| `CLOUDFLARE_API_TOKEN` | Doppler → shell / GitHub Actions secret | Provider auth. Needs Zone + Access write for `ebwiki.org`. |
| `CLOUDFLARE_ACCOUNT_ID` | Doppler → `TF_VAR_cloudflare_account_id` | Zero Trust account. |
| `CLOUDFLARE_ZONE_ID` | Doppler → `TF_VAR_cloudflare_zone_id` | `ebwiki.org` zone. |

Never commit token values or `terraform.tfvars` with real IDs.

## Local commands (plan only until reviewed)

```bash
cd infra/cloudflare
doppler run --project ebwiki --config prd -- \
  env TF_VAR_cloudflare_account_id="$CLOUDFLARE_ACCOUNT_ID" \
      TF_VAR_cloudflare_zone_id="$CLOUDFLARE_ZONE_ID" \
  sh -c 'tofu init && tofu plan'
```

Apply is manual after PR review:

```bash
doppler run --project ebwiki --config prd -- \
  env TF_VAR_cloudflare_account_id="$CLOUDFLARE_ACCOUNT_ID" \
      TF_VAR_cloudflare_zone_id="$CLOUDFLARE_ZONE_ID" \
  sh -c 'tofu apply'
```

After apply, copy the sensitive `health_monitor_client_secret` output into Doppler for monitors (one time).

## Monitoring `/health`

Uptime Kuma, Gatus, or similar can probe `https://ebwiki.org/health` with Access service auth headers:

- `CF-Access-Client-Id`: from `health_monitor_client_id` output / Doppler
- `CF-Access-Client-Secret`: from Doppler (never in the repo)

## Rollback

```bash
tofu destroy -target=cloudflare_zero_trust_access_application.health \
  -target=cloudflare_zero_trust_access_policy.health_operator \
  -target=cloudflare_zero_trust_access_policy.health_monitoring \
  -target=cloudflare_zero_trust_access_service_token.health_monitor
```

Or revert the merge and destroy the stack.

See also `docs/runbooks/cloudflare-access-opentofu.md`.
