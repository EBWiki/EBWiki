source /vagrant/dev_provisions/environment.sh
echo '## Provisioning database ...'
echo "postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost:5432/blackops_development /vagrant/${DATABASE_DUMP_FILE}"
sleep 2
pg_restore --verbose --clean --no-acl --no-owner --no-password --dbname="postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost:5432/blackops_development" "/vagrant/${DATABASE_DUMP_FILE}"

