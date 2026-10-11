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
  if [ -n "${CLOUDFLARE_GRANDKRU_DNS_API_TOKEN:-}" ]; then
    export TF_VAR_cloudflare_grandkru_dns_api_token="$CLOUDFLARE_GRANDKRU_DNS_API_TOKEN"
  fi
  if [ -n "${STAGING_RUNTIME_DOPPLER_TOKEN:-}" ]; then
    export TF_VAR_staging_runtime_doppler_token="$STAGING_RUNTIME_DOPPLER_TOKEN"
  fi
  if [ -n "${STAGING_BASIC_AUTH_USERNAME:-}" ]; then
    export TF_VAR_staging_basic_auth_username="$STAGING_BASIC_AUTH_USERNAME"
  fi
}

infra_require_bootstrap_migrate_tf_vars() {
  infra_export_tf_vars_from_infra_config
  : "${TF_VAR_bootstrap_state_passphrase:?BOOTSTRAP_STATE_PASSPHRASE must be set in ebwiki/infra}"
}

infra_require_staging_tf_vars() {
  infra_export_tf_vars_from_infra_config
  : "${TF_VAR_state_passphrase:?STATE_PASSPHRASE must be set in ebwiki/infra}"
  : "${TF_VAR_cloudflare_dns_api_token:?CLOUDFLARE_DNS_API_TOKEN must be set in ebwiki/infra}"
  : "${TF_VAR_cloudflare_grandkru_dns_api_token:?CLOUDFLARE_GRANDKRU_DNS_API_TOKEN must be set in ebwiki/infra}"
  : "${TF_VAR_staging_runtime_doppler_token:?STAGING_RUNTIME_DOPPLER_TOKEN must be set in ebwiki/infra}"
  : "${TF_VAR_staging_basic_auth_username:?STAGING_BASIC_AUTH_USERNAME must be set in ebwiki/infra}"
}
