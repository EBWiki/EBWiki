build:
	docker build --tag ebwiki/ebwiki .

run:
	export PWD=`pwd`
	@echo "## PWD = $(PWD)"
	docker run --detach --rm --volume  $(PWD):/usr/src/ebwiki \
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
	@docker stop ebwiki > /dev/null 2>&1 || echo "ebwiki container is not running"

clean: stop
	@docker container rm ebwiki > /dev/null 2>&1 || echo "ebwiki container is not present"
	@docker image rm ebwiki/ebwiki:latest > /dev/null 2>&1 || echo "ebwiki image is not present"

test:
	./dev_provisions/run_tests.sh

rspec:
	@echo "## Please note that rspec requires the container to be running and"
	@echo "## takes a while to complete"
	docker exec ebwiki bash -c 'source dev_provisions/environment.sh && rake'

codeclimate:
	export PWD=`pwd`
	@echo "## PWD = $(PWD)"
	@echo "## Please note that codeclimate takes a while to run and does not"
	@echo "## generate any output until all jobs are complete...."
	time docker run --rm --env CODECLIMATE_CODE=. --volume $(PWD):/code --volume /var/run/docker.sock:/var/run/docker.sock --volume /tmp/cc:/tmp/cc --volume "./.codeclimate.yml.lite:/code/.codeclimate.yml" codeclimate/codeclimate analyze

all: clean build run

prchecks: codeclimate rspec
	rubocop
	brakeman -A --no-pager

.PHONY: run build exec stop clean all updatedb logs test rspec codeclimate
