DO $$ BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'blackops'
    ) THEN
        CREATE ROLE blackops WITH LOGIN ENCRYPTED PASSWORD 'yourpassword';
    END IF;

    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_database WHERE datname = 'blackops_development'
    ) THEN
        GRANT ALL PRIVILEGES ON DATABASE blackops_development TO blackops;
    END IF;
END $$;
