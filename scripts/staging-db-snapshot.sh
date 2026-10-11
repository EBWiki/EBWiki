#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-railway.sh
source "$ROOT/scripts/lib/infra-railway.sh"

: "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set (Doppler ebwiki/infra)}"
: "${R2_BUCKET_NAME:?R2_BUCKET_NAME must be set (Doppler ebwiki/infra)}"
: "${R2_S3_ENDPOINT:?R2_S3_ENDPOINT must be set (Doppler ebwiki/infra)}"
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID must be set (Doppler ebwiki/infra)}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY must be set (Doppler ebwiki/infra)}"

command -v pg_dump >/dev/null 2>&1 || { echo "pg_dump is required (install PostgreSQL client)."; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "aws CLI is required for R2 upload."; exit 1; }

read -r project_id service_id environment_id <<<"$(infra_railway_find_project_service_env)"
database_url="$(infra_railway_database_url "$project_id" "$environment_id" "$service_id")"

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
dump_path="$(mktemp "/tmp/ebwiki-staging-${timestamp}.XXXXXX.dump")"
object_key="staging/db-snapshots/${timestamp}.dump"

pg_dump "$database_url" -Fc --no-owner --no-acl -f "$dump_path"

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-auto}"
aws s3 cp "$dump_path" "s3://${R2_BUCKET_NAME}/${object_key}" \
  --endpoint-url "$R2_S3_ENDPOINT" \
  --only-show-errors

rm -f "$dump_path"
echo "Uploaded staging Postgres snapshot to s3://${R2_BUCKET_NAME}/${object_key}"
