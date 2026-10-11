#!/usr/bin/env bash
# Settings the Railway Terraform provider does not expose reliably (GitHub install,
# workspace linking). Run once after the service exists, or when plan shows drift
# on repo connection. Requires: railway CLI, RAILWAY_TOKEN, service linked context.
set -euo pipefail

SERVICE_ID="${RAILWAY_SERVICE_ID:-745e0c67-a192-44d1-ad5e-e4dc616720b7}"
PROJECT_ID="${RAILWAY_PROJECT_ID:-5e9fc613-b97c-4ed2-a721-966aa54490c8}"
REPO="${RAILWAY_GITHUB_REPO:-EBWiki/EBWiki}"
BRANCH="${RAILWAY_GITHUB_BRANCH:-main}"

echo "Railway service ${SERVICE_ID} in project ${PROJECT_ID}"
echo "Expected Git repo: ${REPO} @ ${BRANCH}"
echo "Deploy settings should come from railway.toml (Dockerfile.railway, release-tasks.sh, /up)."
echo ""
echo "If OpenTofu cannot attach the GitHub repo, in the Railway dashboard:"
echo "  1. Open project ebwiki-maps-preview → service ebwiki-web → Settings → Source."
echo "  2. Connect GitHub repo ${REPO}, branch ${BRANCH}, root directory /."
echo "  3. Confirm builder reads railway.toml (preDeployCommand: bash release-tasks.sh)."
echo ""
echo "CLI status (when linked):"
if command -v railway >/dev/null 2>&1; then
  railway status --service "${SERVICE_ID}" 2>/dev/null || railway service "${SERVICE_ID}" 2>/dev/null || true
else
  echo "  (install Railway CLI: https://docs.railway.com/develop/cli)"
fi
