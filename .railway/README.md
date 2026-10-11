# Railway Infrastructure as Code (staging web service)

The **ebwiki** staging service deploy settings live here. OpenTofu (`infra/staging/railway.tf`) owns the GitHub source, region replicas, domains, and sets `RAILWAY_DOCKERFILE_PATH` and `DOPPLER_TOKEN`. This partial owns pre-deploy, start, health check, and restart policy. The `env` block lists every live variable name with `preserve()` only (no values in git).

Plan and apply with `make plan` / `make apply` on the PR Manager machine (see `infra/staging/README.md`).
