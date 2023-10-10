#!/bin/bash
source ./dev_provisions/environment.sh

cp -v ./dev_provisions/database.yml ./config

# Wait for Elasticsearch to start
echo -n "## Waiting for elasticsearch..."
until [ $(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://elasticsearch:9200) -eq 200 ];
do
    echo -n ".";
    sleep 1;
done
echo

echo -n "## Waiting for PostgreSQL to start..."
until pg_isready -h db -U blackops; do
  echo -n ".";
  sleep 1;
done

# Migrate and seed database
echo "## Migrating and seeding the database"
bundle exec rake db:drop db:create db:structure:load db:seed db:migrate

# Start fakes3
echo "## Starting fakes3"
fakes3 --root ${FAKE_S3_HOME} --port ${FAKE_S3_PORT} --license ${FAKE_S3_KEY} &
sleep 2

# Display environment summary
echo '#########################################################'
echo '##  Environment Summary'
echo '#########################################################'
echo "rails   = $(rails -v)"
echo "ruby    = $(ruby -v)"
echo "node    = $(node --version)"
echo "npm     = $(npm -v)"
echo "elastic = $(curl -sX GET 'http://elasticsearch:9200')"
echo '#########################################################'

# Start the Rails server
echo "## Starting the server..."
bundle exec rails server -b 0.0.0.0 -e development
