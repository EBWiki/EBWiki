#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/infra/bootstrap"

doppler me >/dev/null 2>&1 || {
  echo "Run doppler login or export DOPPLER_TOKEN for bootstrap."
  exit 1
}

# A local state file means an earlier run stopped partway: resume it instead of refusing.
if [ ! -f terraform.tfstate ] && \
  doppler secrets get R2_BUCKET_NAME --project ebwiki --config infra --plain >/dev/null 2>&1; then
  echo "Bootstrap already ran. Its state is in R2 under bootstrap/terraform.tfstate."
  exit 1
fi

: "${TF_VAR_bootstrap_state_passphrase:?Export TF_VAR_bootstrap_state_passphrase (16+ characters)}"
: "${TF_VAR_cloudflare_bootstrap_api_token:?Export TF_VAR_cloudflare_bootstrap_api_token}"

if [ ! -f terraform.tfvars ]; then
  echo "Create infra/bootstrap/terraform.tfvars from terraform.tfvars.example (account and zone IDs)."
  exit 1
fi

command -v tofu >/dev/null 2>&1 || { echo "Install OpenTofu 1.10+ (https://opentofu.org/docs/intro/install)"; exit 1; }

cat > backend_override.tf <<'TF'
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
TF

tofu init -input=false -reconfigure
tofu plan -input=false -out=bootstrap.tfplan
tofu apply -input=false bootstrap.tfplan
rm -f bootstrap.tfplan

echo "Migrating bootstrap state into R2 (required, same run)..."

doppler run --project ebwiki --config infra -- \
  "$ROOT/scripts/infra-write-backend.sh" "$ROOT/infra/bootstrap/backend.hcl" "bootstrap/terraform.tfstate"

rm -f backend_override.tf

doppler run --project ebwiki --config infra -- \
  tofu init -migrate-state -force-copy -backend-config=backend.hcl -input=false

rm -f terraform.tfstate terraform.tfstate.backup

echo "Bootstrap complete. Secrets are in Doppler ebwiki/infra."
echo "Complete manual steps in infra/bootstrap/README.md, then: make plan && make apply"
