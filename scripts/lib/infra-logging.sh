#!/usr/bin/env bash
# Shared JSON logging for infra scripts.
set -euo pipefail

log_json() {
  jq -nc \
    --arg ts "$(date -u +%FT%TZ)" \
    --arg level "$1" \
    --arg script "${INFRA_SCRIPT_NAME:-${0##*/}}" \
    --arg event "$2" \
    --arg message "$3" \
    '{ts:$ts,level:$level,script:$script,event:$event,message:$message}' >&2
}

die() {
  log_json error "$1" "$2"
  if declare -F infra_rollbar_report_script_failure >/dev/null; then
    infra_rollbar_report_script_failure "${BASH_LINENO[0]:-0}" 1 || true
  fi
  exit 1
}
