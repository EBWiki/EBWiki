#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STAGING_PLAN="$ROOT/infra/staging/staging.tfplan"
trap 'rm -f "$STAGING_PLAN"' EXIT

echo "Staging apply runs OpenTofu and Railway config against live staging. Confirm with Mark before continuing." >&2
read -r -p "Type apply-staging to continue: " confirm
if [ "$confirm" != apply-staging ]; then
  echo "Aborted."
  exit 1
fi

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-with-tf-vars.sh" bash -c "
  set -Eeuo pipefail
  umask 077
  source \"$ROOT/scripts/lib/infra-rollbar.sh\"
  INFRA_SCRIPT_NAME=staging-apply.sh
  infra_rollbar_load_token_from_stg
  trap infra_script_err_trap ERR
  \"$ROOT/scripts/infra-write-backend.sh\"
  source \"$ROOT/scripts/lib/infra-export-tf-vars.sh\"
  infra_require_staging_tf_vars
  source \"$ROOT/scripts/lib/infra-railway-config.sh\"
  [ -f \"$STAGING_PLAN\" ] || { echo \"Missing OpenTofu plan: $STAGING_PLAN (run make plan first).\" >&2; exit 1; }
  \"$ROOT/scripts/staging-dns-preflight.sh\" --plan \"$STAGING_PLAN\"
  \"$ROOT/scripts/staging-db-snapshot.sh\"
  infra_railway_config_apply
  source \"$ROOT/scripts/lib/infra-staging-plan-gate.sh\"
  cd \"$ROOT/infra/staging\"
  tofu init -backend-config=backend.hcl -input=false
  infra_staging_assert_tofu_plan_destroys \"$STAGING_PLAN\"
  infra_staging_assert_tofu_plan_cloudflare_cname_only \"$STAGING_PLAN\"
  \"$ROOT/scripts/staging-dns-preflight.sh\" --plan \"$STAGING_PLAN\"
  tofu apply -input=false \"$STAGING_PLAN\"
"
