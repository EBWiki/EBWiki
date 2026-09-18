# `ebwiki-dev` Harbor environment

Canonical eval wrapper and Compose sidecars for Harbor tasks that need Postgres.

- `Dockerfile` — `FROM ebwiki/ebwiki:latest` with `ENTRYPOINT []` so Harbor’s `sleep infinity` is not wrapped by the app `db:prepare` entrypoint (build that image with `docker compose build` in the repo root; test gems are included)
- `docker-compose.yaml` — Postgres 17 and Redis 7, same majors as repo `compose.yaml` and CI. Sidecars declare `networks: [default]`. Tasks that need these services use `network_mode = "public"`; Harbor allowlist RST’s raw Postgres TCP.

Copy both files into a task's `environment/` directory. Harbor builds `main` from that folder and merges the Compose file for sidecars.

Do **not** add Elasticsearch. Case search is `pg_search` on Postgres.
