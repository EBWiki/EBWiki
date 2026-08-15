# Use Ruby 3.4.2 as base image
FROM ruby:3.4.2-slim

ENV RAILS_ENV=development
ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_WITHOUT=""

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    libvips \
    libvips-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/ebwiki

COPY Gemfile Gemfile.lock ./

RUN bundle config --global frozen 1 && \
    bundle install

COPY . .

RUN mkdir -p tmp/pids log

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
