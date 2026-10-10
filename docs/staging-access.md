# Staging access (after GKT-1209)

EBWiki staging is not meant to be reachable from the public internet on Railway-generated URLs. People and automation reach it only through Cloudflare Tunnel and Cloudflare Access on `staging.ebwiki.org`.

## How it works

1. **Inside Railway**, a small `cloudflared` service connects out to Cloudflare. Cloudflare sends traffic for `staging.ebwiki.org` through the tunnel to `http://ebwiki-web.railway.internal:8080` on Railway’s private network.
2. **Public Railway domains** on the staging web service are removed so there is no direct `*.up.railway.app` entry point.
3. **Cloudflare Access** sits in front of the hostname:
   - **People** sign in with an allowed email (for example `mark@grandkru.com`).
   - **Bots and CI** send a [Cloudflare service token](https://developers.cloudflare.com/cloudflare-one/access-controls/service-credentials/service-tokens/) using the `CF-Access-Client-Id` and `CF-Access-Client-Secret` request headers. Store those values only in Doppler (`ebwiki/stg`) or CI secrets—never commit them.
4. **Basic auth** on the Rails app stays on as a second layer. Hitting `/up` with a valid service token may still return HTTP 401 until basic-auth credentials are supplied; that is expected.

## Private networking and Puma

The web process must listen on all interfaces (`0.0.0.0`, or IPv6 `::`) so other Railway services can reach `ebwiki-web.railway.internal:8080`. `config/puma.rb` sets an explicit `tcp://0.0.0.0` bind; the Procfile passes the same bind to Puma.

## Exposure check (CI and ops)

Run:

```bash
CF-Access-Client-Id=... CF-Access-Client-Secret=... script/staging_exposure_check
```

Optional environment variables:

| Variable | Purpose |
| --- | --- |
| `STAGING_EXPOSURE_RAILWAY_URLS` | Comma-separated Railway URLs that must be closed (404 or no answer). |
| `STAGING_EXPOSURE_STAGING_URL` | Staging hostname base URL (default `https://staging.ebwiki.org`). |

You can also pass Railway URLs as script arguments.

The check **passes** only when:

- Each Railway URL returns **404** or does not answer.
- `https://staging.ebwiki.org/` **without** Access headers redirects to a `*.cloudflareaccess.com` sign-in page or returns **401** or **403**.
- `https://staging.ebwiki.org/up` **with** service token headers returns **200** or basic-auth **401**.

Automated tests live in `spec/lib/staging_exposure_check_spec.rb` (mocked HTTP, no live network in CI).

## Rollback (from GKT-1209)

**Before the Railway public domain is deleted (cutover step B5):**

- Remove the tunnel route and Access application in Cloudflare. No Railway app code change is required.

**After cutover (public Railway domain removed):**

- Regenerate a Railway public domain on the `ebwiki` web service (Railway dashboard or CLI). Basic auth still protects the app.
- Point `staging.ebwiki.org` DNS back to that origin if DNS was changed for the tunnel.
- Disabling the Access app reopens the hostname immediately—use only for a short test.

Rollback is intended to take under five minutes.
