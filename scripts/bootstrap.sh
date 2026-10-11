#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/infra/bootstrap"

: "${DOPPLER_TOKEN:?Export DOPPLER_TOKEN (Doppler token with write access to create ebwiki/infra)}"
: "${TF_VAR_bootstrap_state_passphrase:?Export TF_VAR_bootstrap_state_passphrase (16+ characters)}"
: "${TF_VAR_cloudflare_bootstrap_api_token:?Export TF_VAR_cloudflare_bootstrap_api_token}"

if [ ! -f terraform.tfvars ]; then
  echo "Create infra/bootstrap/terraform.tfvars from terraform.tfvars.example (account and zone IDs)."
  exit 1
fi

command -v tofu >/dev/null 2>&1 || { echo "Install OpenTofu 1.10+ (https://opentofu.org/docs/intro/install)"; exit 1; }

tofu fmt -recursive
tofu init -input=false
tofu plan -input=false -out=bootstrap.tfplan
tofu apply -input=false bootstrap.tfplan
rm -f bootstrap.tfplan

echo "Bootstrap apply complete. Secrets are in Doppler ebwiki/infra."
echo "Add RAILWAY_TOKEN to ebwiki/infra manually, then run: make plan && make apply"
