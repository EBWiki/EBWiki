#!/bin/bash
source ./dev_provisions/environment.sh

chown postgres ./db/structure.sql
cp ./dev_provisions/database.yml ./config

echo "## Installing nodejs"
wget -qO- "https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh" | bash
. /root/.nvm/nvm.sh
nvm install --lts

for i in postgresql redis-server elasticsearch;
do
    echo "## Starting $i"
    service $i start
done


echo "## Waiting for elasticsearch..."
until [ $(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://127.0.0.1:9200) -eq 200 ]; do sleep 1; done

echo "## Create DB user"
runuser -l postgres -c "psql -c \"CREATE USER blackops WITH PASSWORD '${BLACKOPS_DATABASE_PASSWORD}';\""
runuser -l postgres -c "psql -c \"ALTER USER blackops WITH SUPERUSER;\""

for i in create structure:load seed;
do
    echo "## Running rake db:${i}"
    rake db:${i}
done

echo "## Starting fakes3"
fakes3 --root ${FAKE_S3_HOME} --port ${FAKE_S3_PORT} --license ${FAKE_S3_KEY} &
sleep 2

echo '## Provisioning database ...'
pg_restore --clean --no-acl --no-owner --no-password \
    --dbname="postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost:5432/blackops_development" \
    "./${DATABASE_DUMP_FILE}"
sleep 2

echo '#########################################################'
echo '##  Environment Summary'
echo '#########################################################'
echo "rails   = $(rails -v)"
echo "ruby    = $(ruby -v)"
echo "node    = $(node --version)"
echo "npm     = $(npm -v)"
echo "java    = $(java -version 2>&1 | grep version)"
echo "psql    = $(psql --version)"
echo "redis   = $(redis-server --version | awk '{print $3}')"
echo "elastic = $(curl -sX GET 'http://localhost:9200')"
echo '#########################################################'

echo "## Starting the server..."
bundle exec puma -t 1:1 -p ${PORT:-3000} -e ${RACK_ENV:-development}
