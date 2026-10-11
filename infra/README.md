# EBWiki infrastructure (OpenTofu)

**PR Manager** runs all operator steps from the PR Manager machine. **`make bootstrap`** loads maker secrets from Doppler **`grandkru/prd`**. **`make plan`** and **`make apply`** load runtime secrets from Doppler **`ebwiki/infra`** (created by bootstrap).

| Step | Directory | Who / credentials | Purpose |
| --- | --- | --- | --- |
| 1 (once) | **`bootstrap/`** | PR Manager + **`grandkru/prd`** makers | R2 bucket, minted Cloudflare API tokens, **`ebwiki/infra`** |
| 2 | **`staging/`** | PR Manager + **`ebwiki/infra`** | Railway + **`ebwiki.staging.grandkru.com`** (+ legacy **`staging.ebwiki.org`** redirect) |
| 3 | **`cloudflare/`** | PR Manager + **`ebwiki/infra`** | [GKT-1293](https://linear.app/gkt/issue/GKT-1293) PR #4528 Access on **`/health`** (after staging; include new staging host) |

Root **`Makefile`:** **`make bootstrap`**, **`make plan`**, **`make apply`**.

OpenTofu **1.13.1** in CI. Bootstrap state migrates to R2 in the same **`make bootstrap`** run.

See **`infra/bootstrap/README.md`** for how **`CLOUDFLARE_TOKEN_MAKER`** creates DNS and R2 tokens (it does not mint a second token that creates other tokens; Cloudflare refuses that).
