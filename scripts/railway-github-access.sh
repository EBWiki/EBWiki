#!/usr/bin/env bash
# Gives the existing Railway GitHub app installation access to EBWiki/EBWiki.
set -euo pipefail

command -v gh >/dev/null 2>&1 || { echo "Install GitHub CLI (gh) and authenticate."; exit 1; }

INSTALLATION_ID="$(gh api /user/installations --jq '.installations[] | select(.app_slug=="railway-app") | .id' | head -1)"
if [ -z "${INSTALLATION_ID}" ]; then
  echo "No Railway GitHub app installation found for this user. Install the app in the browser first."
  exit 1
fi

REPO_ID="$(gh api /repos/EBWiki/EBWiki --jq .id)"
gh api -X PUT "/user/installations/${INSTALLATION_ID}/repositories/${REPO_ID}"
echo "Railway GitHub app can now read EBWiki/EBWiki."
