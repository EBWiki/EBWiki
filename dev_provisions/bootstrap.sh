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

#echo "## Running rake db:create"
#DATABASE_URL=postgres://blackops:ebwiki@localhost/blackops_development rake db:create
#sleep 2

#echo "## Running rake db:structure:load"
#DATABASE_URL=postgres://blackops:ebwiki@localhost/blackops_development rake db:structure:load
#sleep 2

#echo "## Running rake db:seed"
#DATABASE_URL=postgres://blackops:ebwiki@localhost/blackops_development rake db:seed
#sleep 2

echo "## Starting fakes3"
fakes3 -r ${FAKE_S3_HOME} -p ${FAKE_S3_PORT} --license ${FAKE_S3_KEY} &

#echo '## Provisioning database ...'
#sleep 2
#pg_restore --verbose --clean --no-acl --no-owner --no-password --dbname="postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost:5432/blackops_development" "./${DATABASE_DUMP_FILE}"

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
