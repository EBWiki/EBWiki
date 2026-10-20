#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=infra-logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-logging.sh"
# shellcheck source=github-preflight.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/github-preflight.sh"

GITHUB_DELETE_SECRET_NAMES=(STAGING_USERNAME STAGING_PASSWORD ROLLBAR_ACCESS_TOKEN)

gh_api_method() {
  infra_curl_github_rest "$GH_HDR" "https://api.github.com$1" "$2" "${3:-GET}"
}

github_env_secret_present() {
  local name="$1"
  local code
  code="$(gh_api_method "/repos/$GH_REPO_SLUG/environments/$GH_ENV_NAME/secrets/$name" "$GH_TMP/env-secret.json")"
  [[ "$code" == 200 ]]
}

github_repo_secret_present() {
  local name="$1"
  local code
  code="$(gh_api_method "/repos/$GH_REPO_SLUG/actions/secrets/$name" "$GH_TMP/repo-secret.json")"
  [[ "$code" == 200 ]]
}

github_delete_repo_secret() {
  local name="$1"
  local code
  code="$(gh_api_method "/repos/$GH_REPO_SLUG/actions/secrets/$name" "$GH_TMP/delete.json" DELETE)"
  [[ "$code" == 204 ]] || die delete_secret "DELETE $name returned HTTP $code"
}

github_delete_cleanup_temp() {
  rm -rf "${GH_TMP:-}"
  GH_TMP=""
  infra_exit_trap_pop
}

github_delete_repo_secrets() {
  local confirm="$1"
  local name present=()

  github_preflight

  GH_TMP="$(mktemp -d)"
  chmod 700 "$GH_TMP"
  infra_exit_trap_push 'rm -rf "${GH_TMP:-}"'
  GH_HDR="$GH_TMP/hdr"
  local github_token="${TF_VAR_github_token:?}"
  ( umask 077; printf 'Authorization: Bearer %s\nAccept: application/vnd.github+json\nX-GitHub-Api-Version: 2022-11-28\n' \
    "$github_token" >"$GH_HDR" )

  for name in "${GITHUB_DELETE_SECRET_NAMES[@]}"; do
    github_env_secret_present "$name" || die preflight_env "environment secret $name is missing from $GH_ENV_NAME"
  done

  for name in "${GITHUB_DELETE_SECRET_NAMES[@]}"; do
    if github_repo_secret_present "$name"; then
      present+=("$name")
    fi
  done

  if ((${#present[@]} == 0)); then
    log_json info delete_skip "no repository-level smoke secrets to delete"
    github_delete_cleanup_temp
    return 0
  fi

  log_json info delete_dry_run "repository secrets present: ${present[*]}"

  if [[ "$confirm" != 1 ]]; then
    log_json info delete_dry_run "re-run with make github-delete-repo-secrets CONFIRM=1 to delete (requires typing delete-repo-secrets)"
    github_delete_cleanup_temp
    return 0
  fi

  local typed
  read -r -p "Type delete-repo-secrets to delete repository copies: " typed
  if [[ "$typed" != delete-repo-secrets ]]; then
    log_json error delete_confirm "confirmation phrase did not match"
    exit 1
  fi

  for name in "${present[@]}"; do
    github_delete_repo_secret "$name"
    log_json info delete_ok "removed repository secret $name"
  done
  github_delete_cleanup_temp
}
