build:
	docker build --tag ebwiki/ebwiki .

run:
	docker run --detach --rm --volume $(PWD):/usr/src/ebwiki --publish 3000:3000 --name ebwiki ebwiki/ebwiki

logs:
	docker logs --timestamps --follow ebwiki

exec:
	docker exec -it ebwiki bash

stop:
	docker stop ebwiki

clean:
	docker image rm ebwiki/ebwiki:latest || echo "clean"

all: clean build run

.PHONY: run build exec stop clean all
