#!/usr/bin/env bash
# curl helpers that keep bearer tokens off argv (curl -K - from stdin).
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

infra_curl_k() {
  curl -fsS -K - "$@"
}

infra_curl_get() {
  local url="$1"
  local token="$2"
  {
    printf 'header = "Authorization: Bearer %s"\n' "$token"
    printf 'url = "%s"\n' "$url"
  } | infra_curl_k
}

infra_curl_get_query() {
  local base_url="$1"
  local token="$2"
  shift 2
  local url="$base_url"
  local sep='?'
  local pair key val
  for pair in "$@"; do
    key="${pair%%=*}"
    val="${pair#*=}"
    url+="${sep}$(printf '%s=%s' "$key" "$val" | jq -sRr @uri)"
    sep='&'
  done
  infra_curl_get "$url" "$token"
}

infra_curl_post_json() {
  local url="$1"
  local token="$2"
  local json_body="$3"
  {
    printf 'header = "Authorization: Bearer %s"\n' "$token"
    printf 'header = "Content-Type: application/json"\n'
    printf 'url = "%s"\n' "$url"
    printf 'request = "POST"\n'
  } | infra_curl_k --data-binary "$json_body"
}
