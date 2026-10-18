# EBWiki infrastructure (OpenTofu)

**`make bootstrap`** loads maker secrets from Doppler **`grandkru/prd`**. **`make plan`** and **`make apply`** load runtime secrets from Doppler **`ebwiki/infra`** (created by bootstrap).

| Step | Directory | Who / credentials | Purpose |
| --- | --- | --- | --- |
| 1 (once) | **`bootstrap/`** | **`grandkru/prd`** makers | R2 bucket, minted Cloudflare API tokens, **`ebwiki/infra`** |
| 2 | **`staging/`** | **`ebwiki/infra`** | Railway + **`staging.ebwiki.org`** |
| 3 | **`github/`** | **`ebwiki/infra`** + smoke values from **`ebwiki/stg`** | **`release-smoke`** GitHub environment and Actions secrets |

Root **`Makefile`:** **`make bootstrap`**, **`make plan`**, **`make apply`**.

OpenTofu **1.13.1** in CI. Bootstrap state migrates to R2 in the same **`make bootstrap`** run.

See **`infra/bootstrap/README.md`** for how **`CLOUDFLARE_TOKEN_MAKER`** creates DNS and R2 tokens (it does not mint a second token that creates other tokens; Cloudflare refuses that).
