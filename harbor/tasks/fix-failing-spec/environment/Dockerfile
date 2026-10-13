# Local-only tag. FROM :latest lets Buildx pull a stale Docker Hub image
# that does not include postgresql-client. `docker compose build` tags :dev.
FROM ebwiki/ebwiki:dev
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
RUN mkdir -p /usr/src/ebwiki/spec/harbor
COPY harbor_addition.rb /usr/src/ebwiki/lib/harbor_addition.rb
COPY addition_spec.rb /usr/src/ebwiki/spec/harbor/addition_spec.rb
ENTRYPOINT []
