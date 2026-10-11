#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

doppler run --project ebwiki --config infra -- "$ROOT/scripts/infra-write-backend.sh"

doppler run --project ebwiki --config infra -- "$ROOT/scripts/staging-db-snapshot.sh"

doppler run --project ebwiki --config infra -- "$ROOT/scripts/write-staging-tfvars.sh"

doppler run --project ebwiki --config infra -- \
  sh -c "cd infra/staging && tofu init -backend-config=backend.hcl -input=false && tofu apply -input=false"
