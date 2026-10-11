# EBWiki infrastructure (OpenTofu)

Each subdirectory is a **separate root module** with its own R2 state object.

| Directory | Linear | Notes |
| --- | --- | --- |
| `staging/` | [GKT-462](https://linear.app/gkt/issue/GKT-462) | Railway + Doppler runtime + DNS for staging.ebwiki.org |
| `cloudflare/` | [GKT-1293](https://linear.app/gkt/issue/GKT-1293) | PR #4528: Access on `/health` (apply after staging) |

Shared conventions: OpenTofu **1.13.1** in CI, encrypted remote state on **R2**, DNS token name **`CLOUDFLARE_DNS_API_TOKEN`** (staging) vs Access token for #4528.
