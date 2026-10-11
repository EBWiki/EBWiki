#!/usr/bin/env bash
# Railway Infrastructure as Code plan/apply helpers for staging.
set -euo pipefail

# shellcheck source=infra-railway.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-railway.sh"

STAGING_RAILWAY_PLAN_FILE="${STAGING_RAILWAY_PLAN_FILE:-infra/staging/staging.railway-plan.json}"

infra_railway_config_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

infra_railway_config_target_env() {
  local ids project_id _service_id environment_id

  : "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set (Doppler ebwiki/infra)}"
  ids="$(infra_railway_find_project_service_env)" || return 1
  read -r project_id _service_id environment_id <<<"$ids"
  export RAILWAY_PROJECT_ID="$project_id"
  export RAILWAY_ENVIRONMENT_ID="$environment_id"
}

infra_railway_config_cli_env() {
  infra_railway_config_target_env
  export RAILWAY_API_TOKEN="$RAILWAY_TOKEN"
  unset RAILWAY_TOKEN
}

infra_railway_config_ensure_sdk() {
  local root
  root="$(infra_railway_config_root)"
  if [ ! -d "$root/node_modules/railway" ]; then
    command -v npm >/dev/null 2>&1 || {
      echo "npm is required to evaluate .railway/railway.ts (run npm ci at repo root)." >&2
      return 1
    }
    (cd "$root" && npm ci --omit=dev)
  fi
}

infra_railway_config_plan() {
  local root out
  root="$(infra_railway_config_root)"
  out="${1:-$root/$STAGING_RAILWAY_PLAN_FILE}"
  command -v railway >/dev/null 2>&1 || {
    echo "Railway CLI is required (https://docs.railway.com/develop/cli)." >&2
    return 1
  }
  infra_railway_config_ensure_sdk
  infra_railway_config_cli_env
  mkdir -p "$(dirname "$out")"
  (cd "$root" && railway config plan --out "$out")
  echo "Wrote Railway config plan: ${out#"$root"/}"
}

infra_railway_config_apply() {
  local root plan
  root="$(infra_railway_config_root)"
  plan="${1:-$root/$STAGING_RAILWAY_PLAN_FILE}"
  [ -f "$plan" ] || {
    echo "Missing Railway config plan: $plan (run make plan first)." >&2
    return 1
  }
  command -v railway >/dev/null 2>&1 || {
    echo "Railway CLI is required (https://docs.railway.com/develop/cli)." >&2
    return 1
  }
  infra_railway_config_ensure_sdk
  infra_railway_config_cli_env
  (cd "$root" && railway config apply --plan "$plan" --yes)
}
