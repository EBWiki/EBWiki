#!/usr/bin/env bash
# OpenTofu staging plan destroy gate (allows only redirect ruleset removal).
set -euo pipefail

STAGING_ALLOWED_DESTROY_ADDRESS="cloudflare_ruleset.legacy_staging_redirect"
STAGING_CNAME_ADDRESS="cloudflare_dns_record.legacy_staging_ebwiki"
infra_staging_assert_tofu_plan_cloudflare_cname_only() {
  local plan_file="$1"
  local changes_json unexpected

  [ -f "$plan_file" ] || {
    echo "Missing OpenTofu plan: $plan_file" >&2
    return 1
  }

  changes_json="$(tofu show -json "$plan_file" | jq -c '
    [.resource_changes[]?
      | select(.address | startswith("cloudflare_"))
      | select(.change.actions != ["no-op"])
      | .address]
    | unique
  ')"

  unexpected="$(jq -r --arg cname "$STAGING_CNAME_ADDRESS" '
    [.[] | select(. != $cname)] | .[]
  ' <<<"$changes_json")"
  if [ -n "$unexpected" ]; then
    echo "OpenTofu plan has unexpected Cloudflare changes (only the staging CNAME may change):" >&2
    printf '%s\n' "$unexpected" >&2
    return 1
  fi
}

infra_staging_assert_tofu_plan_destroys() {
  local plan_file="$1"
  local destroys_json count

  [ -f "$plan_file" ] || {
    echo "Missing OpenTofu plan: $plan_file" >&2
    return 1
  }

  destroys_json="$(tofu show -json "$plan_file" | jq -c '
    [.resource_changes[]?
      | select(.change.actions | index("delete"))
      | .address]
    | unique
  ')"

  count="$(jq 'length' <<<"$destroys_json")"
  if [ "$count" -eq 0 ]; then
    return 0
  fi

  if [ "$count" -eq 1 ] && [ "$(jq -r '.[0]' <<<"$destroys_json")" = "$STAGING_ALLOWED_DESTROY_ADDRESS" ]; then
    echo "OpenTofu plan destroys ${STAGING_ALLOWED_DESTROY_ADDRESS} (expected)." >&2
    return 0
  fi

  echo "OpenTofu plan has unexpected destroys:" >&2
  jq -r '.[]' <<<"$destroys_json" >&2
  echo "Only ${STAGING_ALLOWED_DESTROY_ADDRESS} may be destroyed." >&2
  return 1
}
