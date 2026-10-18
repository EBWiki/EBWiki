#!/usr/bin/env bash
# Read-only staging DNS preflight. Fails closed.
#   staging-dns-preflight.sh [--allow-cname-repair]     live check before plan
#   staging-dns-preflight.sh --plan FILE                  live + planned check
# Live check: exactly one Cloudflare CNAME for the staging host, pointing at a
# Railway target (or repairable via the saved plan when --allow-cname-repair),
# with a boolean proxied flag, plus the Railway TXT verification record with the
# expected railway-verify= prefix. Plan check: the planned CNAME is DNS only and
# points at a Railway target.
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
RAILWAY_VERIFY_TXT_PATTERN='^railway-verify='
STAGING_CNAME_ADDRESS="cloudflare_dns_record.legacy_staging_ebwiki"

plan_file=""
allow_cname_repair=0
case "${1:-}" in
  "") ;;
  --allow-cname-repair)
    allow_cname_repair=1
    shift
    ;;
esac
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

if [[ ! "$cf_content" =~ $RAILWAY_TARGET_PATTERN ]]; then
  if ((allow_cname_repair == 1)) && [[ -n "$cf_content" ]]; then
    log_json warn staging_dns_cname_repair "CNAME ${STAGING_RECORD_NAME} content=${cf_content} is not a Railway target; OpenTofu plan must fix it"
  else
    die staging_dns_cname "CNAME ${STAGING_RECORD_NAME} does not point at a Railway target (content '${cf_content}')"
  fi
fi
[[ -n "$cf_proxied" ]] || die staging_dns_cname "CNAME ${STAGING_RECORD_NAME} has no proxied flag"

verify_record="$(infra_cf_dns_txt_record "$zone_id" "$STAGING_VERIFY_RECORD_NAME" "$cf_token")" \
  || die staging_dns_verify "expected exactly one TXT at ${STAGING_VERIFY_RECORD_NAME}"
verify_content="$(jq -r '.content // empty' <<<"$verify_record")"
[[ "$verify_content" =~ $RAILWAY_VERIFY_TXT_PATTERN ]] \
  || die staging_dns_verify "TXT ${STAGING_VERIFY_RECORD_NAME} must start with railway-verify= (content '${verify_content}')"

log_json info staging_dns_live "CNAME ${STAGING_RECORD_NAME} content=${cf_content} proxied=${cf_proxied}; verification TXT ok"
[ -n "${STAGING_E2E_TRACK_ORDER:-}" ] && echo dns >>"$STAGING_E2E_TRACK_ORDER"

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
