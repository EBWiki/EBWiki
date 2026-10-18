#!/usr/bin/env bash
# Shared JSON logging for GitHub infra scripts.
set -euo pipefail

log_json() {
  printf '{"ts":"%s","level":"%s","script":"%s","event":"%s","message":"%s"}\n' \
    "$(date -u +%FT%TZ)" "$1" "${GITHUB_SCRIPT_NAME:-${0##*/}}" "$2" "${3//\"/\\\"}" >&2
}

die() {
  log_json error "$1" "$2"
  exit 1
}
