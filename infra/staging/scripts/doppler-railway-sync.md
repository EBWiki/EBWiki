# Doppler config `ebwiki/stg` → Railway `ebwiki-web`

OpenTofu writes **`STAGING_USERNAME`**, **`STAGING_PASSWORD`**, and **`HOST`** into Doppler (`infra/staging/doppler.tf`). The rest of the real staging config already lives in `ebwiki/stg` (see `docs/STAGING_RAILWAY.md`).

## Recommended: Doppler Railway integration

Use Doppler’s native **Railway** integration instead of copying secrets into `railway_variable` resources in Terraform.

Why this is cleaner:

- One source of truth: Doppler `stg` holds every name Railway needs.
- No duplicate secret values in OpenTofu state beyond what Doppler resources already require.
- Adding a key in Doppler does not require a Terraform change for Railway.

One-time setup (Mark or operator with Doppler + Railway admin):

1. Doppler → **Integrations** → **Railway** → connect the Railway account.
2. Map **project** `ebwiki`, **config** `stg`, to Railway **project** `ebwiki-maps-preview`, **service** `ebwiki-web`, **environment** `production`.
3. Enable automatic sync on config changes.

After OpenTofu apply creates or rotates `STAGING_PASSWORD`, the integration pushes it to Railway and triggers a redeploy.

## Alternative (not used in this stack)

Per-secret `railway_variable` resources wired from `doppler_secret` values. That duplicates material in state and causes a redeploy per Terraform secret change. Use only if the integration is unavailable.
