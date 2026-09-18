# `ebwiki-dev` Harbor environment

Canonical eval wrapper and Compose sidecars for Harbor tasks that need Postgres.

- `Dockerfile` — `FROM ebwiki/ebwiki:latest` (build that image with `docker compose build` in the repo root; test gems are included)
- `docker-compose.yaml` — Postgres 17 and Redis 7, same majors as repo `compose.yaml` and CI. Sidecars declare `networks: [default]` so Harbor allowlist does not share the egress sidecar’s network namespace with `expose`d ports.

Copy both files into a task's `environment/` directory. Harbor builds `main` from that folder and merges the Compose file for sidecars.

Do **not** add Elasticsearch. Case search is `pg_search` on Postgres.
