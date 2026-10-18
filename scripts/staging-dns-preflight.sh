#!/usr/bin/env bash
# Read-only: compare Cloudflare staging CNAME to Railway custom-domain target before plan.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-logging.sh
source "$ROOT/scripts/lib/infra-logging.sh"
# shellcheck source=lib/infra-cloudflare.sh
source "$ROOT/scripts/lib/infra-cloudflare.sh"

EBWIKI_ZONE_NAME="${CLOUDFLARE_ZONE_NAME:-ebwiki.org}"
STAGING_RECORD_NAME="${STAGING_DNS_RECORD_NAME:-staging.ebwiki.org}"
PLAN_FILE="${1:-$ROOT/infra/staging/staging.tfplan}"

: "${CLOUDFLARE_DNS_API_TOKEN:?CLOUDFLARE_DNS_API_TOKEN must be set (Doppler ebwiki/infra)}"

ebwiki_zone_json="$(infra_cf_zone_for_name "$EBWIKI_ZONE_NAME")"
ebwiki_zone_id="$(echo "$ebwiki_zone_json" | jq -r '.id')"
cf_record="$(infra_cf_dns_cname_record "$ebwiki_zone_id" "$STAGING_RECORD_NAME")"
cf_content="$(echo "$cf_record" | jq -r '.content')"
cf_proxied="$(echo "$cf_record" | jq -r '.proxied')"

log_json info staging_dns_preflight "Cloudflare CNAME ${STAGING_RECORD_NAME} content=${cf_content} proxied=${cf_proxied}"

if [[ -f "$PLAN_FILE" ]]; then
  if command -v tofu >/dev/null 2>&1; then
    planned_target="$(tofu show -json "$PLAN_FILE" 2>/dev/null | jq -r '
      [.planned_values.root_module.resources[]?
        | select(.address == "cloudflare_dns_record.legacy_staging_ebwiki")][0].values.content // empty')" || planned_target=""
    if [[ -n "$planned_target" && "$planned_target" != "$cf_content" ]]; then
      log_json info staging_dns_plan_delta "plan would set CNAME content to ${planned_target} (live ${cf_content})"
    fi
  fi
fi
