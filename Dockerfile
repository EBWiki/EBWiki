FROM ruby:2.7.8

COPY Gemfile Gemfile.lock /
COPY dev_provisions/environment.sh /etc/profile.d

RUN gem install bundler -v 2.4.22
RUN bundle install
RUN gem install fakes3

RUN apt-get update -qq && \
    apt-get install -qq --no-install-recommends lsb-release apt-transport-https && \
    curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | \
    tee -a /etc/apt/sources.list.d/elastic-7.x.list && \
    apt-get update -qq && \
    apt-get install -qq --no-install-recommends vim \
        apt-utils \
        build-essential \
        libpq-dev \
        nodejs \
        npm \
        default-jre \
        postgresql \
        postgresql-contrib \
        postgresql-client \
        redis-server && \
    apt-get install -qq --no-install-recommends elasticsearch && \
    mkdir /usr/src/ebwiki && \
    update-rc.d elasticsearch defaults 95 10 && \
    update-rc.d postgresql defaults 95 10

WORKDIR /usr/src/ebwiki
COPY . /usr/src/ebwiki
EXPOSE 3000
ENTRYPOINT ./dev_provisions/entrypoint.sh
