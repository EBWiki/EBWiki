#!/usr/bin/env bash
# Fail closed unless RAILWAY_TOKEN is a workspace or account token (not project, not empty).
set -euo pipefail

# shellcheck source=infra-railway.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-railway.sh"
# shellcheck source=infra-logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-logging.sh"

infra_railway_token_type() {
  local token="$1"
  local project_payload api_payload workspace_count

  if [ -z "${token//[[:space:]]/}" ]; then
    printf '%s' empty
    return 0
  fi

  project_payload="$(infra_railway_gql_with_token "$token" \
    'query { projectToken { id name } }' '{}' 2>/dev/null)" || project_payload=''
  if [ -n "$project_payload" ] \
    && jq -e '(.errors // []) | length == 0' <<<"$project_payload" >/dev/null \
    && jq -e '.data.projectToken.id // empty | length > 0' <<<"$project_payload" >/dev/null; then
    printf '%s' project
    return 0
  fi

  api_payload="$(infra_railway_gql_with_token "$token" \
    'query { apiToken { workspaces { id name } } }' '{}' 2>/dev/null)" || api_payload=''
  workspace_count="$(jq -r '.data.apiToken.workspaces | length // 0' <<<"${api_payload:-{}}" 2>/dev/null || printf '0')"
  if [ "${workspace_count:-0}" -eq 0 ]; then
    printf '%s' unknown
    return 0
  fi
  if [ "$workspace_count" -gt 1 ]; then
    printf '%s' account
    return 0
  fi
  printf '%s' workspace
}

infra_railway_assert_workspace_or_account_token() {
  local token="${RAILWAY_TOKEN:-}" kind

  kind="$(infra_railway_token_type "$token")"
  case "$kind" in
    workspace|account)
      log_json info railway_token_ok "RAILWAY_TOKEN is a ${kind} token"
      ;;
    project)
      die railway_token_type "RAILWAY_TOKEN is a project token; use a workspace or account token in ebwiki/infra"
      ;;
    empty)
      die railway_token_type "RAILWAY_TOKEN is empty"
      ;;
    *)
      die railway_token_type "RAILWAY_TOKEN is not a workspace or account token"
      ;;
  esac
}
