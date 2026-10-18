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

cname_change() { # actions json, extra changes
  printf '{"resource_changes":[{"address":"cloudflare_dns_record.legacy_staging_ebwiki","mode":"managed","type":"cloudflare_dns_record","change":{"actions":%s}}%s]}' "$1" "${2:-}"
}

for plan in \
  "$(cname_change '["update"]')" \
  "$(cname_change '["no-op"]')" \
  "$(cname_change '["update"]' ',{"address":"cloudflare_ruleset.legacy_staging_redirect","mode":"managed","type":"cloudflare_ruleset","change":{"actions":["delete"]}}')" \
  "$(cname_change '["update"]' ',{"address":"cloudflare_dns_record.staging_railway_verify","mode":"managed","type":"cloudflare_dns_record","change":{"actions":["no-op"]}}')" \
  "$(cname_change '["update"]' ',{"address":"data.cloudflare_zone.ebwiki","mode":"data","type":"cloudflare_zone","change":{"actions":["read"]}}')" \
  "$(cname_change '["update"]' ',{"address":"railway_service.ebwiki","mode":"managed","type":"railway_service","change":{"actions":["update"]}}')"; do
  printf '%s' "$plan" >"$tmpdir/plan.json"
  infra_staging_assert_tofu_plan_cloudflare_cname_only "$tmpdir/plan.json" \
    || fail "Cloudflare gate should accept: $plan"
done
pass "Cloudflare gate accepts CNAME changes, the redirect destroy, no-ops, data reads and non-Cloudflare changes"

for extra in \
  '{"address":"cloudflare_dns_record.staging_railway_verify","mode":"managed","type":"cloudflare_dns_record","change":{"actions":["update"]}}' \
  '{"address":"cloudflare_dns_record.staging_railway_verify","mode":"managed","type":"cloudflare_dns_record","change":{"actions":["delete","create"]}}' \
  '{"address":"cloudflare_ruleset.legacy_staging_redirect","mode":"managed","type":"cloudflare_ruleset","change":{"actions":["update"]}}' \
  '{"address":"cloudflare_zone_setting.ssl","mode":"managed","type":"cloudflare_zone_setting","change":{"actions":["create"]}}' \
  '{"address":"module.dns.cloudflare_dns_record.apex","mode":"managed","type":"cloudflare_dns_record","change":{"actions":["delete"]}}'; do
  printf '%s' "$(cname_change '["update"]' ",$extra")" >"$tmpdir/plan.json"
  if infra_staging_assert_tofu_plan_cloudflare_cname_only "$tmpdir/plan.json" 2>/dev/null; then
    fail "Cloudflare gate should reject: $extra"
  fi
done
infra_staging_assert_tofu_plan_cloudflare_cname_only "$tmpdir/missing.json" 2>/dev/null \
  && fail "Cloudflare gate should reject a missing plan"
printf 'not json' >"$tmpdir/plan.json"
infra_staging_assert_tofu_plan_cloudflare_cname_only "$tmpdir/plan.json" 2>/dev/null \
  && fail "Cloudflare gate should reject an unreadable plan"
pass "Cloudflare gate rejects any other Cloudflare change, a missing plan and an unreadable plan"

echo "All infra-staging-plan-gate tests passed."
