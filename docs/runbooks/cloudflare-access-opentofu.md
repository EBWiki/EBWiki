# Runbook: Cloudflare Access for a path (OpenTofu)

Use this when a Rails (or other) route must stay on the public hostname but should not be world-readable—without app middleware or dashboard-only changes.

## When to use

- The path is already on a Cloudflare-proxied host (orange cloud).
- You need allowlists (email, service token) and audit logs at the edge.
- Railway or another host still needs a separate open probe (e.g. `/up`).

## Pattern (EBWiki `/health`)

1. **Scope the URL** — Access application domain is `hostname/path` (e.g. `ebwiki.org/health`). Do not put `/up` in the application.
2. **Two policies on one app** (OR between policies):
   - **Operator**: `decision = allow`, `include.email`.
   - **Monitoring**: `decision = non_identity`, `include.service_token` pointing at a `cloudflare_zero_trust_access_service_token`.
3. **Service token** — Create in OpenTofu; store `client_id` / `client_secret` in Doppler after apply. Monitors send `CF-Access-Client-Id` and `CF-Access-Client-Secret`.
4. **Secrets** — `CLOUDFLARE_API_TOKEN` only via environment (Doppler). Pin the `cloudflare/cloudflare` provider in `versions.tf`.
5. **CI** — `tofu fmt -check`, `init -backend=false`, `validate`, optional `plan` when the token is present.
6. **Apply** — Human after review; never from CI on first landing.
7. **Rollback** — `tofu destroy` on the four resources (app, two policies, service token) or revert the PR and destroy.

## Verify production

| Check | Expected |
|-------|----------|
| `GET https://example.org/health` (no Access) | Blocked or Access login |
| `GET https://example.org/health` (token headers) | 200 JSON from app |
| `GET https://example.org/up` | 200, no Access |

## Copy to skills repo

This file is the canonical copy in EBWiki. Mirror or link from `mnyon-grandkru/skills` under infrastructure / Cloudflare Access.
