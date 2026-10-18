#!/usr/bin/env bash
# curl helpers that keep bearer tokens off argv (curl -K - from stdin or -H @file).
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

# Every request is bounded so a stalled API cannot hang plan, apply or CI.
INFRA_CURL_CONNECT_TIMEOUT="${INFRA_CURL_CONNECT_TIMEOUT:-10}"
INFRA_CURL_MAX_TIME="${INFRA_CURL_MAX_TIME:-60}"

infra_curl() {
  curl --connect-timeout "$INFRA_CURL_CONNECT_TIMEOUT" --max-time "$INFRA_CURL_MAX_TIME" "$@"
}

infra_curl_k() {
  infra_curl -fsS -K - "$@"
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

infra_curl_delete() {
  local url="$1"
  local token="$2"
  {
    printf 'header = "Authorization: Bearer %s"\n' "$token"
    printf 'url = "%s"\n' "$url"
    printf 'request = "DELETE"\n'
  } | infra_curl_k
}

# GitHub REST: all headers in a mode-0600 file (Authorization, Accept, API version).
infra_curl_github_rest() {
  local hdr_file="$1" url="$2" out_file="$3" method="${4:-GET}"
  infra_curl -sS -o "$out_file" -w '%{http_code}' -H @"$hdr_file" -X "$method" "$url"
}

# POST JSON with every header in hdr_file (for example Rollbar token and Content-Type).
infra_curl_post_json_hdr_file() {
  local hdr_file="$1" url="$2" json_body="$3" out_file="${4:-/dev/null}"
  infra_curl -sS -o "$out_file" -H @"$hdr_file" -X POST --data-binary "$json_body" "$url"
}
