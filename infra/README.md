# EBWiki infrastructure (OpenTofu)

| Step | Directory | Purpose |
| --- | --- | --- |
| 1 (once) | **`bootstrap/`** | R2 bucket, Cloudflare tokens, state passphrase, **`ebwiki/infra`** secrets |
| 2 | **`staging/`** | [GKT-462](https://linear.app/gkt/issue/GKT-462) Railway + **`ebwiki.staging.grandkru.com`** (+ legacy **`staging.ebwiki.org`** redirect) |
| 3 | **`cloudflare/`** | [GKT-1293](https://linear.app/gkt/issue/GKT-1293) PR #4528 Access on **`/health`** (after staging; include new staging host) |

Root **`Makefile`** targets: **`make bootstrap`**, **`make plan`**, **`make apply`**.

OpenTofu **1.13.1** in CI. Bootstrap state migrates to R2 in the same **`make bootstrap`** run.
