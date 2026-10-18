# Release smoke check and rollback

Use these commands after deploying the Postgres search change to Railway staging. Production at ebwiki.org stays on the Cloudflare maintenance worker until a separate release.

## What this release covers

This change ships to **Railway staging only** (service **ebwiki**, public hostname **staging.ebwiki.org**). It does not take production traffic on ebwiki.org.

## Deploy staging (Railway)

Auto-build from GitHub is declared in `.railway/railway.ts`: repository **EBWiki/EBWiki**, branch **main**, Dockerfile **Dockerfile.railway**, health check **/up**. A merge to **main** triggers a new deploy of service **ebwiki**. The CI workflow also runs on push to **main**, so the Railway **Wait for CI** service setting can hold each deploy until CI passes; see [DEPLOYING.md](DEPLOYING.md#gate-deploys-on-ci). **Unverified:** whether Wait for CI is turned on for the service.

Manual redeploy if needed (from a machine with Railway CLI and project access). Use it only for a commit that already passed CI on **main**; a manual redeploy does not wait for CI:

```bash
railway redeploy --service ebwiki
```

OpenTofu for DNS and Railway custom domain (includes read-only DNS preflight before plan):

```bash
make plan    # staging and GitHub stacks; writes plan files, applies nothing
make apply   # applies the reviewed plans, only after a maintainer approves
```

Staging DNS: Cloudflare CNAME **staging.ebwiki.org** points at the Railway custom-domain target with **DNS only** (grey cloud), and the Railway verification TXT record **_railway-verify.staging.ebwiki.org** stays in place. OpenTofu sets `proxied = false` on the CNAME. DNS only lets Railway issue and renew its own certificate for the host without depending on the zone's Cloudflare SSL mode. Railway also supports the proxied setup with SSL mode Full; staging gives up Cloudflare's proxy features, which is acceptable because staging sits behind HTTP basic auth.

`scripts/staging-dns-preflight.sh` is read only and fails closed. Before the plan it requires exactly one staging CNAME pointing at a Railway target, a boolean proxied flag, and the verification TXT record. After the plan, and again before apply, it requires the planned CNAME to be DNS only and to point at a Railway target.

Current state, read from Railway and public DNS on 2026-10-18: **staging.ebwiki.org** is attached as a custom domain to service **ebwiki** in environment **production**, but Railway reports it as not verified, with its certificate still issuing. Railway expects the CNAME to point at its custom-domain target and sees that record as unset, because the live Cloudflare record is proxied and public DNS returns Cloudflare addresses instead. The verification TXT record is present. Requests reach Railway's edge and get its fallback 404 ("Application not found"). Making the record DNS only should let Railway see the CNAME, verify the domain and issue the certificate. **Unverified:** that the 404 clears once the DNS change is applied.

## Post-deploy smoke check

The smoke check hits staging over HTTP. It confirms the home page loads, search returns results for a known term, junk search returns zero results without error, and `/health` reports Postgres and Redis only (no Elasticsearch probe).

Run the **Release smoke check** workflow manually from the GitHub Actions tab on **`main`**. The job uses environment **`release-smoke`** (branch **main** only) with **`STAGING_USERNAME`**, **`STAGING_PASSWORD`**, and **`ROLLBAR_ACCESS_TOKEN`** from Doppler **ebwiki/stg** (provisioned by `infra/github/`). The environment requires reviewer approval and does not allow admin bypass. After apply, run **`make github-delete-repo-secrets`** for a dry run, then **`make github-delete-repo-secrets CONFIRM=1`** to remove repository-level copies of those names.

Rollbar receives smoke and rollback failures when **`ROLLBAR_ACCESS_TOKEN`** is set. That token is an accepted error tracker for release automation (configured through Doppler and GitHub environment secrets, not committed to the repo).

### When to run

Run after every staging deploy that includes the pg_search search path, before you announce the release.

### Commands

**Staging** (HTTP basic auth on **staging.ebwiki.org**; export **`STAGING_USERNAME`** and **`STAGING_PASSWORD`** from Doppler **ebwiki/stg**):

```bash
export STAGING_USERNAME=...
export STAGING_PASSWORD=...
RELEASE_SMOKE_BASE_URL=https://staging.ebwiki.org \
  bin/release-smoke-check
```

Or pass the URL as an argument:

```bash
bin/release-smoke-check https://staging.ebwiki.org
bin/rails 'release:smoke_check[https://staging.ebwiki.org]'
```

Optional environment variables:

| Variable | Purpose |
| --- | --- |
| `RELEASE_SMOKE_BASE_URL` | Base URL when not passed as a CLI argument |
| `RELEASE_SMOKE_ALLOWED_HOSTS` | Comma-separated hosts permitted (default `staging.ebwiki.org`) |
| `RELEASE_SMOKE_SEARCH_TERM` | Query that should match at least one case (default `*`) |
| `RELEASE_SMOKE_BASIC_AUTH_*` | Override staging basic auth credentials |
| `ROLLBAR_ACCESS_TOKEN` | Rollbar project token (**release-smoke** environment secret in CI) |
| `ROLLBAR_ENV` | Rollbar environment name (CI uses **staging**) |

Exit code **0** means all checks passed. Failures log JSON to stderr and report through Rollbar when configured.

Implementation: `lib/release/smoke_check.rb`, entrypoint `bin/release-smoke-check`, rake wrapper in `lib/tasks/release.rake`.

## One-command rollback (Railway staging)

`bin/release-rollback` prints a plan by default (dry run). Pass **`--execute`** to run commands and **`--yes`** to skip the confirmation prompt. In CI or a pipe, **`--execute`** alone is refused unless **`--yes`** is also passed.

### Release tags (document only; do not create from automation)

| Tag | Commit | Role |
| --- | --- | --- |
| **v2026.10.18-pre-pgsearch** | `912745b2` | Last commit before this search migration lands |
| **v2026.10.18-1** | merge commit on **main** | First release that includes pg_search on staging |

After merge, tag those commits locally or in GitHub as above (latest existing release tag before this work is **v1.0.1**).

### Code rollback through git

Revert the merge on **main** with a normal pull request:

```bash
git revert -m 1 <merge-commit-sha>
```

Open a PR with that revert commit. After merge, redeploy the previous application revision on Railway (deployment id from before the bad release, or rebuild from tag **v2026.10.18-pre-pgsearch**).

### Migrations

Rollback redeploys prior application code only. Do not run **`db:rollback`** for the generated **`cases.tsv`** column; removing it would break search.

### Railway staging

Railway exposes a single environment named **production** for this project (staging hostname **staging.ebwiki.org** is a custom domain on that environment). Set the service (**ebwiki**), that environment name, deployment id to restore, and a Railway **workspace** API token. Rollback uses **`Authorization: Bearer`** (see `lib/release/rollback/railway_graphql_client.rb`), matching [Railway account tokens](https://railway.com/account/tokens). Do not use Railway **project** tokens here. Rollback calls Railway GraphQL **`deploymentRollback`** (see [Manage Deployments](https://docs.railway.com/integrations/api/manage-deployments)).

Run it under Doppler so the token is never typed or pasted. `RAILWAY_TOKEN` in `ebwiki/infra` must be a workspace token for this to work (**unverified** which kind of token is stored there today).

```bash
export RELEASE_ROLLBACK_PLATFORM=railway
export RAILWAY_SERVICE=ebwiki
export RAILWAY_ENVIRONMENT=production
export RAILWAY_ROLLBACK_DEPLOYMENT_ID=<previous-deployment-id>
doppler run --project ebwiki --config infra -- bin/release-rollback
doppler run --project ebwiki --config infra -- bin/release-rollback --execute --yes
```

Implementation: `lib/release/rollback.rb`, entrypoint `bin/release-rollback` (loads `lib/release` only, no full Rails boot).
