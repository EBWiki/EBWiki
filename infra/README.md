# EBWiki infrastructure (OpenTofu)

| Step | Directory | Purpose |
| --- | --- | --- |
| 1 (once) | **`bootstrap/`** | R2 bucket, DNS token, state passphrase, **`ebwiki/infra`** secrets |
| 2 | **`staging/`** | [GKT-462](https://linear.app/gkt/issue/GKT-462) Railway + DNS for staging.ebwiki.org |
| 3 | **`cloudflare/`** | [GKT-1293](https://linear.app/gkt/issue/GKT-1293) PR #4528 Access on `/health` (after staging) |

Root **`Makefile`** targets: **`make bootstrap`**, **`make plan`**, **`make apply`**.

OpenTofu **1.13.1** in CI. Bootstrap state stays local and encrypted until optionally migrated to R2.
