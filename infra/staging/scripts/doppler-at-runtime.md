# Doppler at runtime (option A)

First-time setup creates a **read-only** Doppler service token for `ebwiki/stg` and stores its key in `ebwiki/infra` as **`STAGING_RUNTIME_DOPPLER_TOKEN`**. Staging apply sets that value as the only Railway secret named **`DOPPLER_TOKEN`**.

**`railway.staging.toml`** wraps start and pre-deploy with `doppler run --project ebwiki --config stg --`. **`Dockerfile.railway`** installs the Doppler CLI from **`https://packages.doppler.com/public/cli/deb/debian`** (GPG key from **`packages.doppler.com/public/cli/gpg.key`**) so those commands work in the staging image only. Rails reads **`STAGING_USERNAME`** and **`STAGING_PASSWORD`** from Doppler at boot (see `lib/staging_basic_auth.rb`).

Keep **`DATABASE_URL`** and **`REDIS_URL`** as Railway references to the Postgres and Redis services. Do not sync those from Doppler.
