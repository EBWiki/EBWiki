# syntax=docker/dockerfile:1
# Dev/eval image for EBWiki. Postgres and Redis are Compose sidecars, not baked in.
# Production still deploys on Heroku; this image is for local `docker compose` and Harbor.
FROM ruby:3.4.2-slim-bookworm

ARG BUNDLE_WITHOUT=production
ENV RAILS_ENV=development \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=${BUNDLE_WITHOUT} \
    LANG=C.UTF-8 \
    BUNDLE_IGNORE_FUNDING_REQUESTS=1

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      postgresql-client \
      libyaml-dev \
      libvips42 \
      shared-mime-info \
      curl \
      git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/ebwiki

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "${BUNDLE_WITHOUT}" \
 && bundle install

COPY . .
RUN mkdir -p tmp/pids log \
 && chmod +x docker/entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["docker/entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
