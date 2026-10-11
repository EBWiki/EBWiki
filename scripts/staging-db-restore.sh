#!/usr/bin/env bash
# Restore a pg_dump from R2 into staging Postgres via railway ssh (private network).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-railway.sh
source "$ROOT/scripts/lib/infra-railway.sh"

object_key="${1:?Usage: staging-db-restore.sh staging/db-snapshots/<timestamp>.dump}"

: "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set (Doppler ebwiki/infra)}"
: "${R2_BUCKET_NAME:?R2_BUCKET_NAME must be set (Doppler ebwiki/infra)}"
: "${R2_S3_ENDPOINT:?R2_S3_ENDPOINT must be set (Doppler ebwiki/infra)}"
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID must be set (Doppler ebwiki/infra)}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY must be set (Doppler ebwiki/infra)}"

command -v aws >/dev/null 2>&1 || { echo "aws CLI is required."; exit 1; }
command -v railway >/dev/null 2>&1 || { echo "Railway CLI is required."; exit 1; }

ids="$(infra_railway_find_project_service_env)"
read -r project_id service_id environment_id <<<"$ids"

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-auto}"

aws s3 cp "s3://${R2_BUCKET_NAME}/${object_key}" - --endpoint-url "$R2_S3_ENDPOINT" --only-show-errors \
  | railway ssh \
    --project "$project_id" \
    --environment "$environment_id" \
    --service "$service_id" \
    -- ruby -e '
require "uri"
u = URI(ENV.fetch("DATABASE_URL"))
raise "unsupported DATABASE_URL" unless %w[postgresql postgres].include?(u.scheme)
db = u.path.delete_prefix("/")
raise "missing database in DATABASE_URL" if db.empty?
env = {
  "PGHOST" => u.host || "localhost",
  "PGPORT" => (u.port || 5432).to_s,
  "PGUSER" => u.user || "postgres",
  "PGPASSWORD" => u.password || "",
  "PGDATABASE" => db,
}
exec(env, "pg_restore", "--clean", "--if-exists", "--no-owner", "--no-acl", "-d", db)
'

echo "Restored ${object_key} into staging Postgres."
