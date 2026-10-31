#!/usr/bin/env bash
# GitHub autodeploy trigger checks for the staging service.
#   plan:  read only. Fails closed when the trigger is missing or points at another repo or branch.
#   apply: turns on Wait for CI (checkSuites) with deploymentTriggerUpdate and reads it back.
set -euo pipefail

# shellcheck source=infra-railway.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-railway.sh"
# shellcheck source=infra-logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-logging.sh"

RAILWAY_DEPLOY_REPO="${RAILWAY_DEPLOY_REPO:-EBWiki/EBWiki}"
RAILWAY_DEPLOY_BRANCH="${RAILWAY_DEPLOY_BRANCH:-main}"

# Prints every trigger node for the staging service as one JSON array.
infra_railway_deployment_triggers() {
  local project_id="$1" environment_id="$2" service_id="$3"
  local query vars payload

  query='query($projectId: String!, $environmentId: String!, $serviceId: String!) {
    deploymentTriggers(projectId: $projectId, environmentId: $environmentId, serviceId: $serviceId) {
      edges { node { id branch repository checkSuites provider } }
    }
  }'
  vars="$(jq -n --arg p "$project_id" --arg e "$environment_id" --arg s "$service_id" \
    '{projectId: $p, environmentId: $e, serviceId: $s}')"
  payload="$(infra_railway_gql "$query" "$vars")" \
    || die railway_deploy_trigger "could not list deployment triggers"
  jq -e '((.errors // []) | length == 0) and (.data.deploymentTriggers.edges | type == "array")' \
    <<<"$payload" >/dev/null \
    || die railway_deploy_trigger "could not list deployment triggers"
  jq -c '[.data.deploymentTriggers.edges[].node]' <<<"$payload"
}

# Prints the GitHub trigger for RAILWAY_DEPLOY_REPO@RAILWAY_DEPLOY_BRANCH, or dies.
infra_railway_main_github_trigger() {
  local project_id="$1" environment_id="$2" service_id="$3"
  local nodes trigger

  nodes="$(infra_railway_deployment_triggers "$project_id" "$environment_id" "$service_id")" || return 1
  trigger="$(jq -c --arg repo "$RAILWAY_DEPLOY_REPO" --arg branch "$RAILWAY_DEPLOY_BRANCH" '
    [.[] | select(.provider == "github" and .branch == $branch and .repository == $repo)][0] // empty
  ' <<<"$nodes")"
  if [[ -z "$trigger" ]]; then
    if [[ "$(jq 'length' <<<"$nodes")" -eq 0 ]]; then
      die railway_deploy_trigger_missing \
        "GitHub autodeploy trigger missing; connect ${RAILWAY_DEPLOY_REPO} on ${RAILWAY_DEPLOY_BRANCH} in Railway Source (GitHub App)"
    fi
    die railway_deploy_trigger_repo \
      "GitHub autodeploy trigger is not set to ${RAILWAY_DEPLOY_REPO}@${RAILWAY_DEPLOY_BRANCH}"
  fi
  printf '%s\n' "$trigger"
}

infra_railway_staging_ids() {
  local ids
  ids="$(infra_railway_find_project_service_env)" || die railway_deploy_trigger "could not resolve Railway staging ids"
  printf '%s\n' "$ids"
}

# Read only. Used by make plan.
infra_railway_assert_deployment_trigger() {
  local ids project_id service_id environment_id trigger trigger_id suites

  ids="$(infra_railway_staging_ids)" || return 1
  read -r project_id service_id environment_id <<<"$ids"
  trigger="$(infra_railway_main_github_trigger "$project_id" "$environment_id" "$service_id")" || return 1
  trigger_id="$(jq -r '.id' <<<"$trigger")"
  suites="$(jq -r '.checkSuites' <<<"$trigger")"
  if [[ "$suites" != true ]]; then
    log_json warn railway_deploy_trigger_pending \
      "trigger ${trigger_id} has checkSuites=${suites}; make apply turns on Wait for CI"
    return 0
  fi
  log_json info railway_deploy_trigger_ok \
    "trigger ${trigger_id} is ${RAILWAY_DEPLOY_REPO}@${RAILWAY_DEPLOY_BRANCH} with checkSuites=true"
}

# Idempotent. Used by make apply: no write when checkSuites is already true.
infra_railway_ensure_deployment_trigger() {
  local ids project_id service_id environment_id trigger trigger_id mutation vars payload

  ids="$(infra_railway_staging_ids)" || return 1
  read -r project_id service_id environment_id <<<"$ids"
  trigger="$(infra_railway_main_github_trigger "$project_id" "$environment_id" "$service_id")" || return 1
  trigger_id="$(jq -r '.id' <<<"$trigger")"
  if [[ "$(jq -r '.checkSuites' <<<"$trigger")" == true ]]; then
    log_json info railway_deploy_trigger_ok "trigger ${trigger_id} already has checkSuites=true"
    return 0
  fi

  mutation='mutation($id: String!, $input: DeploymentTriggerUpdateInput!) {
    deploymentTriggerUpdate(id: $id, input: $input) { id checkSuites }
  }'
  vars="$(jq -n --arg id "$trigger_id" '{id: $id, input: {checkSuites: true}}')"
  payload="$(infra_railway_gql "$mutation" "$vars")" \
    || die railway_deploy_trigger "deploymentTriggerUpdate request failed"
  jq -e '((.errors // []) | length == 0) and .data.deploymentTriggerUpdate.checkSuites == true' \
    <<<"$payload" >/dev/null \
    || die railway_deploy_trigger "deploymentTriggerUpdate did not enable checkSuites"

  trigger="$(infra_railway_main_github_trigger "$project_id" "$environment_id" "$service_id")" || return 1
  [[ "$(jq -r '.id' <<<"$trigger")" == "$trigger_id" && "$(jq -r '.checkSuites' <<<"$trigger")" == true ]] \
    || die railway_deploy_trigger "checkSuites read-back is not true after update"
  log_json info railway_deploy_trigger_enabled "enabled checkSuites on trigger ${trigger_id}"
}
