# Same image humans build with `docker compose build`.
# Test gems are already installed (BUNDLE_WITHOUT=production).
# Harbor sets command to `sleep infinity`. Clear the app entrypoint
# so `db:prepare` does not race the oracle inside `main`.
FROM ebwiki/ebwiki:latest
ENV RAILS_ENV=test
WORKDIR /usr/src/ebwiki
ENTRYPOINT []
