#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../lib/infra-railway-config.sh
source "$ROOT/scripts/lib/infra-railway-config.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

clean="$ROOT/scripts/test/fixtures/railway-plan-no-destroy.json"
bad="$ROOT/scripts/test/fixtures/railway-plan-with-destroys.json"

[ "$(infra_railway_config_plan_destroy_count "$clean")" = "0" ] \
  || fail "clean plan should report 0 destroys"
pass "destroy count parses zero-destroy summary"

[ "$(infra_railway_config_plan_destroy_count "$bad")" = "22" ] \
  || fail "destructive plan should report 22 destroys"
pass "destroy count parses non-zero summary"

infra_railway_config_assert_plan_no_destructive "$clean" \
  || fail "clean plan should pass delete gate"
pass "delete gate accepts zero-destroy plan"

if infra_railway_config_assert_plan_no_destructive "$bad"; then
  fail "destructive plan should fail delete gate"
else
  pass "delete gate rejects destroy plan"
fi

echo "All infra-railway-config tests passed."
