# Release smoke check and rollback

Use these commands after deploying the Postgres search change to Railway staging. Production at ebwiki.org stays on the Cloudflare maintenance worker until a separate release.

## What this release covers

This change ships to **Railway staging only** (service **ebwiki**, public hostname **staging.ebwiki.org**). It does not take production traffic on ebwiki.org.

## Deploy staging (Railway)

Auto-build from GitHub is declared in `.railway/railway.ts`: repository **EBWiki/EBWiki**, branch **main**, Dockerfile **Dockerfile.railway**, health check **/up**. A merge to **main** triggers a new deploy of service **ebwiki** when the deployment trigger and CI gates allow it. See [DEPLOYING.md](DEPLOYING.md#gate-deploys-on-ci) and [DEPLOYING.md](DEPLOYING.md#why-merges-can-stall-on-railway).

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

`scripts/staging-dns-preflight.sh` is read only and fails closed. Before plan it allows a non-Railway live CNAME only when `--allow-cname-repair` is set (plan path) and the saved plan fixes the target. It compares the verification TXT value, not just the count. After the plan, and again before apply, it requires the planned CNAME to be DNS only and to point at a Railway target.

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

Use the **Release tags** workflow (GitHub environment **`release-tags`**, manual approval) to create:

| Tag | Commit | Role |
| --- | --- | --- |
| **v2026.10.18-pre-pgsearch** | `912745b2` | Last commit before this search migration lands |
| **v2026.10.18-1** | merge commit on **main** | First release that includes pg_search on staging |

### Code rollback through git

Revert the merge on **main** with a normal pull request:

```bash
git revert -m 1 <merge-commit-sha>
```

Open a PR with that revert commit. After merge, redeploy the previous application revision on Railway (deployment id from before the bad release, or rebuild from tag **v2026.10.18-pre-pgsearch**).

### Migrations

Rollback redeploys prior application code only. Do not run **`db:rollback`** for the generated **`cases.tsv`** column; removing it would break search.

### Railway staging (options)

Railway uses environment slug **`production`** for this staging project (hostname **staging.ebwiki.org** is a custom domain on that environment). Rollback uses Railway GraphQL **`deploymentRollback`** with a **workspace or account** token (**`RAILWAY_TOKEN`** in **ebwiki/infra**). Project tokens are rejected by the staging preflight. Rollback picks the previous **SUCCESS** deployment from the API (live **98b66eec-8d76-4447-849a-8edb27867710** at **8278d169**; prior healthy **96ee0929-a867-4a18-8cc4-ef24cddaee0f**).

**Option (a) / default one-liner:** resolves service **ebwiki**, environment slug **`production`**, and the previous **SUCCESS** deployment id automatically:

```bash
doppler run --project ebwiki --config infra -- bin/release-rollback
doppler run --project ebwiki --config infra -- bin/release-rollback --execute --yes
```

**Option (d) explicit deployment id** (when you already know the target id):

```bash
doppler run --project ebwiki --config infra -- \
  env RAILWAY_ROLLBACK_DEPLOYMENT_ID='<deployment-id>' \
  bin/release-rollback --execute --yes
```

Implementation: `lib/release/rollback.rb`, entrypoint `bin/release-rollback` (loads `lib/release` only, no full Rails boot).
