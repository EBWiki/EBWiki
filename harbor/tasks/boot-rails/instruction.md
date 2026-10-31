# Boot EBWiki against Compose Postgres

This environment is EBWiki at `/usr/src/ebwiki` with Postgres 17 and Redis as sidecars.

Prepare the test database if needed, then write the Rails application class name to `/tmp/boot.txt`.

The file must exist and contain `EBWiki::Application`.

Use seed data only. Do not restore a production dump.
