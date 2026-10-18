#!/usr/bin/env bash
# Rollbar reporting for infra script failures (token via header file, never argv).
set -euo pipefail

# shellcheck source=infra-logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-logging.sh"

infra_rollbar_report_script_failure() {
  local line="$1" exit_code="$2" token="${ROLLBAR_ACCESS_TOKEN:-${TF_VAR_rollbar_access_token:-}}" hdr body
  [ -n "$token" ] || return 0
  hdr="$(mktemp)"
  chmod 600 "$hdr"
  printf 'X-Rollbar-Access-Token: %s\n' "$token" >"$hdr"
  body="$(jq -n --arg msg "Infra script failed at line ${line} exit ${exit_code}" \
    --arg script "${INFRA_SCRIPT_NAME:-${0##*/}}" --arg line "$line" --arg exit_code "$exit_code" \
    '{data:{environment:"infra",body:{message:{body:$msg}},custom:{script:$script,line:$line,exit_code:($exit_code|tonumber)}}}')"
  curl -sS -o /dev/null -X POST https://api.rollbar.com/api/1/item/ -H @"$hdr" -H 'Content-Type: application/json' --data-binary "$body" || true
  rm -f "$hdr"
}

# Loads the Rollbar token from ebwiki/stg into this shell only (not exported).
infra_rollbar_load_token_from_stg() {
  ROLLBAR_ACCESS_TOKEN="$(doppler secrets get ROLLBAR_ACCESS_TOKEN --project ebwiki --config stg --plain)"
}

infra_script_err_trap() {
  local exit_code=$?
  local line="${BASH_LINENO[0]:-$LINENO}"
  log_json error script_failed "line ${line} exit ${exit_code}"
  infra_rollbar_report_script_failure "$line" "$exit_code" || true
  exit "$exit_code"
}
