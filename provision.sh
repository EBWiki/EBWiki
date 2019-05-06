#!/bin/bash -e
# to do: echo build steps into the isntall log

# Do some groundwork with the environment
source ./dev_provisions/environment.sh

echo '#########################################################'
echo '##  Provisioning the EBWiki Development Environment'
echo '##  This will take a while :D (10-15 mins depending on network)'
echo "##  Start time: $(date)"
echo '##  Provisioning the EBWiki Development Environment' > ${INSTALL_LOG}
echo '#########################################################'

echo '##  Installing Redis'
apt-get install -qq redis-server
#cp ./dev_provisions/redis.conf /etc/redis/redis.conf
service redis-server restart

echo '##  Installing Node.js'
wget -qO- "https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh" | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts

echo '##  Installing Java Runtime Environment'
apt-get install -qq openjdk-8-jre

echo '##  Installing Elasticsearch'
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
apt-get install -qq apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update &&  apt-get install -qq elasticsearch
/etc/init.d/elasticsearch start
until [ $(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://127.0.0.1:9200) -eq 200 ]; do sleep 1; done

echo '##  Installing NGINX'
apt-get install -qq nginx
cp ./dev_provisions/nginx.conf /etc/nginx/sites-available/default
service nginx restart

echo '##  Installing PostgreSQL'
apt-get install -qq postgresql
cp ./dev_provisions/database.yml ./config
service postgresql restart
chown postgres ./db/structure.sql
/sbin/runuser -l postgres -c "psql -c \"CREATE USER blackops WITH PASSWORD '${BLACKOPS_DATABASE_PASSWORD}';\""
/sbin/runuser -l postgres -c "psql -c \"ALTER USER blackops WITH SUPERUSER;\""

echo '##  Installing Fake S3'
gem install fakes3
fakes3 -r ${FAKE_S3_HOME} -p ${FAKE_S3_PORT} --license ${FAKE_S3_KEY} &

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
#source ./dev_provisions/provision_database.sh
