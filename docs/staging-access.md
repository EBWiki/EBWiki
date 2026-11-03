# Staging access (after GKT-1209)

EBWiki staging is not meant to be reachable from the public internet on Railway-generated URLs. People and automation reach it only through Cloudflare Tunnel and Cloudflare Access on `staging.ebwiki.org`.

## How it works

1. **Inside Railway**, a small `cloudflared` service connects out to Cloudflare. Cloudflare sends traffic for `staging.ebwiki.org` through the tunnel to `http://ebwiki-web.railway.internal:8080` on Railway’s private network.
2. **Public Railway domains** on the staging web service are removed so there is no direct `*.up.railway.app` entry point.
3. **Cloudflare Access** sits in front of the hostname:
   - **People** sign in with an allowed email (for example `mark@grandkru.com`).
   - **Bots and CI** send a [Cloudflare service token](https://developers.cloudflare.com/cloudflare-one/access-controls/service-credentials/service-tokens/) using the `CF-Access-Client-Id` and `CF-Access-Client-Secret` request headers. Store the values in Doppler (`ebwiki/stg`) or CI secrets as `CF_ACCESS_CLIENT_ID` and `CF_ACCESS_CLIENT_SECRET` (underscore names work in POSIX shells). Never commit them.
4. **Basic auth** on the Rails app stays on as a second layer for normal pages. The `/up` health route skips basic auth so automation can verify the app after Access accepts the service token.

## Private networking and Puma

The web process must listen on all interfaces (`0.0.0.0`, or IPv6 `::`) so other Railway services can reach `ebwiki-web.railway.internal:8080`. `config/puma.rb` sets an explicit `tcp://0.0.0.0` bind; the Procfile passes the same bind to Puma.

## Health check route

Rails serves `GET /up` via `rails/health#show` (see `config/routes.rb`). The exposure check calls this path with service token headers after Cloudflare Access allows the request through.

## Exposure check (CI and ops)

Run:

```bash
CF_ACCESS_CLIENT_ID=... CF_ACCESS_CLIENT_SECRET=... script/staging_exposure_check
```

Optional environment variables:

| Variable | Purpose |
| --- | --- |
| `STAGING_EXPOSURE_RAILWAY_URLS` | Comma-separated Railway URLs that must be closed (404 or no answer). If set but empty, the script exits with an error. |
| `STAGING_EXPOSURE_STAGING_URL` | Staging hostname base URL (default `https://staging.ebwiki.org`). |

You can also pass Railway URLs as script arguments.

The check **passes** only when:

- Each Railway URL returns **404** or does not answer.
- `https://staging.ebwiki.org/` **without** Access headers shows Cloudflare Access (redirect to `*.cloudflareaccess.com`, or Cloudflare Access response headers). A plain Rails basic-auth **401** alone does **not** count.
- `https://staging.ebwiki.org/up` **with** service token headers returns **200**.

Automated tests live in `spec/lib/staging_exposure_check_spec.rb` and `spec/requests/up_spec.rb` (mocked HTTP for the library; request spec for the route).

## Rollback (from GKT-1209)

**Before the Railway public domain is deleted (cutover step B5):**

- Remove the tunnel route and Access application in Cloudflare. No Railway app code change is required.

**After cutover (public Railway domain removed):**

- Regenerate a Railway public domain on the `ebwiki` web service (Railway dashboard or CLI). Basic auth still protects the app.
- Point `staging.ebwiki.org` DNS back to that origin if DNS was changed for the tunnel.
- Disabling the Access app reopens the hostname immediately—use only for a short test.

Rollback is intended to take under five minutes.
