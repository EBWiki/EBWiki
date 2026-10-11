#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-cloudflare.sh
source "$ROOT/scripts/lib/infra-cloudflare.sh"
# shellcheck source=lib/infra-railway.sh
source "$ROOT/scripts/lib/infra-railway.sh"

OUT="${1:-$ROOT/infra/staging/terraform.tfvars}"
EBWIKI_ZONE_NAME="${CLOUDFLARE_ZONE_NAME:-ebwiki.org}"
LEGACY_RECORD_NAME="${LEGACY_STAGING_DNS_RECORD_NAME:-staging.ebwiki.org}"
STAGING_HOSTNAME="${STAGING_HOSTNAME:-ebwiki.staging.grandkru.com}"

: "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set (Doppler ebwiki/infra)}"
: "${CLOUDFLARE_DNS_API_TOKEN:?CLOUDFLARE_DNS_API_TOKEN must be set (Doppler ebwiki/infra)}"
: "${CLOUDFLARE_GRANDKRU_ZONE_ID:?CLOUDFLARE_GRANDKRU_ZONE_ID must be set (Doppler ebwiki/infra after first-time setup)}"

command -v curl >/dev/null 2>&1 || { echo "curl is required."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required."; exit 1; }

ids="$(infra_railway_find_project_service_env)" || exit 1
read -r project_id service_id environment_id <<<"$ids"
public_domain="$(infra_railway_public_domain "$project_id" "$environment_id" "$service_id")" || exit 1

ebwiki_zone_json="$(infra_cf_zone_for_name "$EBWIKI_ZONE_NAME")"
ebwiki_zone_id="$(echo "$ebwiki_zone_json" | jq -r '.id')"
legacy_record_id="$(infra_cf_dns_record_id "$ebwiki_zone_id" "$LEGACY_RECORD_NAME")"

infra_cf_assert_no_dynamic_redirect_rules "$ebwiki_zone_id" "$CLOUDFLARE_DNS_API_TOKEN"

mkdir -p "$(dirname "$OUT")"
cat >"$OUT" <<EOF
cloudflare_zone_id               = "${ebwiki_zone_id}"
cloudflare_grandkru_zone_id      = "${CLOUDFLARE_GRANDKRU_ZONE_ID}"
cloudflare_staging_dns_record_id = "${legacy_record_id}"
railway_project_id               = "${project_id}"
railway_service_id               = "${service_id}"
railway_service_domain_fqdn      = "${public_domain}"
staging_hostname                 = "${STAGING_HOSTNAME}"
EOF

echo "Wrote ${OUT} for staging ${STAGING_HOSTNAME} (legacy ${LEGACY_RECORD_NAME})."
