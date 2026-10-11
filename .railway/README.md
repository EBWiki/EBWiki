# Railway Infrastructure as Code (staging web service)

The **ebwiki** staging service deploy settings live here. OpenTofu (`infra/staging/railway.tf`) owns the GitHub source, region replicas, domains, and `DOPPLER_TOKEN`. This partial owns Dockerfile path, pre-deploy, start, and health check.

Plan and apply with `make plan` / `make apply` on the PR Manager machine (see `infra/staging/README.md`).
