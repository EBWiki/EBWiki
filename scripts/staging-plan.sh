#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-write-backend.sh"

doppler run --project ebwiki --config infra -- "$ROOT/scripts/write-staging-tfvars.sh"

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_require_staging_tf_vars
  cd \"$ROOT/infra/staging\" && tofu fmt -check -recursive && tofu init -backend-config=backend.hcl -input=false && tofu plan -input=false -out=staging.tfplan
"
