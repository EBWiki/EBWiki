#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/infra/bootstrap"

: "${DOPPLER_TOKEN:?Export DOPPLER_TOKEN (one-time Doppler bootstrap token or doppler login session)}"
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

echo "Migrating bootstrap state into R2 (required, same run)..."

doppler run --project ebwiki --config infra -- \
  "$ROOT/scripts/infra-write-backend.sh" "$ROOT/infra/bootstrap/backend.hcl" "bootstrap/terraform.tfstate"

# Replace local backend with remote S3 (R2) backend in versions.tf
python3 <<'PY'
from pathlib import Path
path = Path("versions.tf")
text = path.read_text()
start = text.index('  backend "local"')
end = text.index("  }", start) + len("  }")
path.write_text(text[:start] + '  backend "s3" {}' + text[end:])
PY

doppler run --project ebwiki --config infra -- \
  sh -c 'cd infra/bootstrap && tofu init -migrate-state -force-copy -backend-config=backend.hcl -input=false'

rm -f "$ROOT/infra/bootstrap/terraform.tfstate" "$ROOT/infra/bootstrap/terraform.tfstate.backup"

echo "Bootstrap complete. Secrets are in Doppler ebwiki/infra."
echo "Complete manual steps in infra/bootstrap/README.md, then: make plan && make apply"
