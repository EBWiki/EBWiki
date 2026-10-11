# Railway Infrastructure as Code (staging web service)

The **ebwiki** staging service source, builder, and deploy settings live here. OpenTofu does not set GitHub source (workspace token cannot repo-connect). Dockerfile path is **`RAILWAY_DOCKERFILE_PATH`** in the env block (literal path, not duplicated in OpenTofu). Other variables use `preserve()` only. OpenTofu sets **`DOPPLER_TOKEN`** and region replicas.

Plan and apply with `make plan` / `make apply` on the PR Manager machine (see `infra/staging/README.md`).
