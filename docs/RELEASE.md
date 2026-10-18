# Release smoke check and rollback

Use these commands after deploying the Postgres search change to verify behavior and to roll back a bad release without ad hoc scripts.

## Post-deploy smoke check

The smoke check hits the running site over HTTP. It confirms the home page loads, search returns results for a known term, junk search returns zero results without error, and `/health` reports Postgres and Redis only (no Elasticsearch probe).

GitHub Actions runs `release:smoke_check` automatically when a deployment completes successfully (see `.github/workflows/release_smoke_check.yml`).

### When to run

Run after every staging or production deploy that includes the pg_search search path, before you announce the release or move traffic.

### Commands

**Staging** (HTTP basic auth uses `STAGING_USERNAME` and `STAGING_PASSWORD`, or set `RELEASE_SMOKE_BASIC_AUTH_USERNAME` and `RELEASE_SMOKE_BASIC_AUTH_PASSWORD`):

```bash
RELEASE_SMOKE_BASE_URL=https://staging.ebwiki.org \
  bin/rails release:smoke_check
```

Or pass the URL as a rake argument:

```bash
STAGING_USERNAME=... STAGING_PASSWORD=... \
  bin/rails 'release:smoke_check[https://staging.ebwiki.org]'
```

Alias:

```bash
bin/rails 'search:smoke[https://staging.ebwiki.org]'
```

**Production**:

```bash
RELEASE_SMOKE_BASE_URL=https://ebwiki.org \
  RELEASE_SMOKE_SEARCH_TERM=police \
  bin/rails release:smoke_check
```

Optional environment variables:

| Variable | Purpose |
| --- | --- |
| `RELEASE_SMOKE_BASE_URL` | Base URL when not passed as a rake argument |
| `RELEASE_SMOKE_SEARCH_TERM` | Query that should match at least one case (default `*`) |
| `RELEASE_SMOKE_BASIC_AUTH_*` | Override staging basic auth credentials |

Exit code **0** means all checks passed. Failures log JSON to `Rails.logger` and report through Rollbar when `ROLLBAR_ACCESS_TOKEN` is set.

Implementation: `lib/release/smoke_check.rb`, rake task in `lib/tasks/release.rake`.

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

Set the service (`ebwiki`), target environment label, deployment id to restore, and API token. Rollback uses Railway's public GraphQL `deploymentRollback` mutation (see [Manage Deployments](https://docs.railway.com/integrations/api/manage-deployments)).

```bash
export RELEASE_ROLLBACK_PLATFORM=railway
export RAILWAY_SERVICE=ebwiki
export RAILWAY_ENVIRONMENT=staging
export RAILWAY_ROLLBACK_DEPLOYMENT_ID=<previous-deployment-id>
export RAILWAY_TOKEN=<account-token>
bin/release-rollback
bin/release-rollback --execute --yes
```

`railway run` (if used for other tasks) executes on your local machine against the linked project, not inside the remote container.

Implementation: `lib/release/rollback.rb`, entrypoint `bin/release-rollback` (loads `lib/release` only, no full Rails boot).
