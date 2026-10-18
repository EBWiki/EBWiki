#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

trap 'rc=$?; [ "$rc" -eq 0 ] || rm -f "$ROOT/infra/staging/staging.tfplan"' EXIT

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  set -Eeuo pipefail
  source \"$ROOT/scripts/lib/infra-rollbar.sh\"
  INFRA_SCRIPT_NAME=staging-plan.sh
  infra_rollbar_load_token_from_stg
  trap infra_script_err_trap ERR
  \"$ROOT/scripts/infra-write-backend.sh\"
  \"$ROOT/scripts/write-staging-tfvars.sh\"
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_require_staging_tf_vars
  source \"$ROOT/scripts/lib/infra-railway-config.sh\"
  infra_railway_config_plan
  source \"$ROOT/scripts/lib/infra-staging-plan-gate.sh\"
  cd \"$ROOT/infra/staging\"
  tofu fmt -check -recursive
  tofu init -backend-config=backend.hcl -input=false
  tofu plan -input=false -out=staging.tfplan
  infra_staging_assert_tofu_plan_destroys staging.tfplan
"
