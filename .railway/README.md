# Railway Infrastructure as Code (staging web service)

The **ebwiki** staging service deploy settings live here. GitHub source (**EBWiki/EBWiki**, **main**) and Dockerfile builder match OpenTofu so config apply never clears source or builder before OpenTofu runs. OpenTofu owns region replicas, domains, and sets `RAILWAY_DOCKERFILE_PATH` and `DOPPLER_TOKEN`. This partial owns pre-deploy (900s timeout), start, health check, and restart policy. The `env` block lists every live variable name with `preserve()` only (no values in git).

Plan and apply with `make plan` / `make apply` on the PR Manager machine (see `infra/staging/README.md`).
