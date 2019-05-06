FROM ruby:2.5.5
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && \
    apt-get install -qq --no-install-recommends \
        apt-utils \
        build-essential \
        libpq-dev \
        nodejs && \
    mkdir /usr/src/ebwiki
WORKDIR /usr/src/ebwiki
COPY . /usr/src/ebwiki
RUN bundle install && ./provision.sh
