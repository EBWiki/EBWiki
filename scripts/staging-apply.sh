#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  set -Eeuo pipefail
  source \"$ROOT/scripts/lib/infra-rollbar.sh\"
  INFRA_SCRIPT_NAME=staging-apply.sh
  infra_rollbar_load_token_from_stg
  trap infra_script_err_trap ERR
  \"$ROOT/scripts/infra-write-backend.sh\"
  \"$ROOT/scripts/staging-db-snapshot.sh\"
  \"$ROOT/scripts/write-staging-tfvars.sh\"
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_require_staging_tf_vars
  source \"$ROOT/scripts/lib/infra-railway-config.sh\"
  infra_railway_config_apply
  source \"$ROOT/scripts/lib/infra-staging-plan-gate.sh\"
  cd \"$ROOT/infra/staging\"
  tofu init -backend-config=backend.hcl -input=false
  infra_staging_assert_tofu_plan_destroys staging.tfplan
  tofu apply -input=false staging.tfplan
"
