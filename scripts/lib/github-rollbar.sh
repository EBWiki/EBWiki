#!/usr/bin/env bash
# Rollbar reporting for GitHub infra script failures (token via header file, never argv).
set -euo pipefail

# shellcheck source=github-logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/github-logging.sh"

github_rollbar_header_file() {
  local token="${ROLLBAR_ACCESS_TOKEN:-${TF_VAR_rollbar_access_token:-}}"
  [ -n "$token" ] || return 1
  local dir="${GH_TMP:-}"
  if [ -z "$dir" ]; then
    dir="$(mktemp -d)"
    chmod 700 "$dir"
    GH_TMP="$dir"
  fi
  local hdr="$dir/rollbar.hdr"
  ( umask 077; printf 'X-Rollbar-Access-Token: %s\n' "$token" >"$hdr" )
  printf '%s' "$hdr"
}

github_rollbar_report_script_failure() {
  local line="$1"
  local exit_code="$2"
  local hdr
  hdr="$(github_rollbar_header_file)" || return 0

  local body
  body="$(jq -n \
    --arg msg "GitHub infra script failed at line ${line} exit ${exit_code}" \
    --arg script "${GITHUB_SCRIPT_NAME:-${0##*/}}" \
    '{data: {environment: "github-infra", body: {message: {body: $msg}, custom: {script: $script, line: $line, exit_code: ($exit_code | tonumber)}}}}')"

  curl -sS -o /dev/null -w '' \
    -X POST 'https://api.rollbar.com/api/1/item/' \
    -H @"$hdr" \
    -H 'Content-Type: application/json' \
    --data-binary "$body" || true
}

github_script_err_trap() {
  local exit_code=$?
  local line="${BASH_LINENO[0]:-$LINENO}"
  log_json error script_failed "line ${line} exit ${exit_code}"
  github_rollbar_report_script_failure "$line" "$exit_code" || true
  exit "$exit_code"
}
