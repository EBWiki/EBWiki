#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=infra-logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-logging.sh"
# shellcheck source=infra-exit-trap.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-exit-trap.sh"
# shellcheck source=infra-curl.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-curl.sh"

# Fixed target. A GH_REPO_SLUG from the environment is overwritten here, never used.
GH_REPO_SLUG='EBWiki/EBWiki'
GH_ENV_NAME="release-smoke"
GH_TMP=""
GH_HDR=""

gh_api() {
  infra_curl_github_rest "$GH_HDR" "https://api.github.com$1" "$2" "${3:-GET}"
}

github_preflight() {
  local mode="${1:-plan}"
  local v code main_count non_main policy_id state_pass

  for v in TF_VAR_state_passphrase TF_VAR_github_token TF_VAR_staging_username TF_VAR_staging_password TF_VAR_rollbar_access_token; do
    [[ -n "${!v:-}" ]] || die preflight_input "$v is empty"
    [[ "${!v}" != *$'\n'* ]] || die preflight_input "$v contains a newline"
  done
  state_pass="${TF_VAR_state_passphrase:-}"
  if ((${#state_pass} < 16)); then
    die preflight_input "state passphrase is shorter than 16 characters"
  fi

  local allowed=' TF_VAR_state_passphrase TF_VAR_github_token TF_VAR_staging_username TF_VAR_staging_password TF_VAR_rollbar_access_token TF_VAR_existing_release_smoke_environment TF_VAR_existing_main_policy_id '
  while read -r v; do
    [[ "$allowed" == *" $v "* ]] || die preflight_input "unexpected $v in environment"
  done < <(compgen -e | grep '^TF_VAR_' || true)

  GH_TMP="$(mktemp -d)"
  chmod 700 "$GH_TMP"
  infra_exit_trap_push 'rm -rf "${GH_TMP:-}"'
  GH_HDR="$GH_TMP/hdr"
  local github_token="${TF_VAR_github_token:?}"
  ( umask 077; printf 'Authorization: Bearer %s\nAccept: application/vnd.github+json\nX-GitHub-Api-Version: 2022-11-28\n' \
    "$github_token" >"$GH_HDR" )

  code="$(gh_api "/repos/$GH_REPO_SLUG" "$GH_TMP/repo.json")"
  [[ "$code" == 200 ]] || die preflight_token "GET repo returned HTTP $code"
  [[ "$(jq -r '.permissions.admin' "$GH_TMP/repo.json")" == true ]] || die preflight_token "token does not have admin on $GH_REPO_SLUG"

  code="$(gh_api "/repos/$GH_REPO_SLUG/actions/secrets/public-key" "$GH_TMP/pk.json")"
  [[ "$code" == 200 ]] || die preflight_token "token cannot read Actions secrets (HTTP $code)"

  code="$(gh_api "/repos/$GH_REPO_SLUG/environments/$GH_ENV_NAME" "$GH_TMP/env.json")"
  case "$code" in
    200)
      export TF_VAR_existing_release_smoke_environment=true
      code="$(gh_api "/repos/$GH_REPO_SLUG/environments/$GH_ENV_NAME/deployment-branch-policies" "$GH_TMP/pol.json")"
      [[ "$code" == 200 || "$code" == 404 ]] || die preflight_lookup "policy lookup HTTP $code"
      if [[ "$code" == 200 ]]; then
        main_count="$(jq '[.branch_policies[]? | select(.name == "main" and ((.type // "branch") == "branch"))] | length' "$GH_TMP/pol.json")"
        if ((main_count > 1)); then
          die preflight_lookup "more than one main branch deployment policy"
        fi
        non_main="$(jq '[.branch_policies[]? | select(.name != "main" or ((.type // "branch") != "branch"))] | length' "$GH_TMP/pol.json")"
        if ((non_main > 0)); then
          die preflight_lookup "environment has deployment policies other than main"
        fi
        if ((main_count == 1)); then
          policy_id="$(jq -r '[.branch_policies[]? | select(.name == "main" and ((.type // "branch") == "branch")) | .id][0] // ""' "$GH_TMP/pol.json")"
          export TF_VAR_existing_main_policy_id="$policy_id"
        else
          export TF_VAR_existing_main_policy_id=""
        fi
      else
        export TF_VAR_existing_main_policy_id=""
      fi
      ;;
    404)
      if [ "$mode" = apply ]; then
        die preflight_lookup "release-smoke environment is missing; apply the GitHub stack before running smoke checks"
      fi
      export TF_VAR_existing_release_smoke_environment=false
      export TF_VAR_existing_main_policy_id=""
      ;;
    *)
      die preflight_lookup "environment lookup HTTP $code"
      ;;
  esac

  log_json info preflight_ok "token is admin; environment exists=${TF_VAR_existing_release_smoke_environment}"
  rm -rf "$GH_TMP"
  GH_TMP=""
  GH_HDR=""
  infra_exit_trap_pop
}
