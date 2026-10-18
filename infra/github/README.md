# GitHub release smoke environment (`release-smoke`)

OpenTofu stack for the **`release-smoke`** GitHub Actions environment: **`main`**-only deployment branch policy and environment secrets **`STAGING_USERNAME`**, **`STAGING_PASSWORD`**, and **`ROLLBAR_ACCESS_TOKEN`** (values sourced from Doppler **`ebwiki/stg`** at apply time).

Mark runs **`make plan`** and **`make apply`** from a machine with Doppler access. **`make apply` writes secrets to GitHub**. Coordinate with Mark before applying.

## Prerequisites in ebwiki/infra

- **`STATE_PASSPHRASE`**
- **`GITHUB_TOKEN`**: token with permission to manage repository environments and Actions secrets on **EBWiki/EBWiki**

Staging smoke values are read from **`ebwiki/stg`** during plan/apply (never passed on the shell argv).

## Commands

```bash
make plan    # includes this stack after staging
make apply   # includes this stack after staging; writes GitHub environment secrets
make github-delete-repo-secrets   # dry run; use --confirm after apply
```

After apply, Mark runs **`make github-delete-repo-secrets`** with **`--confirm`** to remove repository-level copies of the three secret names.

Delete any **repository-level** copies of these three secret names after the environment is live so workflows cannot read them from repo secrets.

Deployment policy import ID format (integrations/github **6.4.0**): `repository:environment:policy_id`. See [repository_environment_deployment_policy import](https://github.com/integrations/terraform-provider-github/blob/v6.4.0/website/docs/r/repository_environment_deployment_policy.html.markdown#import).
