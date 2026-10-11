#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../lib/infra-staging-plan-gate.sh
source "$ROOT/scripts/lib/infra-staging-plan-gate.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

tofu() {
  if [ "$1" = "show" ] && [ "$2" = "-json" ]; then
    cat "$tmpdir/plan.json"
    return 0
  fi
  fail "unexpected tofu invocation: $*"
}

export -f tofu

no_destroy='{"resource_changes":[{"address":"cloudflare_dns_record.legacy_staging_ebwiki","change":{"actions":["update"]}}]}'
allowed='{"resource_changes":[{"address":"cloudflare_ruleset.legacy_staging_redirect","change":{"actions":["delete"]}}]}'
bad='{"resource_changes":[{"address":"cloudflare_ruleset.legacy_staging_redirect","change":{"actions":["delete"]}},{"address":"railway_service.ebwiki","change":{"actions":["delete"]}}]}'

printf '%s' "$no_destroy" >"$tmpdir/plan.json"
infra_staging_assert_tofu_plan_destroys "$tmpdir/plan.json" \
  || fail "should accept plan with no destroys"
pass "OpenTofu gate accepts zero destroys"

printf '%s' "$allowed" >"$tmpdir/plan.json"
infra_staging_assert_tofu_plan_destroys "$tmpdir/plan.json" \
  || fail "should accept redirect ruleset destroy"
pass "OpenTofu gate accepts redirect ruleset destroy only"

printf '%s' "$bad" >"$tmpdir/plan.json"
if infra_staging_assert_tofu_plan_destroys "$tmpdir/plan.json"; then
  fail "should reject extra destroys"
else
  pass "OpenTofu gate rejects unexpected destroys"
fi

echo "All infra-staging-plan-gate tests passed."
