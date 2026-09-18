# `ebwiki-dev` Harbor environment

Canonical eval image and Compose sidecars for EBWiki Harbor tasks that need
Postgres or the test gem group.

- `Dockerfile` — `ebwiki/ebwiki:latest` plus `bundle install` with the test group
- `docker-compose.yaml` — Postgres 17 and Redis 7 (same major versions as CI)

Copy both files into a task's `environment/` directory. Harbor builds `main`
from that `environment/` folder and merges the Compose file for sidecars.

Do **not** add Elasticsearch. Case search is `pg_search` on Postgres.
