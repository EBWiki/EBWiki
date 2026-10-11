#!/usr/bin/env bash
# Cloudflare API helpers. Requires: curl, jq, CLOUDFLARE_API_TOKEN or first argument.
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

# shellcheck source=infra-curl.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-curl.sh"
# shellcheck source=infra-tofu-state.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-tofu-state.sh"

infra_cf_api_token() {
  if [ -n "${1:-}" ]; then
    printf '%s' "$1"
  elif [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
    printf '%s' "$CLOUDFLARE_API_TOKEN"
  elif [ -n "${CLOUDFLARE_DNS_API_TOKEN:-}" ]; then
    printf '%s' "$CLOUDFLARE_DNS_API_TOKEN"
  elif [ -n "${TF_VAR_cloudflare_dns_api_token:-}" ]; then
    printf '%s' "$TF_VAR_cloudflare_dns_api_token"
  else
    echo "Cloudflare API token not set." >&2
    return 1
  fi
}

infra_cf_zone_for_name() {
  local zone_name="$1"
  local token resp encoded_zone
  token="$(infra_cf_api_token "${2:-}")"
  encoded_zone="$(printf '%s' "$zone_name" | jq -sRr @uri)"
  resp="$(infra_curl_get "https://api.cloudflare.com/client/v4/zones?name=${encoded_zone}&status=active" "$token")"
  echo "$resp" | jq -e '.success and (.result | length == 1)' >/dev/null \
    || { echo "Expected exactly one Cloudflare zone named ${zone_name}." >&2; return 1; }
  echo "$resp" | jq -r '.result[0]'
}

infra_cf_assert_no_dynamic_redirect_rules() {
  local zone_id="$1"
  local token="$2"
  local allowed_ruleset_id="${3:-}"
  local rs ruleset_id
  rs="$(infra_curl_get \
    "https://api.cloudflare.com/client/v4/zones/${zone_id}/rulesets/phases/http_request_dynamic_redirect/entrypoint" \
    "$token" 2>&1)" || {
    echo "$rs" | grep -q 'error: 404' && return 0
    echo "Could not read ebwiki.org redirect rules." >&2
    return 1
  }
  if echo "$rs" | jq -e '.success and (.result.rules | length > 0)' >/dev/null 2>&1; then
    ruleset_id="$(echo "$rs" | jq -r '.result.id // empty')"
    if [ -n "$allowed_ruleset_id" ] && [ "$ruleset_id" = "$allowed_ruleset_id" ]; then
      return 0
    fi
    echo "ebwiki.org already has Single Redirect rules. Import the ruleset and copy its rules into cloudflare.tf before applying." >&2
    return 1
  fi
}

# Ruleset ID for cloudflare_ruleset.legacy_staging_redirect when staging state is initialized.
infra_staging_legacy_redirect_ruleset_id_from_state() {
  local root staging_dir id
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  staging_dir="$root/infra/staging"
  [ -n "${STATE_PASSPHRASE:-}" ] || return 1
  export TF_VAR_state_passphrase="$STATE_PASSPHRASE"
  id="$(
    cd "$staging_dir" \
      && tofu init -backend-config=backend.hcl -input=false >/dev/null 2>&1 \
      && tofu state show -json cloudflare_ruleset.legacy_staging_redirect 2>/dev/null \
      | infra_tofu_state_show_json_resource_id
  )" || return 1
  [ -n "$id" ] || return 1
  printf '%s' "$id"
}

infra_cf_dns_record_id() {
  local zone_id="$1"
  local record_name="$2"
  local token resp encoded_name
  token="$(infra_cf_api_token "${3:-}")"
  encoded_name="$(printf '%s' "$record_name" | jq -sRr @uri)"
  resp="$(infra_curl_get \
    "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?name=${encoded_name}&type=CNAME" \
    "$token")"
  echo "$resp" | jq -e '.success and (.result | length == 1)' >/dev/null \
    || { echo "Expected exactly one Cloudflare CNAME record named ${record_name}." >&2; return 1; }
  echo "$resp" | jq -r '.result[0].id'
}
