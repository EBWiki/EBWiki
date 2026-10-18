#!/usr/bin/env bash
# Railway Infrastructure as Code plan/apply helpers for staging.
set -euo pipefail

# shellcheck source=infra-railway.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-railway.sh"
# shellcheck source=infra-railway-token-preflight.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-railway-token-preflight.sh"
# shellcheck source=infra-railway-deploy-trigger.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-railway-deploy-trigger.sh"

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

infra_railway_config_run_cli() {
  local token="$1"
  shift
  (
    unset RAILWAY_TOKEN
    export RAILWAY_API_TOKEN="$token"
    export RAILWAY_PROJECT_ID RAILWAY_ENVIRONMENT_ID
    "$@"
  )
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

# Returns the number of destroys in a pinned Railway config plan (0 when none).
infra_railway_config_plan_destroy_count() {
  local plan_file="$1"
  local summary destroys from_kinds

  summary="$(jq -r '
    .. | strings | select(test("^Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy$"))
  ' "$plan_file" 2>/dev/null | head -1)"
  if [ -n "$summary" ]; then
    destroys="$(printf '%s' "$summary" | sed -nE 's/^Plan: [0-9]+ to add, [0-9]+ to change, ([0-9]+) to destroy$/\1/p')"
    if [ -n "$destroys" ]; then
      printf '%s' "$destroys"
      return 0
    fi
  fi

  destroys="$(jq -r '
    (
      .summary // .plan.summary // .display.summary // empty
    ) as $s |
    if ($s | type) == "string" and ($s | test(", [0-9]+ to destroy")) then
      ($s | capture(", (?<n>[0-9]+) to destroy$").n)
    else
      (.stats.destroy // .planStats.destroy // .destroyCount // 0)
    end
  ' "$plan_file" 2>/dev/null)"
  if [ -n "$destroys" ] && [ "$destroys" != "null" ]; then
    printf '%s' "$destroys"
    return 0
  fi

  from_kinds="$(jq -r '
    [
      .. | objects | select(has("kind")) | .kind
      | select(test("delete|destroy|remove"; "i"))
    ] | length
  ' "$plan_file" 2>/dev/null)"
  if [ "${from_kinds:-0}" != "0" ]; then
    printf '%s' "$from_kinds"
    return 0
  fi

  from_changeset="$(jq -r '
    [
      .changeSet.changes[]?
      | select(.severity == "destructive" or (.kind | test("\\.(delete|destroy)$")))
    ] | length
  ' "$plan_file" 2>/dev/null)"
  printf '%s' "${from_changeset:-0}"
}

infra_railway_config_assert_plan_no_destructive() {
  local plan_file="$1"
  local destroys

  destroys="$(infra_railway_config_plan_destroy_count "$plan_file")"
  if [ "${destroys:-0}" != "0" ]; then
    echo "Railway config plan would destroy or delete ${destroys} resource(s). Refusing to continue." >&2
    echo "Review ${plan_file} and fix .railway/railway.ts (preserve every live variable name; no destructive changes)." >&2
    return 1
  fi
  if ! jq -e '
    ([.changeSet.changes[]?
      | select(.severity == "destructive" or (.kind | test("\\.(delete|destroy)$")))] | length) == 0
  ' "$plan_file" >/dev/null 2>&1; then
    echo "Railway config plan has destructive changeSet entries. Refusing to continue." >&2
    return 1
  fi
}

infra_railway_config_plan() {
  local root out token
  root="$(infra_railway_config_root)"
  out="${1:-$root/$STAGING_RAILWAY_PLAN_FILE}"
  command -v railway >/dev/null 2>&1 || {
    echo "Railway CLI is required (https://docs.railway.com/develop/cli)." >&2
    return 1
  }
  infra_railway_assert_workspace_or_account_token || return 1
  infra_railway_assert_deployment_trigger || return 1
  infra_railway_config_ensure_sdk
  infra_railway_config_target_env
  token="$RAILWAY_TOKEN"
  mkdir -p "$(dirname "$out")"
  (cd "$root" && infra_railway_config_run_cli "$token" railway config plan --out "$out")
  infra_railway_config_assert_plan_no_destructive "$out"
  echo "Wrote Railway config plan: ${out#"$root"/}"
}

infra_railway_config_apply() {
  local root plan token
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
  infra_railway_config_assert_plan_no_destructive "$plan" || return 1
  infra_railway_assert_workspace_or_account_token || return 1
  infra_railway_ensure_deployment_trigger || return 1
  infra_railway_config_ensure_sdk
  infra_railway_config_target_env
  token="$RAILWAY_TOKEN"
  (cd "$root" && infra_railway_config_run_cli "$token" railway config apply --plan "$plan" --yes)
}
