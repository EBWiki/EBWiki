#!/usr/bin/env bash
# Cloudflare API helpers. Requires: curl, jq, CLOUDFLARE_API_TOKEN or first argument.
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

# shellcheck source=infra-curl.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-curl.sh"
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

infra_cf_dns_cname_record() {
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
  echo "$resp" | jq -c '.result[0]'
}

infra_cf_dns_txt_count() {
  local zone_id="$1"
  local record_name="$2"
  local token resp encoded_name
  token="$(infra_cf_api_token "${3:-}")"
  encoded_name="$(printf '%s' "$record_name" | jq -sRr @uri)"
  resp="$(infra_curl_get \
    "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?name=${encoded_name}&type=TXT" \
    "$token")"
  echo "$resp" | jq -e '.success' >/dev/null \
    || { echo "Cloudflare TXT lookup for ${record_name} failed." >&2; return 1; }
  echo "$resp" | jq -r '.result | length'
}
