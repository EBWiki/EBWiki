#!/usr/bin/env bash
# Require exactly one non-empty line on stdin.
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

infra_one() {
  local label="$1" vals n
  vals="$(grep -v '^$' || true)"
  n="$(printf '%s\n' "$vals" | grep -c . || true)"
  if [ "$n" -ne 1 ]; then
    echo "Expected exactly one ${label}, found ${n}." >&2
    return 1
  fi
  printf '%s' "$vals"
}
