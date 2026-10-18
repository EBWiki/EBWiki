# Release smoke check and rollback

Use these commands after deploying the Postgres search change (PR #4410) to verify behavior and to roll back a bad release without ad hoc scripts.

## Post-deploy smoke check

The smoke check hits the running site over HTTP. It confirms the home page loads, search returns results for a known term, junk search returns zero results without error, and `/health` reports Postgres and Redis only (no Elasticsearch probe).

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

Exit code **0** means all checks passed. Failures log JSON to `Rails.logger` and report through Rollbar (and Sentry when the gem is present).

Implementation: `lib/release/smoke_check.rb`, rake task in `lib/tasks/release.rake`.

## One-command rollback

`bin/release-rollback` prints a plan by default (dry run). Pass `--execute` to run commands and `--yes` to skip the confirmation prompt.

### Migrations and PR #4410

This pull request does not add new migrations. The `cases.tsv` column is additive and safe to leave in place when rolling back application code. Default rollback is **redeploy only**. Pass `--with-migration-down` only when you intentionally need to run `db:rollback STEP=1` before redeploying (not required for the pg_search landing).

### Heroku

Set the app name, review the plan, then execute:

```bash
export HEROKU_APP_NAME=ebwiki
bin/release-rollback
bin/release-rollback --execute --yes
```

Planned command: `heroku releases:rollback -a $HEROKU_APP_NAME`

With migration down (unusual for this release):

```bash
bin/release-rollback --execute --yes --with-migration-down
```

### Railway staging

Set the service and the deployment id to restore (from `railway deployment list`):

```bash
export RELEASE_ROLLBACK_PLATFORM=railway
export RAILWAY_SERVICE=ebwiki-web
export RAILWAY_ROLLBACK_DEPLOYMENT_ID=<previous-deployment-id>
bin/release-rollback
bin/release-rollback --execute --yes
```

Planned command: `railway redeploy --deployment $RAILWAY_ROLLBACK_DEPLOYMENT_ID --service $RAILWAY_SERVICE`

Implementation: `lib/release/rollback.rb`, entrypoint `bin/release-rollback`.
