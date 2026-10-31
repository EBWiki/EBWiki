#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -z "${BOOTSTRAP_MAKER_ENV_LOADED:-}" ]; then
  export BOOTSTRAP_MAKER_ENV_LOADED=1
  exec doppler run --project grandkru --config prd -- \
    "$ROOT/scripts/bootstrap.sh" "$@"
fi

cd "$ROOT/infra/bootstrap"

export DOPPLER_TOKEN="${DOPPLER_TOKEN_MAKER:?Set DOPPLER_TOKEN_MAKER in grandkru/prd}"
export TF_VAR_cloudflare_token_maker="${CLOUDFLARE_TOKEN_MAKER:?Set CLOUDFLARE_TOKEN_MAKER in grandkru/prd}"
export TF_VAR_railway_api_token="${RAILWAY_API_TOKEN:?Set RAILWAY_API_TOKEN in grandkru/prd}"
export TF_VAR_rollbar_account_api_key="${ROLLBAR_ACCOUNT_API_KEY:?Set ROLLBAR_ACCOUNT_API_KEY in grandkru/prd}"
export CLOUDFLARE_ZONE_READ_API_TOKEN="${CLOUDFLARE_ZONE_READ_API_TOKEN:?Set CLOUDFLARE_ZONE_READ_API_TOKEN in grandkru/prd}"

# A local state file means an earlier run stopped partway: resume it instead of refusing.
if [ ! -f terraform.tfstate ] && \
  doppler secrets get R2_BUCKET_NAME --project ebwiki --config infra --plain >/dev/null 2>&1; then
  echo "Bootstrap already ran. Its state is in R2 under bootstrap/terraform.tfstate."
  exit 1
fi

: "${TF_VAR_bootstrap_state_passphrase:?Export TF_VAR_bootstrap_state_passphrase (16+ characters)}"

"$ROOT/scripts/write-bootstrap-tfvars.sh"

command -v tofu >/dev/null 2>&1 || { echo "Install OpenTofu 1.10+ (https://opentofu.org/docs/intro/install)"; exit 1; }

cat > backend_override.tf <<'TF'
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
TF

tofu init -input=false -reconfigure

BOOTSTRAP_STAGE2_EXCLUDES=(
  -exclude=cloudflare_r2_bucket.opentofu_state
  -exclude=cloudflare_api_token.r2_state
  -exclude=doppler_secret.aws_access_key_id
  -exclude=doppler_secret.aws_secret_access_key
  -exclude=doppler_secret.r2_bucket_name
)

echo "Bootstrap stage 1 (tokens and Doppler infra)..."
tofu plan -input=false "${BOOTSTRAP_STAGE2_EXCLUDES[@]}" -out=bootstrap-stage1.tfplan
tofu apply -input=false bootstrap-stage1.tfplan
rm -f bootstrap-stage1.tfplan

echo "Bootstrap stage 2 (R2 bucket and state credentials; mints a new R2 admin token if state has none)..."
tofu plan -input=false -out=bootstrap-stage2.tfplan
tofu apply -input=false bootstrap-stage2.tfplan
rm -f bootstrap-stage2.tfplan

echo "Dropping ephemeral R2 admin token and bucket from bootstrap state..."
# shellcheck source=lib/infra-curl.sh
source "$ROOT/scripts/lib/infra-curl.sh"
# shellcheck source=lib/infra-tofu-state.sh
source "$ROOT/scripts/lib/infra-tofu-state.sh"
r2_admin_token_id="$(tofu state show -json cloudflare_api_token.r2_admin \
  | infra_tofu_state_show_json_resource_id)"
[ -n "$r2_admin_token_id" ] || {
  echo "Could not read the R2 admin token id from state; not removing it." >&2
  exit 1
}
delete_resp="$(infra_curl_delete \
  "https://api.cloudflare.com/client/v4/user/tokens/${r2_admin_token_id}" \
  "${CLOUDFLARE_TOKEN_MAKER}")"
echo "$delete_resp" | jq -e '.success' >/dev/null \
  || { echo "Failed to delete ephemeral R2 admin API token in Cloudflare." >&2; exit 1; }
tofu state rm cloudflare_api_token.r2_admin
tofu state rm cloudflare_r2_bucket.opentofu_state

echo "Migrating bootstrap state into R2 (required, same run)..."

doppler run --project ebwiki --config infra -- \
  "$ROOT/scripts/infra-write-backend.sh" "$ROOT/infra/bootstrap/backend.hcl" "bootstrap/terraform.tfstate"

rm -f backend_override.tf

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_require_bootstrap_migrate_tf_vars
  cd \"$ROOT/infra/bootstrap\" && tofu init -migrate-state -force-copy -backend-config=backend.hcl -input=false
"

rm -f terraform.tfstate terraform.tfstate.backup

echo "Bootstrap complete. Secrets are in Doppler ebwiki/infra."
echo "Run make plan && make apply when ready (see infra/staging/README.md)."
