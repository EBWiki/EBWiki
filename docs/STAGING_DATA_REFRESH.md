# Refreshing staging with a copy of the production data

Linear: [GKT-1816](https://linear.app/gkt/issue/GKT-1816/load-a-copy-of-live-ebwiki-data-onto-staging-for-the-ui-refresh)

Staging (https://staging.ebwiki.org, behind HTTP auth) should run on a copy of
the real case data, with personal details removed. Sample data hides the messy
cases a UI has to handle: missing photos, long names, unknown causes of death.

**Wiping, resetting, reseeding or replacing staging or production data needs
Mark's explicit go every time.** Nothing in a deploy may do it.

## Where things live (checked Nov 1, 2026)

| What | Where |
| --- | --- |
| staging.ebwiki.org | Railway project `ebwiki`, service `ebwiki`, runs `RAILS_ENV=staging` with Doppler `ebwiki/stg` |
| Staging database | Railway project `ebwiki`, service `Postgres` (`postgres.railway.internal`, database `ebwiki`), no public port |
| Production copy (source) | Neon project `ebwiki-review`, database `ebwiki_review`. It holds the last real production snapshot (Heroku, Sept 1, 2020) plus three "E2E" test cases added on Sept 6, 2026 |
| ebwiki.org | Cloudflare maintenance page; there is no live production database today |

When a live production database exists again, point `SOURCE_DATABASE_URL` at a
read-only user on it and add its host to `PRODUCTION_DB_HOSTS`.

## What the refresh does

`script/refresh_staging_from_production`:

1. Refuses unless the target host and database name match the expected staging
   ones, the target is not the source, and the target is not listed in
   `PRODUCTION_DB_HOSTS`.
2. Asks you to type `replace <staging host>/<staging db>` (or reads it from
   `CONFIRM_REFRESH` when not run from a terminal).
3. Takes a rollback copy of current staging into a temp folder that is deleted
   when the script exits.
4. Streams `pg_dump` from the source (read-only transaction) straight into
   `psql` on staging. No dump file is written. Sessions, visits and analytics
   events are copied as empty tables.
5. Runs `script/refresh_staging_scrub.sql` on staging:
   - every user email becomes `user<id>@example.invalid`
   - every password becomes a random, unknown bcrypt hash, so no one can log in
   - reset and confirmation tokens, sign-in IPs and users' home coordinates are cleared
   - edit-history IPs are cleared, user records in edit history are emptied, and
     any email address left in edit history becomes `redacted@example.invalid`
   - private messages (mailboxer tables), sessions, visits and analytics events are emptied
6. Checks that the case count matches the source, no real emails remain and no
   tokens or IPs remain. If any check fails, it puts the rollback copy back.

Public case data (cases, subjects, agencies, links, comments) is not changed.
After the refresh nobody can log in to staging. Create a staging-only admin by
hand if you need one.

## How to run it

The staging database has no public port, so run the script inside Railway's
private network, from a temporary service in the `ebwiki` project:

1. Create a service from the `postgres:17` image (matches the server version).
2. Set its variables, never in the start command:
   - `TARGET_DATABASE_URL=postgresql://${{Postgres.POSTGRES_USER}}:${{Postgres.POSTGRES_PASSWORD}}@postgres.railway.internal:5432/ebwiki`
   - `SOURCE_DATABASE_URL` = the Neon direct (non-pooler) URL for `ebwiki_review`
   - `STAGING_DB_HOST=postgres.railway.internal`, `STAGING_DB_NAME=ebwiki`
   - `PRODUCTION_DB_HOSTS` = the source host plus any production host
   - `CONFIRM_REFRESH=replace postgres.railway.internal/ebwiki`
3. Start it with this script and the scrub SQL copied in, read the deploy logs,
   then **delete the service** so the source URL and the rollback copy go with it.
4. Restart the staging `ebwiki` deployment (a restart, not a redeploy) so Rails
   drops its cached database types.
5. Check https://staging.ebwiki.org through HTTP auth: the home page count
   matches the source, and a few case pages open. Without the login every page,
   including `/robots.txt`, returns 401.

## Mail safety

`config/environments/staging.rb` sets `action_mailer.delivery_method = :test`,
so staging never sends email, including Mailboxer notifications. The staging
service has no SMTP, SendGrid, Resend or Mailchimp API key. Keep it that way.

## Guards against silent wipes

- `release-tasks.sh` (the pre-deploy step) only runs `db:migrate`.
- `staging:sample_content` needs `CONFIRM_STAGING_SAMPLE_CONTENT=add-sample-cases`
  and is never called from a deploy.
- `db/seeds.rb` aborts outside development and test unless
  `CONFIRM_SEED_ENVIRONMENT` equals the current `RAILS_ENV`.
- `config.active_record.protected_environments` includes `staging`, so
  `db:drop`, `db:reset`, `db:purge` and `db:schema:load` refuse unless
  `DISABLE_DATABASE_ENVIRONMENT_CHECK=1` is set on purpose.
- `spec/deploy_commands_spec.rb` fails CI if a seed, reset or sample step shows
  up in `release-tasks.sh`, `Procfile`, `railway.toml` or `.railway/railway.ts`.
