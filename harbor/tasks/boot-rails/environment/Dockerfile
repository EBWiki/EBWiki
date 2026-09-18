# Same image humans build with `docker compose build`.
# Test gems are already installed (BUNDLE_WITHOUT=production).
# Harbor sets command to `sleep infinity`. Clear the app entrypoint
# so `db:prepare` does not race the oracle inside `main`.
# Bake PG* defaults: Harbor exec does not always inherit Compose env,
# and schema_format :sql shells out to psql.
FROM ebwiki/ebwiki:latest
ENV RAILS_ENV=test \
    DATABASE_URL=postgres://blackops:ebwiki@postgres:5432/blackops_test \
    PGHOST=postgres \
    PGUSER=blackops \
    PGPASSWORD=ebwiki \
    PGDATABASE=blackops_test \
    BLACKOPS_DATABASE_PASSWORD=ebwiki \
    REDIS_URL=redis://redis:6379/0 \
    BUNDLE_IGNORE_FUNDING_REQUESTS=1
WORKDIR /usr/src/ebwiki
ENTRYPOINT []
