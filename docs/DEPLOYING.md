This guide explains how EBWiki is deployed today.

# Table of Contents

1. [Where EBWiki runs](#where-ebwiki-runs)
2. [Deploy staging](#deploy-staging)
3. [Gate deploys on CI](#gate-deploys-on-ci)
4. [Docker image publish on main](#docker-image-publish-on-main)
5. [Why merges can stall on Railway](#why-merges-can-stall-on-railway)
6. [Handling the database](#handling-the-database)
7. [After a deploy](#after-a-deploy)

## Where EBWiki runs

- **Staging:** the Rails app runs on Railway (project **ebwiki**, service **ebwiki**) at **staging.ebwiki.org**, behind HTTP basic auth. [STAGING_RAILWAY.md](STAGING_RAILWAY.md) covers the build, health checks and the Doppler `ebwiki/stg` variable names.
- **Production:** **ebwiki.org** serves the Cloudflare maintenance page. Moving production traffic to the Rails app is a separate release with its own review.

The old Heroku app is gone. Do not use the Heroku CLI for EBWiki.

**HSTS:** the zone uses `includeSubDomains`. Until Railway issues a certificate for **staging.ebwiki.org**, browsers may refuse HTTPS on staging even when HTTP basic auth would otherwise work. DNS-only staging CNAME (grey cloud) is required so Railway can verify the host and finish certificate issuance.

## Deploy staging

1. Open a pull request against `main`. CI must pass and a maintainer must approve it.
2. Merge to `main`. Railway builds `Dockerfile.railway` from `main` and deploys service **ebwiki** when its GitHub deployment trigger fires and any configured CI gates pass.
3. Railway's pre-deploy step runs `bash release-tasks.sh`, which runs `rails db:migrate`. The deploy health check is `GET /up`.

Staging DNS and the Railway custom domain are managed with OpenTofu in `infra/staging`. `make plan` writes plans for the GitHub and staging stacks and applies nothing. `make apply` applies the reviewed plans (GitHub stack first, then staging) and needs typed confirmation on each apply script. Staging apply runs DNS preflight before the DB snapshot and Railway config apply. See [RELEASE.md](RELEASE.md).

## Gate deploys on CI

The **CI** workflow runs on every push to `main`. **Wait for CI** is not a dashboard-only setting: `make apply` on staging runs `infra_railway_ensure_deployment_trigger`, which sets **`checkSuites: true`** on the GitHub **main** deployment trigger through Railway GraphQL **`deploymentTriggerUpdate`**, then read-backs the flag. Staging plan runs a read-only check and fails if **checkSuites** is still false.

When **checkSuites** is true, Railway holds each deploy until GitHub reports passing check suites for that commit. Workflows that run on push to **main** (including **CI**, **Publish Docker Image**, and path-filtered infra workflows when touched) participate in that gate. A failing required check blocks the deploy; skipped jobs depend on branch protection and Railway's GitHub app integration.

## Docker image publish on main

Every merge to **main** also runs [Publish Docker Image](../.github/workflows/publish_docker_image.yml), which builds and pushes **`ebwiki/ebwiki:latest`** (public on Docker Hub). That job is independent of Railway staging deploys but still counts toward GitHub check suites when **Wait for CI** is enabled.

## Why merges can stall on Railway

**Verified cause (repo + Railway API contract, Oct 2026):** service **ebwiki** autodeploys from GitHub **main** through a **DeploymentTrigger** (see `.railway/railway.ts` and `railway.toml`). When **`checkSuites`** is true on that trigger, Railway will not deploy until GitHub posts successful check suites for the commit.

Between 2026-10-11 and the CI fix on this branch, **`ci.yml` did not run on push to `main`** (only on `pull_request`), while live **`/up`** stayed on deploy revision **8278d169** from Oct 11. Commits **82270bc0** and **912745b2** on **main** therefore had no **CI** check suite for Railway to wait on, so autodeploy never started even though the trigger remained on **main**. Enabling **CI** on push to **main** plus idempotent **`checkSuites: true`** in staging apply unblocks future merges. If deploys stall again, inspect the trigger with staging plan (read-only) and the GitHub checks tab for that commit.

## Handling the database

Migrations run on every deploy through `release-tasks.sh`. Before a risky migration, take a Postgres snapshot to the R2 bucket:

```
make snapshot
```

That runs `scripts/staging-db-snapshot.sh` under Doppler `ebwiki/infra`, so no credentials are typed by hand.

Case search uses Postgres full-text search (`cases.tsv`). After restoring a dump that predates that column, run `bundle exec rails db:migrate` against the restored database so the generated `tsv` column and GIN index exist. No Elasticsearch reindex is required.

## After a deploy

Run the post-deploy smoke check and, if needed, the one-command rollback described in [RELEASE.md](RELEASE.md). Apply the GitHub stack (`make apply`, GitHub step first) before using the **Release smoke check** workflow so the **`release-smoke`** environment exists.
