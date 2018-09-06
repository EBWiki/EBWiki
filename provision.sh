#!/bin/bash
# to do: echo build steps into the isntall log

# Do some groundwork with the environment
source /vagrant/dev_provisions/environment.sh

echo '#########################################################'
echo '##  Provisioning the EBWiki Development Environment'
echo '##  This will take a while :D'
echo "##  Start time: $(date)"
echo '##  Provisioning the EBWiki Development Environment' > ${INSTALL_LOG}
echo '#########################################################'

env >> ${INSTALL_LOG}
cp /vagrant/dev_provisions/database.yml /vagrant/config/database.yml

echo '##  Updating the apt cache'
apt-get update 2>&1 >> ${INSTALL_LOG}

echo '##  Installing dependencies'
apt-get install -qq \
    apt-transport-https\
    build-essential \
    curl \
    gcc \
    git-core \
    libcurl4-openssl-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    sqlite3 \
    zlib1g-dev \
    2>&1 >> ${INSTALL_LOG}

echo '## Installing Redis'
apt-get install -qq redis-server 2>&1 >> ${INSTALL_LOG}
cp /vagrant/dev_provisions/redis.conf /etc/redis/redis.conf
systemctl restart redis.service

echo '##  Installing Node.js'
apt-get install -qq nodejs npm 2>&1 >> ${INSTALL_LOG}

echo '##  Installing Java Runtime Environment'
apt-get install -qq openjdk-8-jre 2>&1 >> ${INSTALL_LOG}

echo '##  Installing Elasticsearch'
cp /vagrant/dev_provisions/elastic-6.x.list /etc/apt/sources.list.d
wget -q https://artifacts.elastic.co/GPG-KEY-elasticsearch -O /tmp/GPG-KEY-elasticsearch
(apt-key add /tmp/GPG-KEY-elasticsearch) 2>&1 >> ${INSTALL_LOG}
apt-get update 2>&1 >> ${INSTALL_LOG}
apt-get install -qq elasticsearch 2>&1 >> ${INSTALL_LOG}
systemctl enable elasticsearch 2>&1 >> ${INSTALL_LOG}
/etc/init.d/elasticsearch start 2>&1 >> ${INSTALL_LOG}
until [ $(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://127.0.0.1:9200) -eq 200 ]; do sleep 1; done

echo '##  Installing NGINX'
apt-get install -qq nginx 2>&1 >> ${INSTALL_LOG}
cp /vagrant/dev_provisions/nginx.conf /etc/nginx/sites-available/default
systemctl reload nginx

echo '##  Installing PostgreSQL'
apt-get install -qq postgresql 2>&1 >> ${INSTALL_LOG}
su - postgres -c \
psql <<__END__
CREATE USER blackops WITH PASSWORD '${BLACKOPS_DATABASE_PASSWORD}';
ALTER USER blackops CREATEDB;
__END__

echo '##  Installing Ruby (via RVM)'
apt-get install -qq \
    automake \
    bison \
    gpgv2 \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libtool \
    2>&1 >> ${INSTALL_LOG}

curl -sSL https://rvm.io/mpapis.asc > /tmp/gpg.txt
gpg --no-tty --quiet --import /tmp/gpg.txt 2>/dev/null
curl -sSL https://get.rvm.io > /tmp/get.rvm.sh
chmod +x /tmp/get.rvm.sh
/tmp/get.rvm.sh --quiet-curl stable  2>&1 >> ${INSTALL_LOG}
source /etc/profile.d/rvm.sh 2>&1 >> ${INSTALL_LOG}
(rvm install 2.5.1) 2>&1 >> ${INSTALL_LOG}
rvm use 2.5.1 --default 2>&1 >> ${INSTALL_LOG}

echo '##  Installing Rails'
gem install rails 2>&1 >> ${INSTALL_LOG}

echo '##  Installing Bundler'
gem install bundler 2>&1 >> ${INSTALL_LOG}

echo '##  Installing Fake S3'
gem install fakes3 2>&1 >> ${INSTALL_LOG}
fakes3 -r ${FAKE_S3_HOME} -p ${FAKE_S3_PORT} --license ${FAKE_S3_KEY} &

echo '##  Running bundle install'
(cd /vagrant && bundle install) 2>&1 >> ${INSTALL_LOG}

/etc/init.d/elasticsearch start
until [ $(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://127.0.0.1:9200) -eq 200 ]; do sleep 1; done

echo '##  Running rake commands...'
for env in development;
do
    for rake_step in create db:structure:load seed;
    do
        echo "## DATABASE_URL=postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost/blackops_${env} rake db:${rake_step}"
        cd /vagrant && DATABASE_URL=postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost/blackops_${env} rake db:${rake_step} 2>&1 >> ${INSTALL_LOG};
    done
done

echo
echo
echo '#########################################################'
echo '##  Installation complete!'
echo "##  End time: $(date)"
echo '#########################################################'
echo '##  Environment Summary'
echo '#########################################################'
echo "rails   = $(rails -v)"
echo "ruby    = $(ruby -v)"
echo "node    = $(node --version)"
echo "npm     = $(npm -v)"
echo "java    = $(java -version 2>&1 | grep version)"
echo "psql    = $(psql --version)"
echo "nginx   = $(nginx -v 2>&1)"
echo "redis   = $(redis-server --version | awk '{print $3}')"
echo "elastic = $(curl -sX GET 'http://localhost:9200')"
echo '#########################################################'

echo
echo "##  Starting EBWiki on ${PROJECT_URL}"
echo '##  Run 'vagrant ssh' to connect to the VM'
echo '##  Run 'vagrant status' for tips on working with the VM'
cd /vagrant && rails server 2>&1 >> /tmp/ebwiki.log &
