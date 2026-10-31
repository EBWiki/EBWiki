#!/usr/bin/env bash
# Map Doppler ebwiki/infra secret names to TF_VAR_* for OpenTofu (Doppler names must stay uppercase).
set -euo pipefail

infra_export_tf_vars_from_infra_config() {
  if [ -n "${BOOTSTRAP_STATE_PASSPHRASE:-}" ]; then
    export TF_VAR_bootstrap_state_passphrase="$BOOTSTRAP_STATE_PASSPHRASE"
  fi
  if [ -n "${STATE_PASSPHRASE:-}" ]; then
    export TF_VAR_state_passphrase="$STATE_PASSPHRASE"
  fi
  if [ -n "${CLOUDFLARE_DNS_API_TOKEN:-}" ]; then
    export TF_VAR_cloudflare_dns_api_token="$CLOUDFLARE_DNS_API_TOKEN"
  fi
  if [ -n "${STAGING_RUNTIME_DOPPLER_TOKEN:-}" ]; then
    export TF_VAR_staging_runtime_doppler_token="$STAGING_RUNTIME_DOPPLER_TOKEN"
  fi
  if [ -n "${STAGING_BASIC_AUTH_USERNAME:-}" ]; then
    export TF_VAR_staging_basic_auth_username="$STAGING_BASIC_AUTH_USERNAME"
  fi
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    export TF_VAR_github_token="$GITHUB_TOKEN"
  fi
}

infra_export_github_smoke_secrets_from_stg() {
  command -v doppler >/dev/null 2>&1 || { echo "doppler CLI is required." >&2; exit 1; }
  TF_VAR_staging_username="$(doppler secrets get STAGING_USERNAME --project ebwiki --config stg --plain)"
  TF_VAR_staging_password="$(doppler secrets get STAGING_PASSWORD --project ebwiki --config stg --plain)"
  TF_VAR_rollbar_access_token="$(doppler secrets get ROLLBAR_ACCESS_TOKEN --project ebwiki --config stg --plain)"
  export TF_VAR_staging_username TF_VAR_staging_password TF_VAR_rollbar_access_token
}

# The GitHub stack gets exactly its own TF_VARs. Anything else exported by
# infra-with-tf-vars.sh (staging, bootstrap) or the caller's shell is dropped.
infra_scrub_tf_vars() {
  local v
  while read -r v; do
    [[ "$v" != TF_VAR_* ]] || unset "$v"
  done < <(compgen -e)
}

infra_require_github_tf_vars() {
  local u="${TF_VAR_staging_username:-}" p="${TF_VAR_staging_password:-}" r="${TF_VAR_rollbar_access_token:-}"
  infra_scrub_tf_vars
  [ -n "${STATE_PASSPHRASE:-}" ] && export TF_VAR_state_passphrase="$STATE_PASSPHRASE"
  [ -n "${GITHUB_TOKEN:-}" ] && export TF_VAR_github_token="$GITHUB_TOKEN"
  export TF_VAR_staging_username="$u" TF_VAR_staging_password="$p" TF_VAR_rollbar_access_token="$r"
  : "${TF_VAR_state_passphrase:?STATE_PASSPHRASE must be set in ebwiki/infra}"
  : "${TF_VAR_github_token:?GITHUB_TOKEN must be set in ebwiki/infra}"
  : "${TF_VAR_staging_username:?TF_VAR_staging_username must be set from ebwiki/stg}"
  : "${TF_VAR_staging_password:?TF_VAR_staging_password must be set from ebwiki/stg}"
  : "${TF_VAR_rollbar_access_token:?TF_VAR_rollbar_access_token must be set from ebwiki/stg}"
}

infra_require_bootstrap_migrate_tf_vars() {
  infra_export_tf_vars_from_infra_config
  : "${TF_VAR_bootstrap_state_passphrase:?BOOTSTRAP_STATE_PASSPHRASE must be set in ebwiki/infra}"
}

infra_require_staging_tf_vars() {
  infra_export_tf_vars_from_infra_config
  : "${TF_VAR_state_passphrase:?STATE_PASSPHRASE must be set in ebwiki/infra}"
  : "${TF_VAR_cloudflare_dns_api_token:?CLOUDFLARE_DNS_API_TOKEN must be set in ebwiki/infra}"
  : "${TF_VAR_staging_runtime_doppler_token:?STAGING_RUNTIME_DOPPLER_TOKEN must be set in ebwiki/infra}"
  : "${TF_VAR_staging_basic_auth_username:?STAGING_BASIC_AUTH_USERNAME must be set in ebwiki/infra}"
}
