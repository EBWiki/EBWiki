#!/usr/bin/env bash
# Railway GraphQL helpers. Requires: curl, jq, RAILWAY_TOKEN.
set -euo pipefail

# shellcheck source=infra-curl.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-curl.sh"
# shellcheck source=infra-one.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-one.sh"

RAILWAY_GQL_URL="${RAILWAY_GQL_URL:-https://backboard.railway.com/graphql/v2}"
RAILWAY_TARGET_PROJECT_NAME="${RAILWAY_TARGET_PROJECT_NAME:-ebwiki}"
RAILWAY_TARGET_SERVICE_NAME="${RAILWAY_TARGET_SERVICE_NAME:-ebwiki}"
RAILWAY_TARGET_ENVIRONMENT_NAME="${RAILWAY_TARGET_ENVIRONMENT_NAME:-production}"

infra_railway_gql() {
  local query="$1"
  local variables="${2:-}"
  local body
  [ -n "$variables" ] || variables='{}'
  : "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set}"
  body="$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')"
  infra_curl_post_json "$RAILWAY_GQL_URL" "$RAILWAY_TOKEN" "$body"
}

infra_railway_find_project_service_env() {
  local query='query { projects { edges { node { id name environments { edges { node { id name } } } services { edges { node { id name } } } } } } }'
  local payload project_id service_id environment_id

  payload="$(infra_railway_gql "$query")"
  project_id="$(echo "$payload" | jq -r --arg n "$RAILWAY_TARGET_PROJECT_NAME" \
    '.data.projects.edges[].node | select(.name == $n) | .id' | infra_one "Railway project named ${RAILWAY_TARGET_PROJECT_NAME}")"
  service_id="$(echo "$payload" | jq -r --arg pn "$RAILWAY_TARGET_PROJECT_NAME" --arg sn "$RAILWAY_TARGET_SERVICE_NAME" \
    '.data.projects.edges[].node | select(.name == $pn) | .services.edges[].node | select(.name == $sn) | .id' \
    | infra_one "Railway service named ${RAILWAY_TARGET_SERVICE_NAME} in project ${RAILWAY_TARGET_PROJECT_NAME}")"
  environment_id="$(echo "$payload" | jq -r --arg pn "$RAILWAY_TARGET_PROJECT_NAME" --arg en "$RAILWAY_TARGET_ENVIRONMENT_NAME" \
    '.data.projects.edges[].node | select(.name == $pn) | .environments.edges[].node | select(.name == $en) | .id' \
    | infra_one "Railway environment named ${RAILWAY_TARGET_ENVIRONMENT_NAME} in project ${RAILWAY_TARGET_PROJECT_NAME}")"

  printf '%s %s %s\n' "$project_id" "$service_id" "$environment_id"
}

infra_railway_public_domain() {
  local project_id="$1"
  local environment_id="$2"
  local service_id="$3"
  local query='query($projectId: String!, $environmentId: String!, $serviceId: String!) { domains(projectId: $projectId, environmentId: $environmentId, serviceId: $serviceId) }'
  local vars domain

  vars="$(jq -n --arg p "$project_id" --arg e "$environment_id" --arg s "$service_id" \
    '{projectId: $p, environmentId: $e, serviceId: $s}')"
  domain="$(infra_railway_gql "$query" "$vars" \
    | jq -r '.data.domains.serviceDomains[].domain' \
    | infra_one "Railway public service domain for service ${service_id}")"
  printf '%s' "$domain"
}

# Shell snippet: set libpq env from DATABASE_URL (no credentials on argv).
infra_railway_remote_libpq_from_database_url() {
  cat <<'REMOTE'
set -euo pipefail
if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL is not set in the Railway service environment." >&2
  exit 1
fi
eval "$(ruby -ruri -e '
  u = URI(ENV.fetch("DATABASE_URL"))
  raise "unsupported DATABASE_URL scheme" unless u.scheme == "postgresql" || u.scheme == "postgres"
  host = u.host || "localhost"
  port = u.port || 5432
  user = u.user || "postgres"
  pass = u.password || ""
  db = (u.path || "").sub(%r{\A/}, "")
  raise "missing database name in DATABASE_URL" if db.empty?
  puts "export PGHOST=#{host.inspect} PGPORT=#{port.inspect} PGUSER=#{user.inspect} PGPASSWORD=#{pass.inspect} PGDATABASE=#{db.inspect}"
')"
REMOTE
}

# Remote script for `railway ssh ... bash -s` (pg_dump to stdout).
infra_railway_remote_pg_dump_shell() {
  infra_railway_remote_libpq_from_database_url
  printf '%s\n' 'exec pg_dump -Fc --no-owner --no-acl'
}
