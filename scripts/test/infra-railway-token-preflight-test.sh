#!/usr/bin/env bash
# Behavior of the RAILWAY_TOKEN type preflight: only workspace or account tokens pass.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../lib/infra-railway-token-preflight.sh
source "$ROOT/scripts/lib/infra-railway-token-preflight.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }
export INFRA_SCRIPT_NAME=test

# STUB_KIND: project, workspace, account, none (no workspaces), denied (API errors), down (request fails).
infra_railway_gql_with_token() {
  local query="$2"
  [ "${STUB_KIND:-}" = down ] && return 1
  case "$query" in
    *projectToken*)
      if [ "${STUB_KIND:-}" = project ]; then
        printf '{"data":{"projectToken":{"id":"pt1","name":"ci"}}}'
      else
        printf '{"errors":[{"message":"Not Authorized"}],"data":null}'
      fi
      ;;
    *apiToken*)
      case "${STUB_KIND:-}" in
        workspace) printf '{"data":{"apiToken":{"workspaces":[{"id":"w1","name":"one"}]}}}' ;;
        account) printf '{"data":{"apiToken":{"workspaces":[{"id":"w1","name":"one"},{"id":"w2","name":"two"}]}}}' ;;
        none) printf '{"data":{"apiToken":{"workspaces":[]}}}' ;;
        *) printf '{"errors":[{"message":"Not Authorized"}],"data":null}' ;;
      esac
      ;;
    *) fail "unexpected query" ;;
  esac
}

expect_kind() { # kind token
  local got
  got="$(infra_railway_token_type "$2")"
  [ "$got" = "$1" ] || fail "token type: expected $1, got $got (STUB_KIND=${STUB_KIND:-})"
}

STUB_KIND=workspace expect_kind empty ""
STUB_KIND=workspace expect_kind empty "   "
STUB_KIND=project expect_kind project tok
STUB_KIND=workspace expect_kind workspace tok
STUB_KIND=account expect_kind account tok
STUB_KIND=none expect_kind unknown tok
STUB_KIND=denied expect_kind unknown tok
STUB_KIND=down expect_kind unknown tok
pass "token type is read from the API"

for kind in workspace account; do
  out="$(STUB_KIND=$kind RAILWAY_TOKEN=tok bash -c "$(declare -f); infra_railway_assert_workspace_or_account_token" 2>&1)" \
    || fail "$kind token must pass: $out"
  grep -q railway_token_ok <<<"$out" || fail "$kind token: ok event"
done
pass "workspace and account tokens pass"

for kind in project none denied down; do
  out="$(STUB_KIND=$kind RAILWAY_TOKEN=tok bash -c "$(declare -f); infra_railway_assert_workspace_or_account_token" 2>&1)" \
    && fail "$kind token must fail"
  grep -q railway_token_type <<<"$out" || fail "$kind token: error event"
done
out="$(STUB_KIND=workspace RAILWAY_TOKEN='' bash -c "$(declare -f); infra_railway_assert_workspace_or_account_token" 2>&1)" \
  && fail "empty token must fail"
grep -q 'RAILWAY_TOKEN is empty' <<<"$out" || fail "empty token message"
out="$(env -u RAILWAY_TOKEN STUB_KIND=workspace bash -c "$(declare -f); infra_railway_assert_workspace_or_account_token" 2>&1)" \
  && fail "unset token must fail"
pass "project, unknown, unreachable, empty and unset tokens fail closed"

echo "All infra-railway-token-preflight tests passed."
