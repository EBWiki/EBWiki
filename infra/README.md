# EBWiki infrastructure (OpenTofu)

Each subdirectory is a **separate root module** with its own state file and CI workflow.

| Directory | Linear | Status |
| --- | --- | --- |
| `staging/` | [GKT-462](https://linear.app/gkt/issue/GKT-462) | Railway + Doppler + DNS for staging.ebwiki.org |
| `cloudflare/` | [GKT-1293](https://linear.app/gkt/issue/GKT-1293) | PR #4528: Access on `/health` |

Shared conventions: OpenTofu **1.9.0** in CI, `tofu init -backend=false` on PRs, Cloudflare provider **~> 5.0**, secrets via Doppler names only.
