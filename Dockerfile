FROM ruby:2.5.5

ENV EBWIKI_SITEMAP_URL=http://bow-sitemaps.s3.amazonaws.com/sitemaps/sitemap.xml.gz
ENV PROJECT_URL='http://192.168.68.68'
ENV INSTALL_LOG='/tmp/install.log'
ENV DEBIAN_FRONTEND=noninteractive
ENV BLACKOPS_DATABASE_PASSWORD='ebwiki'
ENV DATABASE_DUMP_FILE='latest.dump'
ENV NVM_VERSION='v0.33.11'
ENV MAILCHIMP_API_KEY=''
ENV MAILCHIMP_LINK=''
ENV MAILCHIMP_LIST_ID=''
ENV SEARCHBOX_URL=''
ENV CODECLIMATE_REPO_TOKEN=''
ENV AUTOBUS_SNAPSHOT_URL=''
ENV AWS_ACCESS_KEY_ID='accessKey1'
ENV AWS_SECRET_KEY_ID='verySecretKey1'

RUN apt-get update -qq && \
    apt-get install -qq --no-install-recommends \
        apt-utils \
        build-essential \
        libpq-dev \
        nodejs && \
    mkdir /usr/src/ebwiki

WORKDIR /usr/src/ebwiki

COPY . /usr/src/ebwiki

RUN bundle install && \
    ./provision.sh
    #./provision.sh && \
    #DATABASE_URL=postgres://blackops:ebwiki@localhost/blackops_development rake db:create && \
    #DATABASE_URL=postgres://blackops:ebwiki@localhost/blackops_development rake db:structure:load && \
    #DATABASE_URL=postgres://blackops:ebwiki@localhost/blackops_development rake db:seed

