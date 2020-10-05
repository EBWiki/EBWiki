build:
	docker build --tag ebwiki/ebwiki .

run:
	docker run --detach --rm --volume $(PWD):/usr/src/ebwiki --publish 3000:3000 --name ebwiki ebwiki/ebwiki
	./dev_provisions/prewarm.sh

test:
	./dev_provisions/run_tests.sh

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
