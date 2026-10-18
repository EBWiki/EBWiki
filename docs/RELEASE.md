# Release smoke check and rollback

Use these commands after deploying the Postgres search change to Railway staging. Production at ebwiki.org stays on the Cloudflare maintenance worker until a separate release.

## What this release covers

This change ships to **Railway staging only** (service **ebwiki**, public hostname **staging.ebwiki.org**). It does not take production traffic on ebwiki.org.

## Deploy staging (Railway)

Auto-build from GitHub is declared in `.railway/railway.ts`: repository **EBWiki/EBWiki**, branch **main**, Dockerfile **Dockerfile.railway**, health check **/up**. A merge to **main** triggers a new deploy of service **ebwiki** when the deployment trigger and CI gates allow it. See [Gate deploys on CI](DEPLOYING.md#gate-deploys-on-ci) and [Why GitHub pushes did not deploy](DEPLOYING.md#why-github-pushes-did-not-deploy).

Manual redeploy if needed (from a machine with Railway CLI and project access). Use it only for a commit that already passed CI on **main**; a manual redeploy does not wait for CI:

```bash
railway redeploy --service ebwiki
```

OpenTofu for DNS and Railway custom domain (includes read-only DNS preflight before plan):

```bash
make plan    # GitHub and staging stacks; writes plan files, applies nothing
make apply   # GitHub stack first, then staging; typed confirmation on each apply script
```

Staging DNS: Cloudflare CNAME **staging.ebwiki.org** points at the Railway custom-domain target with **DNS only** (grey cloud), and the Railway verification TXT record **_railway-verify.staging.ebwiki.org** stays in place with a `railway-verify=` value. OpenTofu sets `proxied = false` on the CNAME. DNS only lets Railway issue and renew its own certificate for the host without depending on the zone's Cloudflare SSL mode.

`scripts/staging-dns-preflight.sh` is read only and fails closed. It requires exactly one staging CNAME with a boolean proxied flag and exactly one verification TXT record whose value starts with `railway-verify=`. A live CNAME that does not point at Railway is allowed only as a repair: before the plan with `--allow-cname-repair`, and on the saved plan only when the plan points it at a Railway target, so the repair can be planned and applied. After the plan, and again before apply, it requires the planned CNAME to be DNS only and to point at a Railway target, and the live TXT value to equal the value Railway expects in the plan. The plan gates also fail when the plan changes any Cloudflare resource other than the staging CNAME (the one allowed destroy is the legacy redirect ruleset).

**Verified Railway domain state (2026-10-18):** **staging.ebwiki.org** is attached to service **ebwiki** in Railway's internal environment slug **`production`** (staging app only; **ebwiki.org** is not on Railway). Railway reported verification incomplete and certificate issuance in progress because the live Cloudflare CNAME was proxied. The verification TXT is present. Requests hit Railway's fallback 404 (`x-railway-fallback: true`). Applying the DNS-only CNAME plan should let Railway verify the host and finish the certificate; clearing the 404 is still labeled **unverified** until observed after apply.

## Post-deploy smoke check

The smoke check hits staging over HTTP. It confirms the home page loads, search returns results for a known term, junk search returns zero results without error, and `/health` reports Postgres and Redis only (no Elasticsearch probe).

Run the **Release smoke check** workflow manually from the GitHub Actions tab on **`main`**. The job uses environment **`release-smoke`** (branch **main** only) with **`STAGING_USERNAME`**, **`STAGING_PASSWORD`**, and **`ROLLBAR_ACCESS_TOKEN`** from Doppler **ebwiki/stg** (provisioned by `infra/github/`). The workflow fails closed if that environment is missing. The environment requires reviewer approval and does not allow admin bypass. After apply, run **`make github-delete-repo-secrets`** for a dry run, then **`make github-delete-repo-secrets CONFIRM=1`** to remove repository-level copies of those names.

Rollbar receives smoke and rollback failures when **`ROLLBAR_ACCESS_TOKEN`** is set. Bootstrap mints that project token into **ebwiki/stg**; the only manual Rollbar step is seeding **`ROLLBAR_ACCOUNT_API_KEY`** in **grandkru/prd** before **`make bootstrap`**.

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

### Release tags

Tags are created by the [Release tags](../.github/workflows/release-tags.yml) workflow, run by hand from **main**. Its tag job uses the GitHub environment **`release-tags`** (created by `infra/github`, reviewer approval required, no admin bypass, **main** only). An earlier job refuses to run until that environment exists with reviewers, because GitHub would otherwise create it without protection. The workflow only tags commits on **main** and refuses a tag that already exists.

| Tag | Commit | Role |
| --- | --- | --- |
| **v2026.10.18-pre-pgsearch** | `912745b257dbc9fdd5c48b9cf563df0905375c86` | Last commit before this search migration lands; create it before merging |
| **v2026.10.18-1** | the merge commit on **main** (full SHA as the `commit` input) | First release that includes pg_search on staging |

### Code rollback through git

Revert the merge on **main** with a normal pull request:

```bash
git revert -m 1 <merge-commit-sha>
```

Open a PR with that revert commit. After merge, redeploy the previous application revision on Railway (deployment id from before the bad release, or rebuild from tag **v2026.10.18-pre-pgsearch**).

### Migrations

Rollback redeploys prior application code only. Do not run **`db:rollback`** for the generated **`cases.tsv`** column; removing it would break search.

### Railway staging (options)

Railway uses environment slug **`production`** for this staging project (hostname **staging.ebwiki.org** is a custom domain on that environment). Rollback uses Railway GraphQL **`deploymentRollback`** with a **workspace or account** token (**`RAILWAY_TOKEN`** in **ebwiki/infra**).

Railway marks a replaced deployment **REMOVED**, so the live deployment is normally the only **SUCCESS** one. Without `RAILWAY_ROLLBACK_DEPLOYMENT_ID`, rollback takes the live **SUCCESS** deployment and picks the newest older deployment that Railway still allows rolling back to (`canRollback`). It fails closed when there is no live deployment or no such earlier one. The dry run prints the chosen id; read it before passing `--execute`.

On 2026-10-18 the live deployment was **98b66eec** (commit **8278d169**). The two deployments just before it (Oct 11) cannot be rolled back to, so a rollback run that day would have chosen **54e4f273**, the Oct 5 deployment of image **ebwiki/ebwiki:184**. After this change deploys, the target should become **98b66eec** (**unverified** until the dry run shows it).

**Option (a), one command:** resolves service **ebwiki**, environment slug **`production`** and the target deployment, prints the plan, then runs it:

```bash
doppler run --project ebwiki --config infra -- bin/release-rollback
doppler run --project ebwiki --config infra -- bin/release-rollback --execute --yes
```

**Option (d), explicit deployment id** (when you already know the target id, for example from the Railway deployment list):

```bash
doppler run --project ebwiki --config infra -- \
  env RAILWAY_ROLLBACK_DEPLOYMENT_ID='<deployment-id>' \
  bin/release-rollback --execute --yes
```

Implementation: `lib/release/rollback.rb`, entrypoint `bin/release-rollback` (loads `lib/release` only, no full Rails boot).
