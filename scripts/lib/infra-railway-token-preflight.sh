#!/usr/bin/env bash
# Fail closed unless RAILWAY_TOKEN is a workspace or account token (not project, not empty).
set -euo pipefail

# shellcheck source=infra-railway.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-railway.sh"
# shellcheck source=infra-logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-logging.sh"

# Prints empty, project, workspace, account or unknown. Never prints the token.
infra_railway_token_type() {
  local token="$1"
  local payload workspace_count

  if [ -z "${token//[[:space:]]/}" ]; then
    printf '%s' empty
    return 0
  fi

  if payload="$(infra_railway_gql_with_token "$token" 'query { projectToken { id name } }' '{}' 2>/dev/null)" \
    && jq -e '((.errors // []) | length == 0) and ((.data.projectToken.id // "") | length > 0)' \
      <<<"$payload" >/dev/null 2>&1; then
    printf '%s' project
    return 0
  fi

  workspace_count=0
  if payload="$(infra_railway_gql_with_token "$token" 'query { apiToken { workspaces { id name } } }' '{}' 2>/dev/null)"; then
    workspace_count="$(jq -r 'if ((.errors // []) | length) == 0 and (.data.apiToken.workspaces | type) == "array"
      then (.data.apiToken.workspaces | length) else 0 end' <<<"$payload" 2>/dev/null)" || workspace_count=0
  fi
  [[ "$workspace_count" =~ ^[0-9]+$ ]] || workspace_count=0

  if ((workspace_count == 0)); then
    printf '%s' unknown
  elif ((workspace_count > 1)); then
    printf '%s' account
  else
    printf '%s' workspace
  fi
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
