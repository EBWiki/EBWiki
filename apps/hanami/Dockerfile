# Hanami sibling app. Railway must set the service root to apps/hanami so this
# file is used instead of the repo-root Rails Dockerfile.
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

ENV HANAMI_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    LANG=C.UTF-8

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libpq5 \
      libyaml-0-2 \
      postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      nodejs \
      npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Settings load during asset compile; this value is not used at runtime.
ENV SESSION_SECRET=build-time-session-secret-change-in-production-must-be-at-least-64-chars
RUN bundle exec hanami assets compile

FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /app /app

EXPOSE 2300
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
