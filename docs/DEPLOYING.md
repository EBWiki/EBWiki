This guide explains how EBWiki is deployed today.

# Table of Contents

1. [Where EBWiki runs](#where-ebwiki-runs)
2. [Deploy staging](#deploy-staging)
3. [Gate deploys on CI](#gate-deploys-on-ci)
4. [Handling the database](#handling-the-database)
5. [After a deploy](#after-a-deploy)

## Where EBWiki runs

- **Staging:** the Rails app runs on Railway (project **ebwiki**, service **ebwiki**) at **staging.ebwiki.org**, behind HTTP basic auth. [STAGING_RAILWAY.md](STAGING_RAILWAY.md) covers the build, health checks and the Doppler `ebwiki/stg` variable names.
- **Production:** **ebwiki.org** serves the Cloudflare maintenance page. Moving production traffic to the Rails app is a separate release with its own review.

The old Heroku app is gone. Do not use the Heroku CLI for EBWiki.

## Deploy staging

1. Open a pull request against `main`. CI must pass and a maintainer must approve it.
2. Merge to `main`. Railway builds `Dockerfile.railway` from `main` and deploys service **ebwiki**.
3. Railway's pre-deploy step runs `bash release-tasks.sh`, which runs `rails db:migrate`. The deploy health check is `GET /up`.

Staging DNS and the Railway custom domain are managed with OpenTofu in `infra/staging`. `make plan` writes plans for the staging and GitHub stacks and applies nothing. `make apply` applies the reviewed plans and needs a maintainer's go. The staging steps of both run a read-only DNS preflight first and stop when the staging record is wrong. See [RELEASE.md](RELEASE.md).

## Gate deploys on CI

The CI workflow also runs on every push to `main`. Turn on **Wait for CI** in the Railway service settings (Settings, Source) so Railway holds each staging deploy until the GitHub Actions checks on that commit pass, and skips it when one fails. Railway does not read this setting from `railway.toml`, so it is a dashboard setting owned by a project admin.

## Handling the database

Migrations run on every deploy through `release-tasks.sh`. Before a risky migration, take a Postgres snapshot to the R2 bucket:

```
make snapshot
```

That runs `scripts/staging-db-snapshot.sh` under Doppler `ebwiki/infra`, so no credentials are typed by hand.

Case search uses Postgres full-text search (`cases.tsv`). After restoring a dump that predates that column, run `bundle exec rails db:migrate` against the restored database so the generated `tsv` column and GIN index exist. No Elasticsearch reindex is required.

## After a deploy

Run the post-deploy smoke check and, if needed, the one-command rollback described in [RELEASE.md](RELEASE.md).
