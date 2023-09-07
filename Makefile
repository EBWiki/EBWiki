build:
	docker build --tag ebwiki/ebwiki .

run:
	docker run --detach --rm --volume "$(shell pwd)":/usr/src/ebwiki \
		--publish 3000:3000 --name ebwiki ebwiki/ebwiki
	./dev_provisions/prewarm.sh

logs:
	docker logs --timestamps --follow ebwiki

exec:
	docker exec -e PGPASSWORD=ebwiki -it ebwiki bash

stop:
	@docker stop ebwiki > /dev/null 2>&1 || echo "ebwiki container is not running"

clean: stop
	@docker container rm ebwiki > /dev/null 2>&1 || echo "ebwiki container is not present"
	@docker image rm ebwiki/ebwiki:latest > /dev/null 2>&1 || echo "ebwiki image is not present"

test:
	./dev_provisions/run_tests.sh

searchkick reindex_all:
	@echo "## Please note that searchkick requires the container to be running and"
	@echo "## takes a while to complete"
	docker exec ebwiki bash -c 'source dev_provisions/environment.sh && rake searchkick:reindex:all'

rspec:
	@echo "## Please note that rspec requires the container to be running and"
	@echo "## takes a while to complete"
	docker exec ebwiki bash -c 'source dev_provisions/environment.sh && rspec spec/'

codeclimate:
	@echo "## Please note that codeclimate takes a while to run and does not"
	@echo "## generate any output until all jobs are complete...."
	time docker run --rm --env CODECLIMATE_CODE="$(shell pwd)" --volume "$(shell pwd)":/code --volume /var/run/docker.sock:/var/run/docker.sock --volume /tmp/cc:/tmp/cc --volume "$(shell pwd)/.codeclimate.yml.lite":/code/.codeclimate.yml codeclimate/codeclimate analyze

all: clean build run

prchecks: codeclimate rspec
	rubocop
	brakeman -A --no-pager

.PHONY: run build exec stop clean all updatedb logs test rspec codeclimate
