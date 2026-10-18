This guide explains how EBWiki is deployed today.

# Table of Contents

1. [Where EBWiki runs](#where-ebwiki-runs)
2. [Deploy staging](#deploy-staging)
3. [Gate deploys on CI](#gate-deploys-on-ci)
4. [Docker image publish on main](#docker-image-publish-on-main)
5. [Why GitHub pushes did not deploy (verified)](#why-github-pushes-did-not-deploy-verified)
6. [Handling the database](#handling-the-database)
7. [After a deploy](#after-a-deploy)

## Where EBWiki runs

- **Staging:** the Rails app on Railway (project **ebwiki**, service **ebwiki**) serves **staging.ebwiki.org** with Doppler **ebwiki/stg**, behind HTTP basic auth. Railway names the only app environment **`production`** internally; that slug is not public production traffic. [STAGING_RAILWAY.md](STAGING_RAILWAY.md) covers the build and health checks.
- **Public production:** **ebwiki.org** is **not** on Railway. [https://ebwiki.org/up](https://ebwiki.org/up) serves the Cloudflare maintenance page (HTTP 200, no `deploy_rev`). Staging health with JSON is on the Railway default host or **staging.ebwiki.org** after DNS is correct (for example `Accept: application/json` on the `*.up.railway.app` host showed `deploy_rev` **8278d169** on 2026-10-18).

The old Heroku app is gone. Do not use the Heroku CLI for EBWiki.

**HSTS:** the zone uses `includeSubDomains`. Until Railway issues a certificate for **staging.ebwiki.org**, browsers may refuse HTTPS on staging even when HTTP basic auth would otherwise work. DNS-only staging CNAME (grey cloud) is required so Railway can verify the host and finish certificate issuance.

## Deploy staging

1. Open a pull request against `main`. CI must pass and a maintainer must approve it.
2. Merge to `main`. Railway should build `Dockerfile.railway` and deploy service **ebwiki** when the GitHub deployment trigger is connected and checks pass.
3. Railway's pre-deploy step runs `bash release-tasks.sh`, which runs `rails db:migrate`. The deploy health check is `GET /up`.

Staging DNS and the Railway custom domain are managed with OpenTofu in `infra/staging`. `make plan` writes plans for the GitHub and staging stacks and applies nothing. `make apply` applies the reviewed plans (GitHub stack first, then staging) and needs typed confirmation on each apply script. Staging apply runs DNS preflight before the DB snapshot and Railway config apply. See [RELEASE.md](RELEASE.md).

## Gate deploys on CI

The **CI** workflow runs on every push to `main` (including **RSpec**). **Wait for CI** is enforced in code: staging plan runs a read-only GitHub autodeploy trigger preflight; staging apply runs **`infra_railway_ensure_deployment_trigger`**, which sets **`checkSuites: true`** on the **EBWiki/EBWiki** **main** trigger via Railway GraphQL **`deploymentTriggerUpdate`**, with read-back.

Only workflows that run on **push** to **main** can gate deploys. **Dependabot** auto-merge commits using the **`GITHUB_TOKEN`** do not trigger [Publish Docker Image](../.github/workflows/publish_docker_image.yml) (that workflow listens for human **`GITHUB_ACTOR`** pushes, not the Dependabot bot token).

## Docker image publish on main

Every normal merge to **main** also runs [Publish Docker Image](../.github/workflows/publish_docker_image.yml), which builds and pushes **`ebwiki/ebwiki:latest`** (public on Docker Hub). That job is independent of Railway staging deploys but counts toward GitHub check suites when **Wait for CI** is enabled.

## Why GitHub pushes did not deploy (verified)

**Symptom:** live staging **`deploy_rev`** stayed **8278d169** (deployment **98b66eec-8d76-4447-849a-8edb27867710**, 2026-10-11 6:02pm ET) while **82270bc0** and **912745b2** on **main** had green GitHub checks ([run 38265660321](https://github.com/EBWiki/EBWiki/actions/runs/38265660321), [run 38289919391](https://github.com/EBWiki/EBWiki/actions/runs/38289919391)) but **Railway created no deployment at all** (not WAITING, not SKIPPED).

**Cause:** GitHub autodeploy never fired. Source **EBWiki/EBWiki** **main** is declared in `.railway/railway.ts`, but the service was never connected through the **Railway GitHub App** (workspace tokens cannot attach repo source; see `infra/staging/railway.tf` lifecycle ignores and PR #4545). Oct 11 deploys line up with **`railway config apply`**, not GitHub push hooks. Public-repo autodeploy also requires a project member with contributor access ([Railway docs](https://docs.railway.com/deployments/github-autodeploys)).

**One-time human step (Mark):**

1. Install the **Railway GitHub App** on the **EBWiki** org with access to **EBWiki/EBWiki** (or run **`scripts/railway-github-access.sh`** after install to verify org installation and repo visibility).
2. In Railway service **ebwiki** → **Source**, connect **EBWiki/EBWiki** branch **main** (the API token cannot do this).
3. Run **`make plan`** (read-only trigger preflight must pass) then **`make apply`** (sets **`checkSuites: true`**).
4. Verify JSON **`/up`** on the Railway host shows **`912745b2`** (or newer), then confirm the next **main** push creates a Railway deployment.

`scripts/staging-plan.sh` fails closed when the GitHub deployment trigger is missing, pointed at the wrong repo or branch, or has **`checkSuites: false`**.

## Handling the database

Migrations run on every deploy through `release-tasks.sh`. Before a risky migration, take a Postgres snapshot to the R2 bucket:

```
make snapshot
```

That runs `scripts/staging-db-snapshot.sh` under Doppler `ebwiki/infra`, so no credentials are typed by hand.

Case search uses Postgres full-text search (`cases.tsv`). After restoring a dump that predates that column, run `bundle exec rails db:migrate` against the restored database so the generated `tsv` column and GIN index exist. No Elasticsearch reindex is required.

## After a deploy

Run the post-deploy smoke check and, if needed, the one-command rollback described in [RELEASE.md](RELEASE.md). Apply the GitHub stack (`make apply`, GitHub step first) before using the **Release smoke check** workflow so the **`release-smoke`** environment exists.
