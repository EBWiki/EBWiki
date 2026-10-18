# GitHub release smoke environment (`release-smoke`)

OpenTofu stack for the **`release-smoke`** GitHub Actions environment: **`main`**-only deployment branch policy and environment secrets **`STAGING_USERNAME`**, **`STAGING_PASSWORD`**, and **`ROLLBAR_ACCESS_TOKEN`** (values sourced from Doppler **`ebwiki/stg`** at apply time).

It also manages the **`release-tags`** environment: one required reviewer, no admin bypass, **`main`** only. The release tags workflow refuses to run until that environment exists with those rules.

An EBWiki org admin runs **`make plan`** and **`make apply`** from a machine with Doppler access. **`make apply` writes secrets to GitHub**, so apply only after the plan has been reviewed.

## Prerequisites in ebwiki/infra

- **`STATE_PASSPHRASE`**
- **`GITHUB_TOKEN`**: token with permission to manage repository environments and Actions secrets on **EBWiki/EBWiki**

Staging smoke values are read from **`ebwiki/stg`** during plan/apply (never passed on the shell argv).

## Commands

```bash
make plan    # includes this stack after staging
make apply   # includes this stack after staging; writes GitHub environment secrets
make github-delete-repo-secrets              # dry run
make github-delete-repo-secrets CONFIRM=1    # after apply
```

After apply, the same admin runs **`make github-delete-repo-secrets`** for a dry run, then **`make github-delete-repo-secrets CONFIRM=1`**.

Deployment policy import ID format (integrations/github **6.4.0**): `repository:environment:policy_id`. See [repository_environment_deployment_policy import](https://github.com/integrations/terraform-provider-github/blob/v6.4.0/website/docs/r/repository_environment_deployment_policy.html.markdown#import).
