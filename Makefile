build:
	docker build --tag ebwiki/ebwiki .

run:
	docker run --detach --rm --volume "$(PWD)":/usr/src/ebwiki \
		--publish 3000:3000 --name ebwiki ebwiki/ebwiki
	./dev_provisions/prewarm.sh

updatedb:
	docker exec -e PGPASSWORD=ebwiki ebwiki pg_restore --verbose --clean \
		--no-acl --no-owner -p 5432 -h localhost -U blackops \
		-d blackops_development /usr/src/ebwiki/latest.dump || true

logs:
	docker logs --timestamps --follow ebwiki

exec:
	docker exec -it ebwiki bash

stop:
	docker stop ebwiki || echo "stopped"

clean: stop
	docker image rm ebwiki/ebwiki:latest || echo "clean"

test:
	./dev_provisions/run_tests.sh

rspec:
	docker exec ebwiki bash -c 'source dev_provisions/environment.sh && rspec spec/'

codeclimate:
	time docker run --rm --env CODECLIMATE_CODE="$(PWD)" --volume "$(PWD)":/code --volume /var/run/docker.sock:/var/run/docker.sock --volume /tmp/cc:/tmp/cc --volume "$(PWD)/.codeclimate.yml.orig.lite":/code/.codeclimate.yml codeclimate/codeclimate analyze

all: clean build run

.PHONY: run build exec stop clean all updatedb logs test rspec codeclimate
