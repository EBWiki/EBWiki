FROM ruby:2.6.5

COPY Gemfile Gemfile.lock /

RUN gem install bundler && bundle install && gem install fakes3
RUN apt-get update -qq && apt-get install -qq --no-install-recommends lsb-release apt-transport-https && \
    wget -q https://artifacts.elastic.co/GPG-KEY-elasticsearch && \
    wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    apt-key add GPG-KEY-elasticsearch && \
    apt-key add ACCC4CF8.asc && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" > /etc/apt/sources.list.d/elastic-6.x.list && \
    apt-get update -qq && \
    apt-get install -qq --no-install-recommends \
        apt-utils \
        build-essential \
        libpq-dev \
        nodejs \
        npm \
        default-jre \
        postgresql-12  \
        postgresql-client-12  \
        redis-server && \
    apt-get install -qq --no-install-recommends elasticsearch && \
    mkdir /usr/src/ebwiki

WORKDIR /usr/src/ebwiki
COPY . /usr/src/ebwiki
EXPOSE 3000
ENTRYPOINT ./dev_provisions/entrypoint.sh
