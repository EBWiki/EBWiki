#!/usr/bin/env bash
# Read-only staging DNS preflight. Fails closed.
#   staging-dns-preflight.sh               live check before plan
#   staging-dns-preflight.sh --plan FILE   live check, then check the saved plan
# Live check: exactly one Cloudflare CNAME for the staging host, pointing at a
# Railway target, with a boolean proxied flag, plus the Railway TXT verification
# record. Plan check: the planned CNAME is DNS only and points at a Railway target.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INFRA_SCRIPT_NAME="${INFRA_SCRIPT_NAME:-staging-dns-preflight.sh}"
# shellcheck source=lib/infra-logging.sh
source "$ROOT/scripts/lib/infra-logging.sh"
# shellcheck source=lib/infra-cloudflare.sh
source "$ROOT/scripts/lib/infra-cloudflare.sh"

EBWIKI_ZONE_NAME="ebwiki.org"
STAGING_RECORD_NAME="staging.ebwiki.org"
STAGING_VERIFY_RECORD_NAME="_railway-verify.staging.ebwiki.org"
RAILWAY_TARGET_PATTERN='^[a-z0-9-]+(\.[a-z0-9-]+)*\.railway\.app$'
STAGING_CNAME_ADDRESS="cloudflare_dns_record.legacy_staging_ebwiki"

plan_file=""
case "${1:-}" in
  "") ;;
  --plan)
    plan_file="${2:-}"
    [[ -n "$plan_file" ]] || die preflight_input "--plan needs a plan file"
    ;;
  *) die preflight_input "unknown argument ${1}" ;;
esac

cf_token="${CLOUDFLARE_DNS_API_TOKEN:-}"
[[ -n "$cf_token" ]] || die preflight_input "CLOUDFLARE_DNS_API_TOKEN must be set (Doppler ebwiki/infra)"

zone_id="$(infra_cf_zone_for_name "$EBWIKI_ZONE_NAME" "$cf_token" | jq -r '.id // empty')" \
  || die staging_dns_zone "could not read Cloudflare zone ${EBWIKI_ZONE_NAME}"
[[ -n "$zone_id" ]] || die staging_dns_zone "Cloudflare zone ${EBWIKI_ZONE_NAME} has no id"

cf_record="$(infra_cf_dns_cname_record "$zone_id" "$STAGING_RECORD_NAME" "$cf_token")" \
  || die staging_dns_cname "expected exactly one CNAME for ${STAGING_RECORD_NAME}"
cf_content="$(jq -r '.content // empty' <<<"$cf_record")"
cf_proxied="$(jq -r 'if (.proxied | type) == "boolean" then (.proxied | tostring) else empty end' <<<"$cf_record")"
[[ "$cf_content" =~ $RAILWAY_TARGET_PATTERN ]] \
  || die staging_dns_cname "CNAME ${STAGING_RECORD_NAME} does not point at a Railway target (content '${cf_content}')"
[[ -n "$cf_proxied" ]] || die staging_dns_cname "CNAME ${STAGING_RECORD_NAME} has no proxied flag"

verify_count="$(infra_cf_dns_txt_count "$zone_id" "$STAGING_VERIFY_RECORD_NAME" "$cf_token")" \
  || die staging_dns_verify "could not read TXT ${STAGING_VERIFY_RECORD_NAME}"
[[ "$verify_count" == 1 ]] \
  || die staging_dns_verify "expected one Railway verification TXT at ${STAGING_VERIFY_RECORD_NAME}, found ${verify_count}"

log_json info staging_dns_live "CNAME ${STAGING_RECORD_NAME} content=${cf_content} proxied=${cf_proxied}; verification TXT present"

[[ -n "$plan_file" ]] || exit 0
[[ -f "$plan_file" ]] || die staging_dns_plan "plan file ${plan_file} is missing"

planned="$(tofu show -json "$plan_file" | jq -c --arg addr "$STAGING_CNAME_ADDRESS" '
  [.planned_values.root_module.resources[]? | select(.address == $addr)][0].values // empty')" \
  || die staging_dns_plan "could not read ${plan_file}"
[[ -n "$planned" ]] || die staging_dns_plan "plan has no ${STAGING_CNAME_ADDRESS}"
planned_content="$(jq -r '.content // empty' <<<"$planned")"
planned_proxied="$(jq -r '.proxied | tostring' <<<"$planned")"
[[ "$planned_content" =~ $RAILWAY_TARGET_PATTERN ]] \
  || die staging_dns_plan "planned CNAME content '${planned_content}' is not a Railway target"
[[ "$planned_proxied" == false ]] || die staging_dns_plan "planned CNAME must be DNS only (proxied=${planned_proxied})"

if [[ "$planned_content" != "$cf_content" || "$planned_proxied" != "$cf_proxied" ]]; then
  log_json info staging_dns_plan_delta "plan changes CNAME to content=${planned_content} proxied=false (live content=${cf_content} proxied=${cf_proxied})"
else
  log_json info staging_dns_plan_delta "plan leaves the staging CNAME unchanged"
fi
