#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "GitHub apply writes release-smoke environment secrets. Confirm with Mark before continuing." >&2
read -r -p "Type apply-github to continue: " confirm
if [ "$confirm" != apply-github ]; then
  echo "Aborted."
  exit 1
fi

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-write-backend.sh" \
  "$ROOT/infra/github/backend.hcl" "github/terraform.tfstate"

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_export_github_smoke_secrets_from_stg
  infra_require_github_tf_vars
  cd \"$ROOT/infra/github\" && tofu init -backend-config=backend.hcl -input=false && tofu apply -input=false github.tfplan
"
