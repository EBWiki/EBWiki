#!/bin/bash
source ./dev_provisions/environment.sh
for i in postgresql redis-server nginx elasticsearch;
do
    echo "## Starting service $i"
    service $i start
done

echo "## Running rake commands"
DATABASE_URL=postgres://blackops:ebwiki@localhost/blackops_development rake db:create && \
DATABASE_URL=postgres://blackops:ebwiki@localhost/blackops_development rake db:structure:load && \
DATABASE_URL=postgres://blackops:ebwiki@localhost/blackops_development rake db:seed

echo '## Provisioning database ...'
echo "postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost:5432/blackops_development ./${DATABASE_DUMP_FILE}"
sleep 2
pg_restore --verbose --clean --no-acl --no-owner --no-password --dbname="postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost:5432/blackops_development" "./${DATABASE_DUMP_FILE}"

echo "## Starting the server..."
bundle exec puma -t 1:1 -p ${PORT:-3000} -e ${RACK_ENV:-development}
