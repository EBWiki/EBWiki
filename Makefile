build:
	docker build --tag ebwiki/ebwiki .

run:
	docker run --detach --rm --volume $(PWD):/usr/src/ebwiki \
		--publish 3000:3000 --name ebwiki ebwiki/ebwiki
	./dev_provisions/prewarm.sh

updatedb:
	docker exec -e PGPASSWORD=ebwiki -it ebwiki pg_restore --verbose --clean \
		--no-acl --no-owner -p 5432 -h localhost -U blackops \
		-d blackops_development /usr/src/ebwiki/latest.dump || true

test:
	./dev_provisions/run_tests.sh

rspec:
	docker exec -it ebwiki bash -c 'source dev_provisions/environment.sh && rspec spec/'

logs:
	docker logs --timestamps --follow ebwiki

exec:
	docker exec -it ebwiki bash

stop:
	docker stop ebwiki || echo "stopped"

clean: stop
	docker image rm ebwiki/ebwiki:latest || echo "clean"

all: clean build run

.PHONY: run build exec stop clean all
