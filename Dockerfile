FROM ruby:2.5.5

ENV AUTOBUS_SNAPSHOT_URL=''
ENV AWS_ACCESS_KEY_ID='accessKey1'
ENV AWS_SECRET_KEY_ID='verySecretKey1'
ENV BLACKOPS_DATABASE_PASSWORD='ebwiki'
ENV CODECLIMATE_REPO_TOKEN=''
ENV DATABASE_DUMP_FILE='latest.dump'
ENV DEBIAN_FRONTEND=noninteractive
ENV EBWIKI_SITEMAP_URL=http://bow-sitemaps.s3.amazonaws.com/sitemaps/sitemap.xml.gz
ENV INSTALL_LOG='/tmp/install.log'
ENV MAILCHIMP_API_KEY=''
ENV MAILCHIMP_LINK=''
ENV MAILCHIMP_LIST_ID=''
ENV NVM_VERSION='v0.33.11'
ENV REDISTOGO_URL=''
ENV SEARCHBOX_URL=''

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

ENTRYPOINT ./dev_provisions/bootstrap.sh
