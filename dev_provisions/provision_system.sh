#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo '##  Updating the apt cache'
apt-get install -qq aptitude
aptitude update 2>&1

echo '## Allow default user to install in /usr/local'
setfacl --modify='u:vagrant:rwx' --recursive /usr/local/

echo '##  Installing dependencies'
aptitude install --assume-yes \
    apt-transport-https \
    autoconf \
    automake \
    bison \
    build-essential \
    curl \
    g++ \
    gcc \
    git \
    git-core \
    gnupg2 \
    libcurl4-openssl-dev \
    libffi-dev \
    libgdbm-dev \
    libgdbm5 \
    libncurses5-dev \
    libpq-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    make \
    nginx \
    nodejs \
    npm \
    openjdk-8-jre \
    postgresql \
    redis-server \
    ruby \
    ruby-dev \
    sqlite3 \
    zlib1g-dev 2>&1

echo '##  Install Elasticsearch'
cp /vagrant/confs/elastic-6.x.list /etc/apt/sources.list.d
wget -q https://artifacts.elastic.co/GPG-KEY-elasticsearch -O /tmp/GPG-KEY-elasticsearch
(apt-key add /tmp/GPG-KEY-elasticsearch) 2>&1
aptitude update 2>&1
aptitude install --assume-yes --quiet elasticsearch 2>&1
systemctl enable elasticsearch 2>&1

echo '##  Installing NGINX'
cp /vagrant/confs/nginx.conf /etc/nginx/sites-available/default
systemctl enable nginx 2>&1

echo '##  Installing PostgreSQL'
systemctl enable postgresql 2>&1

(
echo '#########################################################'
echo '##  Installation complete!'
echo "##  End time: $(date)"
echo '#########################################################'
echo '##  Environment Summary'
echo '#########################################################'
echo "node    = $(nodejs --version)"
echo "npm     = $(npm -v)"
echo "java    = $(java -version 2>&1 | grep version)"
echo "psql    = $(psql --version)"
echo "nginx   = $(nginx -v 2>&1)"
echo "redis   = $(redis-server --version | awk '{print $3}')"
echo "elastic = $(curl -sX GET 'http://localhost:9200')"
echo '#########################################################'
) > /tmp/system_provision.txt
