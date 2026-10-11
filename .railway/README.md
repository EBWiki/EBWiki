# Railway Infrastructure as Code (staging web service)

The **ebwiki** staging service deploy settings live here. OpenTofu (`infra/staging/railway.tf`) owns the GitHub source, region replicas, domains, `RAILWAY_DOCKERFILE_PATH`, `DOPPLER_TOKEN`, and other service variables. This partial owns pre-deploy, start, health check, and restart policy only (no `env` block).

Plan and apply with `make plan` / `make apply` on the PR Manager machine (see `infra/staging/README.md`).
