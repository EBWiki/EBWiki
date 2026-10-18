#!/usr/bin/env bash
# Read-only GitHub autodeploy trigger checks and idempotent Wait for CI (checkSuites).
set -euo pipefail

# shellcheck source=infra-railway.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-railway.sh"
# shellcheck source=infra-logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-logging.sh"

RAILWAY_DEPLOY_REPO="${RAILWAY_DEPLOY_REPO:-EBWiki/EBWiki}"
RAILWAY_DEPLOY_BRANCH="${RAILWAY_DEPLOY_BRANCH:-main}"

infra_railway_deployment_trigger_nodes() {
  local project_id="$1" environment_id="$2" service_id="$3"
  local query vars payload

  query='query($projectId: String!, $environmentId: String!, $serviceId: String!) {
    deploymentTriggers(projectId: $projectId, environmentId: $environmentId, serviceId: $serviceId) {
      edges { node { id branch repository checkSuites provider } }
    }
  }'
  vars="$(jq -n --arg p "$project_id" --arg e "$environment_id" --arg s "$service_id" \
    '{projectId: $p, environmentId: $e, serviceId: $s}')"
  payload="$(infra_railway_gql "$query" "$vars")"
  echo "$payload" | jq -e '.data.deploymentTriggers.edges' >/dev/null \
    || die railway_deploy_trigger "could not list deployment triggers"
  echo "$payload" | jq -c '.data.deploymentTriggers.edges[].node'
}

infra_railway_pick_main_github_trigger() {
  jq -s --arg repo "$RAILWAY_DEPLOY_REPO" --arg branch "$RAILWAY_DEPLOY_BRANCH" '
    [.[] | select(.provider == "github" and .branch == $branch and .repository == $repo)][0] // empty
  '
}

infra_railway_read_trigger_check_suites() {
  local trigger_id="$1"
  local query payload

  query='query($id: String!) { deploymentTrigger(id: $id) { id checkSuites branch repository } }'
  payload="$(infra_railway_gql "$query" "$(jq -n --arg id "$trigger_id" '{id: $id}')")"
  echo "$payload" | jq -e '.data.deploymentTrigger.checkSuites' >/dev/null \
    || die railway_deploy_trigger "read-back failed for trigger ${trigger_id}"
  echo "$payload" | jq -r '.data.deploymentTrigger.checkSuites'
}

infra_railway_update_trigger_check_suites() {
  local trigger_id="$1"
  local mutation vars payload updated

  mutation='mutation($id: String!, $input: DeploymentTriggerUpdateInput!) {
    deploymentTriggerUpdate(id: $id, input: $input) { id checkSuites }
  }'
  vars="$(jq -n --arg id "$trigger_id" '{id: $id, input: {checkSuites: true}}')"
  payload="$(infra_railway_gql "$mutation" "$vars")"
  echo "$payload" | jq -e '.data.deploymentTriggerUpdate.checkSuites == true' >/dev/null \
    || die railway_deploy_trigger "deploymentTriggerUpdate did not enable checkSuites"
  updated="$(infra_railway_read_trigger_check_suites "$trigger_id")"
  [[ "$updated" == true ]] || die railway_deploy_trigger "checkSuites read-back is not true after update"
  log_json info railway_deploy_trigger "enabled checkSuites on trigger ${trigger_id}"
}

infra_railway_preflight_github_autodeploy() {
  local ids project_id service_id environment_id all_nodes count trigger_json trigger_id suites

  infra_railway_assert_workspace_or_account_token
  ids="$(infra_railway_find_project_service_env)" || return 1
  read -r project_id service_id environment_id <<<"$ids"
  all_nodes="$(infra_railway_deployment_trigger_nodes "$project_id" "$environment_id" "$service_id")"
  count="$(jq -s 'length' <<<"$all_nodes")"
  trigger_json="$(jq -s --arg repo "$RAILWAY_DEPLOY_REPO" --arg branch "$RAILWAY_DEPLOY_BRANCH" '
    [.[] | select(.provider == "github" and .branch == $branch and .repository == $repo)][0] // empty
  ' <<<"$all_nodes")"

  if [[ -z "$trigger_json" ]]; then
    if [[ "$count" -eq 0 ]]; then
      die railway_deploy_trigger_missing \
        "GitHub autodeploy trigger missing; connect EBWiki/EBWiki on main in Railway Source (GitHub App)"
    fi
    die railway_deploy_trigger_repo \
      "GitHub autodeploy trigger is not set to ${RAILWAY_DEPLOY_REPO}@${RAILWAY_DEPLOY_BRANCH}"
  fi

  trigger_id="$(jq -r '.id' <<<"$trigger_json")"
  suites="$(jq -r '.checkSuites' <<<"$trigger_json")"
  if [[ "$suites" != true ]]; then
    die railway_deploy_trigger_disabled \
      "GitHub autodeploy trigger ${trigger_id} has checkSuites=${suites}; run make apply to enable Wait for CI"
  fi
  log_json info railway_deploy_trigger_ok "trigger ${trigger_id} is ${RAILWAY_DEPLOY_REPO}@${RAILWAY_DEPLOY_BRANCH} with checkSuites=true"
}

infra_railway_assert_deployment_trigger() {
  infra_railway_preflight_github_autodeploy
}

infra_railway_ensure_deployment_trigger() {
  local ids project_id service_id environment_id all_nodes trigger_json trigger_id suites

  infra_railway_assert_workspace_or_account_token
  ids="$(infra_railway_find_project_service_env)" || return 1
  read -r project_id service_id environment_id <<<"$ids"
  all_nodes="$(infra_railway_deployment_trigger_nodes "$project_id" "$environment_id" "$service_id")"
  trigger_json="$(jq -s --arg repo "$RAILWAY_DEPLOY_REPO" --arg branch "$RAILWAY_DEPLOY_BRANCH" '
    [.[] | select(.provider == "github" and .branch == $branch and .repository == $repo)][0] // empty
  ' <<<"$all_nodes")"
  [[ -n "$trigger_json" ]] || die railway_deploy_trigger_missing \
    "GitHub autodeploy trigger missing; connect EBWiki/EBWiki on main in Railway Source (GitHub App)"

  trigger_id="$(jq -r '.id' <<<"$trigger_json")"
  suites="$(jq -r '.checkSuites' <<<"$trigger_json")"
  if [[ "$suites" == true ]]; then
    suites="$(infra_railway_read_trigger_check_suites "$trigger_id")"
    [[ "$suites" == true ]] || infra_railway_update_trigger_check_suites "$trigger_id"
    return 0
  fi
  infra_railway_update_trigger_check_suites "$trigger_id"
}
