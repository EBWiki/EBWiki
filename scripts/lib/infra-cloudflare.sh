#!/usr/bin/env bash
# Cloudflare API helpers. Requires: curl, jq, CLOUDFLARE_API_TOKEN or first argument.
set -euo pipefail

infra_cf_api_token() {
  if [ -n "${1:-}" ]; then
    printf '%s' "$1"
  elif [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
    printf '%s' "$CLOUDFLARE_API_TOKEN"
  elif [ -n "${TF_VAR_cloudflare_dns_api_token:-}" ]; then
    printf '%s' "$TF_VAR_cloudflare_dns_api_token"
  else
    echo "Cloudflare API token not set." >&2
    return 1
  fi
}

infra_cf_zone_for_name() {
  local zone_name="$1"
  local token
  token="$(infra_cf_api_token "${2:-}")"
  curl -fsS -H "Authorization: Bearer ${token}" \
    "https://api.cloudflare.com/client/v4/zones?name=${zone_name}&status=active" \
    | jq -e '.success and (.result | length > 0)' >/dev/null
  curl -fsS -H "Authorization: Bearer ${token}" \
    "https://api.cloudflare.com/client/v4/zones?name=${zone_name}&status=active" \
    | jq -r '.result[0]'
}

infra_cf_dns_record_id() {
  local zone_id="$1"
  local record_name="$2"
  local token
  token="$(infra_cf_api_token "${3:-}")"
  curl -fsS -G -H "Authorization: Bearer ${token}" \
    --data-urlencode "name=${record_name}" \
    "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records" \
    | jq -e '.success and (.result | length > 0)' >/dev/null
  curl -fsS -G -H "Authorization: Bearer ${token}" \
    --data-urlencode "name=${record_name}" \
    "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records" \
    | jq -r '.result[0].id'
}
