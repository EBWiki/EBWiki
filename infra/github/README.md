# GitHub release smoke environment (`release-smoke`)

OpenTofu stack for the **`release-smoke`** GitHub Actions environment: **`main`**-only deployment branch policy and environment secrets **`STAGING_USERNAME`**, **`STAGING_PASSWORD`**, and **`ROLLBAR_ACCESS_TOKEN`** (values sourced from Doppler **`ebwiki/stg`** at apply time).

**PR Manager** runs **`make plan`** and **`make apply`** on the PR Manager machine. **`make apply` writes secrets to GitHub** — coordinate with Mark before applying.

## Prerequisites in ebwiki/infra

- **`STATE_PASSPHRASE`**
- **`GITHUB_TOKEN`** — token with permission to manage repository environments and Actions secrets on **EBWiki/EBWiki**

Staging smoke values are read from **`ebwiki/stg`** during plan/apply (never passed on the shell argv).

## Commands

```bash
make plan    # includes this stack after staging
make apply   # includes this stack after staging; writes GitHub environment secrets
```

Delete any **repository-level** copies of these three secret names after the environment is live so workflows cannot read them from repo secrets.
