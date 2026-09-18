-- Extra databases for the Compose Postgres 17 sidecar.
-- POSTGRES_USER/POSTGRES_DB already create blackops + blackops_development.
CREATE DATABASE blackops_test;
GRANT ALL PRIVILEGES ON DATABASE blackops_test TO blackops;
