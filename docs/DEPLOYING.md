This guide explains how EBWiki is deployed today.

# Table of Contents

1. [Where EBWiki runs](#where-ebwiki-runs)
2. [Deploy staging](#deploy-staging)
3. [Gate deploys on CI](#gate-deploys-on-ci)
4. [Docker image publish on main](#docker-image-publish-on-main)
5. [Why GitHub pushes did not deploy](#why-github-pushes-did-not-deploy)
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

Staging DNS and the Railway custom domain are managed with OpenTofu in `infra/staging`. `make plan` writes plans for the GitHub and staging stacks and applies nothing. `make apply` applies the reviewed plans (GitHub stack first, then staging) and needs typed confirmation on each apply script. Staging apply runs every read-only gate first (token type, saved-plan gates, DNS preflight) and only then takes the DB snapshot, turns on Wait for CI, applies the Railway config and runs `tofu apply`. See [RELEASE.md](RELEASE.md).

## Gate deploys on CI

The **CI** workflow runs on every push to `main` (including **RSpec**). Railway's **Wait for CI** setting is the `checkSuites` flag on the service's GitHub deployment trigger, and it is set in code:

- `make plan` reads the trigger (read only). It fails when the trigger is missing or points at another repo or branch, and reports `checkSuites: false` as pending.
- `make apply` calls Railway GraphQL `deploymentTriggerUpdate` with `checkSuites: true` when the flag is off, then lists the triggers again and fails unless the flag reads back true. It writes nothing when the flag is already on.

With Wait for CI on, Railway holds a deploy until every GitHub check suite on that commit finishes, and skips it if one fails. Two workflows run on every push to `main`: **CI** and [Publish Docker Image](../.github/workflows/publish_docker_image.yml). A failing Docker Hub publish therefore also skips the staging deploy.

GitHub does not start workflows for events made with the `GITHUB_TOKEN`. Dependabot pull requests are merged by [dependabot-auto-merge.yml](../.github/workflows/dependabot-auto-merge.yml) with that token, so those merges run no push workflows on `main`, and Railway has no check suite to wait for. **Unverified:** whether Railway then deploys such a commit at once or waits; check the next Dependabot merge.

## Docker image publish on main

Every push to **main** runs [Publish Docker Image](../.github/workflows/publish_docker_image.yml), which builds and pushes **`ebwiki/ebwiki:latest`** and **`ebwiki/ebwiki:<run number>`** to Docker Hub, where the image is public. Railway staging does not use that image (it builds `Dockerfile.railway`), but the workflow counts as a check suite for Wait for CI.

## Why GitHub pushes did not deploy

**Symptom (read from Railway on 2026-10-18):** the live staging deployment is still **98b66eec-8d76-4447-849a-8edb27867710** at **8278d169**, created 2026-10-11 6:02pm ET by a manual run, not by a push. **82270bc0** and **912745b2** reached **main** with green checks ([run 38265660321](https://github.com/EBWiki/EBWiki/actions/runs/38265660321), [run 38289919391](https://github.com/EBWiki/EBWiki/actions/runs/38289919391)), and Railway created no deployment for either, not even a WAITING or SKIPPED one.

**Cause (very likely):** the service config names **EBWiki/EBWiki** on **main** as its source, but that source was never connected through the Railway GitHub App, so GitHub pushes never reach Railway. The workspace token cannot connect a repo (see `infra/staging/railway.tf` and PR #4545). **Unverified:** the trigger list itself; `make plan` now reads it and fails while the trigger is missing.

**One-time step for an EBWiki org admin:**

1. Install the **Railway GitHub App** on the **EBWiki** org with access to **EBWiki/EBWiki**. `scripts/railway-github-access.sh` then confirms the org installation can see the repo.
2. In the Railway service **ebwiki**, open Settings, then Source, and connect **EBWiki/EBWiki** on branch **main**. The API token cannot do this.
3. Run `make plan` (the trigger check must pass), then `make apply` (turns on Wait for CI).
4. Confirm the next push to **main** creates a Railway deployment, and that `/up` on the Railway host reports that commit.

## Handling the database

Migrations run on every deploy through `release-tasks.sh`. Before a risky migration, take a Postgres snapshot to the R2 bucket:

```
make snapshot
```

That runs `scripts/staging-db-snapshot.sh` under Doppler `ebwiki/infra`, so no credentials are typed by hand.

Case search uses Postgres full-text search (`cases.tsv`). After restoring a dump that predates that column, run `bundle exec rails db:migrate` against the restored database so the generated `tsv` column and GIN index exist. No Elasticsearch reindex is required.

## After a deploy

Run the post-deploy smoke check and, if needed, the one-command rollback described in [RELEASE.md](RELEASE.md). The **Release smoke check** and **Release tags** workflows refuse to run until `make apply` has created their protected environments (`release-smoke` and `release-tags`).
