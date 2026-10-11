#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-cloudflare.sh
source "$ROOT/scripts/lib/infra-cloudflare.sh"
# shellcheck source=lib/infra-railway.sh
source "$ROOT/scripts/lib/infra-railway.sh"

OUT="${1:-$ROOT/infra/staging/terraform.tfvars}"
ZONE_NAME="${CLOUDFLARE_ZONE_NAME:-ebwiki.org}"
STAGING_RECORD_NAME="${STAGING_DNS_RECORD_NAME:-staging.ebwiki.org}"

: "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set (Doppler ebwiki/infra)}"

command -v curl >/dev/null 2>&1 || { echo "curl is required."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required."; exit 1; }

read -r project_id service_id environment_id <<<"$(infra_railway_find_project_service_env)"
public_domain="$(infra_railway_public_domain "$project_id" "$environment_id" "$service_id")"

zone_json="$(infra_cf_zone_for_name "$ZONE_NAME")"
zone_id="$(echo "$zone_json" | jq -r '.id')"
record_id="$(infra_cf_dns_record_id "$zone_id" "$STAGING_RECORD_NAME")"

mkdir -p "$(dirname "$OUT")"
cat >"$OUT" <<EOF
cloudflare_zone_id               = "${zone_id}"
cloudflare_staging_dns_record_id = "${record_id}"
railway_project_id               = "${project_id}"
railway_service_id               = "${service_id}"
railway_service_domain_fqdn      = "${public_domain}"
EOF

echo "Wrote ${OUT} for Railway ${RAILWAY_TARGET_PROJECT_NAME}/${RAILWAY_TARGET_SERVICE_NAME} and DNS ${STAGING_RECORD_NAME}."
