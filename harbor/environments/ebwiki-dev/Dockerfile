# Harbor eval image: published app image plus the test gem group.
# The root Dockerfile runs `bundle install --without test production`,
# so RSpec tasks fail without this wrapper.
FROM ebwiki/ebwiki:latest

ENV RAILS_ENV=test
ENV BUNDLE_WITHOUT=""
ENV BUNDLE_PATH=/usr/local/bundle
WORKDIR /usr/src/ebwiki

RUN bundle config unset without \
 && bundle config unset frozen \
 && bundle install
