# EBWiki Rails staging on Railway

This document describes how the **Rails** EBWiki archive deploys to Railway from
`main`, how it differs from [hanami.ebwiki.org](http://hanami.ebwiki.org), and
which environment variable **names** belong in Doppler config `ebwiki/stg`
(values live only in Doppler and Railway — never commit them).

Linear: [GKT-460](https://linear.app/gkt/issue/GKT-460).

## Deploy path

1. Merge-ready changes land on GitHub `main`.
2. Railway watches `main` on `EBWiki/EBWiki` and builds with
   **`Dockerfile.railway`** (see `railway.toml`).
3. **Pre-deploy:** `bundle exec rails db:prepare` (creates the DB schema on first
   deploy and applies migrations afterward). Other deploy paths may still use
   `release-tasks.sh` (`rails db:migrate`).
4. **Start:** `bundle exec puma -C config/puma.rb`.
5. **Health check:** HTTP `GET /up` (Rails 8.1 health endpoint).
6. **Revision check:** `/up` JSON may include `deploy_rev` when
   `DEPLOY_REV` or `RAILWAY_GIT_COMMIT_SHA` is set. Every HTML page also
   includes an HTML comment `<!-- deploy_rev: … -->` in the footer for the same
   SHA.

The root **`Dockerfile`** is unchanged for the Docker Hub workflow
(`.github/workflows/publish_docker_image.yml`). Only Railway uses
`Dockerfile.railway`.

Database config is **not** committed: the image copies
`config/database.railway.yml` to `config/database.yml` at build time so staging
boots from **`DATABASE_URL`** only. The image installs **PostgreSQL client 17**
(PGDG) so `pg_dump` matches Postgres 17 features in `db/structure.sql` (for
example `SET transaction_timeout`).

## How this host differs from hanami.ebwiki.org

| | **Rails staging (this doc)** | **hanami.ebwiki.org** |
| --- | --- | --- |
| App | Full Rails 7 archive on `main` | Hanami 3 sibling app (`apps/hanami`) |
| Railway project | EBWiki staging Rails service (target: staging.ebwiki.org) | `ebwiki-hanami-staging` |
| Build file | `Dockerfile.railway` at repo root | `apps/hanami/Dockerfile` |
| Role | Full Rails archive: cases, search, mailers, admin, etc. | Public read-focused slice; Rails still owns many write paths |

Both can share Postgres patterns via `DATABASE_URL`, but they are **separate**
Railway services and codebases.

## Doppler mapping (`ebwiki/stg`)

Set each name below in Railway (or sync from Doppler `ebwiki/stg`). Names match
1:1 unless noted. For local development, the same names (with comments on
required vs optional) are grouped in `.env.example`.

### Core runtime

| Variable | Purpose |
| --- | --- |
| `RAILS_ENV` | Must be `staging` for this service |
| `RACK_ENV` | Same as `RAILS_ENV` |
| `SECRET_KEY_BASE` | Rails signed cookies / secrets |
| `DATABASE_URL` | Postgres (sole DB config at runtime) |
| `REDIS_URL` | Cache / Action Cable (see `config/environments/staging.rb`) |
| `PORT` | Injected by Railway; Puma binds via `config/puma.rb` |
| `HOST` | Public hostname (e.g. staging.ebwiki.org) for host authorization |
| `RAILS_LOG_TO_STDOUT` | Log to Railway |
| `RAILS_SERVE_STATIC_FILES` | Serve precompiled assets from the container |

### Deploy visibility

| Variable | Purpose |
| --- | --- |
| `DEPLOY_REV` | Optional explicit git SHA for `/up` and footer |
| `RAILWAY_GIT_COMMIT_SHA` | Auto-set by Railway when deploying from GitHub |

### AWS / uploads

| Variable | Purpose |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | S3 / CarrierWave (optional on staging: file storage when unset) |
| `AWS_SECRET_KEY_ID` | S3 secret (note `_KEY_ID` suffix in this app) |
| `S3_BUCKET` | Upload bucket |
| `FOG_DIRECTORY` | Sitemap / Fog directory name |

### Search

| Variable | Purpose |
| --- | --- |
| `ELASTICSEARCH_URL` | Preferred Elasticsearch URL |
| `SEARCHBOX_URL` | Legacy fallback (`config/initializers/searchbox.rb`) |

### Mail / marketing

| Variable | Purpose |
| --- | --- |
| `MAILCHIMP_API_KEY` | Mailchimp API |
| `MAILCHIMP_LIST_ID` | List for subscriptions |
| `MAILCHIMP_LINK` | Newsletter signup link in header |

### Analytics / maps

| Variable | Purpose |
| --- | --- |
| `GOOGLE_ANALYTICS_MEASUREMENT_ID` | gtag.js in layout |
| `GOOGLE_TAG_MANAGER_ID` | GTM noscript iframe |
| `GOOGLE_MAPS_API_KEY` | Geocoder |

### Observability / misc

| Variable | Purpose |
| --- | --- |
| `ROLLBAR_ACCESS_TOKEN` | Error reporting |
| `ROLLBAR_ENV` | Rollbar environment label |
| `EBWIKI_SITEMAP_URL` | Sitemap URL reference |
| `RECAPTCHA_SITE_KEY` | reCAPTCHA site key (if enabled) |
| `RECAPTCHA_SECRET_KEY` | reCAPTCHA secret |

### Railway-injected (read-only)

Railway adds names such as `RAILWAY_ENVIRONMENT`, `RAILWAY_PUBLIC_DOMAIN`,
`RAILWAY_SERVICE_*`, and related `RAILWAY_*` variables. Do not duplicate them in
Doppler unless you intentionally override; they are not part of `ebwiki/stg`.

## Operator checklist

- [ ] Railway service: repo `EBWiki/EBWiki`, branch `main`, Dockerfile path
  `Dockerfile.railway`.
- [ ] Variables synced from Doppler `ebwiki/stg` (names above).
- [ ] Health check path `/up` returns **200**.
- [ ] After deploy, `curl -sS -H 'Accept: application/json' https://<host>/up`
  shows `deploy_rev` matching the deployed `main` commit.
