# Cloudflare Access for EBWiki `/health`

OpenTofu stack that puts [Cloudflare Zero Trust Access](https://developers.cloudflare.com/cloudflare-one/policies/access/) in front of **`GET /health`** on the public EBWiki hostnames. The readiness response includes database, cache, search timings, and deploy revision, so it must not be world-readable.

**`GET /up`** (Railway liveness) is **not** in this stack and stays public.

## What this protects

| URI | Access |
| --- | --- |
| `https://<host>/health` | Cloudflare Access (operator email or monitoring service token) |
| `https://<host>/up` | Unchanged (200 from origin) |

Default hostnames: **`ebwiki.org`**, **`staging.ebwiki.org`**. Override with **`health_protected_hostnames`**.

## Doppler secret names (`ebwiki/infra`)

| Secret | Use |
| --- | --- |
| **`CLOUDFLARE_API_TOKEN`** | Cloudflare provider (Access apps, policies, service tokens). Not the DNS-only **`CLOUDFLARE_DNS_API_TOKEN`**. |
| **`STATE_PASSPHRASE`** | OpenTofu state and plan encryption (`TF_VAR_state_passphrase`). |
| **`AWS_ACCESS_KEY_ID`** / **`AWS_SECRET_ACCESS_KEY`** | R2 backend for remote state (same as staging). |
| **`HEALTH_ACCESS_OPERATOR_EMAIL`** | Operator allowed by Access (`TF_VAR_allowed_operator_email`). |

Account and zone IDs live in generated **`terraform.tfvars`** (same pattern as staging). Bootstrap **`write-bootstrap-tfvars.sh`** already resolves **`cloudflare_account_id`** and **`cloudflare_zone_id`** for ebwiki.org.

After the first apply, copy the monitoring token **`client_secret`** from OpenTofu state into your uptime provider (Doppler name is up to the operator; this stack only creates the token in Cloudflare).

## Plan and apply (PR Manager machine)

```bash
cd infra/cloudflare
cp backend.hcl.example backend.hcl   # once; fill from Doppler / infra tracker
cp terraform.tfvars.example terraform.tfvars   # or use scripts/write-bootstrap-tfvars.sh fields

doppler run --project ebwiki --config infra -- \
  env CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN" \
  bash -c '
    export TF_VAR_state_passphrase="$STATE_PASSPHRASE"
    export TF_VAR_allowed_operator_email="$HEALTH_ACCESS_OPERATOR_EMAIL"
    tofu fmt -recursive
    tofu init -backend-config=backend.hcl -input=false
    tofu plan -input=false -out=cloudflare.tfplan
  '

# After review:
doppler run --project ebwiki --config infra -- \
  env CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN" \
  bash -c '
    export TF_VAR_state_passphrase="$STATE_PASSPHRASE"
    export TF_VAR_allowed_operator_email="$HEALTH_ACCESS_OPERATOR_EMAIL"
    tofu apply -input=false cloudflare.tfplan
  '
```

No automatic apply in GitHub Actions.

## Verify (production or staging host)

Unauthenticated **`/health`** should redirect to Cloudflare Access or return **401** (service auth mode), not JSON readiness:

```bash
curl -i "https://ebwiki.org/health"
curl -i "https://staging.ebwiki.org/health"
```

**`/up`** must still return **200**:

```bash
curl -i "https://ebwiki.org/up"
curl -i "https://staging.ebwiki.org/up"
```

Monitoring checks use **`CF-Access-Client-Id`** and **`CF-Access-Client-Secret`** from the service token created here.

## Rollback

- **Targeted destroy:** `tofu destroy -target=cloudflare_zero_trust_access_application.health` (and policy or token targets if you want a full revert).
- **Git revert:** merge a PR that removes this stack, then apply so Access rules disappear.

## Security notes

- Secrets never belong in git. **`CLOUDFLARE_API_TOKEN`** and the monitoring **`client_secret`** stay in Doppler or the secret store.
- This is edge protection only. A follow-up can add Rails-side refusal of **`/health`** without a shared secret (defense in depth).
- Scope the API token to Zero Trust Access and service tokens on the ebwiki.org account, not account-wide DNS.
