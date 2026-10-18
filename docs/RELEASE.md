# Release smoke check and rollback

Use these commands after deploying the Postgres search change to verify behavior and to roll back a bad release without ad hoc scripts.

## Post-deploy smoke check

The smoke check hits the running site over HTTP. It confirms the home page loads, search returns results for a known term, junk search returns zero results without error, and `/health` reports Postgres and Redis only (no Elasticsearch probe).

GitHub Actions can run `bin/release-smoke-check` when a GitHub **deployment** completes successfully (see `.github/workflows/release_smoke_check.yml`). Railway does not emit GitHub deployment events unless that integration is enabled in the Railway project, so the usual path is **Run workflow** in the Actions tab and choose **staging** or **production**. The workflow needs the repository secret `ROLLBAR_ACCESS_TOKEN` when Rollbar reporting is enabled.

### When to run

Run after every staging or production deploy that includes the pg_search search path, before you announce the release or move traffic.

### Commands

**Staging** (HTTP basic auth applies only to `staging.ebwiki.org`; export `STAGING_USERNAME` and `STAGING_PASSWORD` from Doppler config `ebwiki/stg`):

```bash
export STAGING_USERNAME=...
export STAGING_PASSWORD=...
RELEASE_SMOKE_BASE_URL=https://staging.ebwiki.org \
  bin/release-smoke-check
```

Or pass the URL as an argument (same script as the rake task):

```bash
bin/release-smoke-check https://staging.ebwiki.org
bin/rails 'release:smoke_check[https://staging.ebwiki.org]'
```

**Production**:

```bash
RELEASE_SMOKE_BASE_URL=https://ebwiki.org \
  RELEASE_SMOKE_SEARCH_TERM=police \
  bin/release-smoke-check
```

Optional environment variables:

| Variable | Purpose |
| --- | --- |
| `RELEASE_SMOKE_BASE_URL` | Base URL when not passed as a CLI argument |
| `RELEASE_SMOKE_ALLOWED_HOSTS` | Comma-separated hosts permitted (default `staging.ebwiki.org,ebwiki.org`) |
| `RELEASE_SMOKE_SEARCH_TERM` | Query that should match at least one case (default `*`) |
| `RELEASE_SMOKE_BASIC_AUTH_*` | Override staging basic auth credentials |
| `ROLLBAR_ACCESS_TOKEN` | Rollbar project token (required in the deployment workflow for error reporting) |
| `ROLLBAR_ENV` | Rollbar environment name (the GitHub deployment environment in CI) |

Exit code **0** means all checks passed. Failures log JSON to stderr and report through Rollbar when `ROLLBAR_ACCESS_TOKEN` is set.

Implementation: `lib/release/smoke_check.rb`, entrypoint `bin/release-smoke-check`, rake wrapper in `lib/tasks/release.rake`.

## One-command rollback

`bin/release-rollback` prints a plan by default (dry run). Pass `--execute` to run commands and `--yes` to skip the confirmation prompt. In CI or a pipe, `--execute` alone is refused unless `--yes` is also passed.

### Migrations

Rollback redeploys prior application code only. Do not run `db:rollback` for the generated `cases.tsv` column; removing it would break search.

### Heroku

Set the app name, review the plan, then execute:

```bash
export HEROKU_APP_NAME=ebwiki
bin/release-rollback
bin/release-rollback --execute --yes
```

Planned command: `heroku releases:rollback -a $HEROKU_APP_NAME`

### Railway staging

Set the service (`ebwiki`), target environment label, deployment id to restore, and a Railway API token. Prefer a **project- or workspace-scoped** token from [Railway account tokens](https://railway.com/account/tokens) with access to the EBWiki staging project only; avoid a full account token unless no narrower scope is available. Rollback uses Railway's public GraphQL `deploymentRollback` mutation (see [Manage Deployments](https://docs.railway.com/integrations/api/manage-deployments)).

```bash
export RELEASE_ROLLBACK_PLATFORM=railway
export RAILWAY_SERVICE=ebwiki
export RAILWAY_ENVIRONMENT=staging
export RAILWAY_ROLLBACK_DEPLOYMENT_ID=<previous-deployment-id>
export RAILWAY_TOKEN=<project-or-workspace-token>
bin/release-rollback
bin/release-rollback --execute --yes
```

`railway run` (if used for other tasks) executes on your local machine against the linked project, not inside the remote container.

Implementation: `lib/release/rollback.rb`, entrypoint `bin/release-rollback` (loads `lib/release` only, no full Rails boot).
