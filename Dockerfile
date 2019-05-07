FROM ruby:2.5.5

ENV NVM_VERSION='v0.33.11'

COPY Gemfile Gemfile.lock /

RUN bundle install && \
    gem install fakes3 && \
    apt-get update -qq && \
    apt-get install apt-transport-https && \
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" > \
        /etc/apt/sources.list.d/elastic-6.x.list && \
    apt-get update -qq && \
    apt-get install -qq --no-install-recommends \
        apt-utils \
        build-essential \
        libpq-dev \
        openjdk-8-jre \
        postgresql  \
        redis-server && \
    apt-get install elasticsearch && \
    mkdir /usr/src/ebwiki

WORKDIR /usr/src/ebwiki

COPY . /usr/src/ebwiki


ENTRYPOINT ./dev_provisions/bootstrap.sh
