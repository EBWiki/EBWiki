run:
	docker run --rm -it --volume $(PWD):/usr/src/ebwiki --publish 3000:3000 --name ebwiki ebwiki/ebwiki

build:
	docker build --tag ebwiki/ebwiki .

exec:
	docker exec -it ebwiki bash

stop:
	docker stop ebwiki

clean:
	docker image rm ebwiki/ebwiki:latest || echo "clean"

all: clean build run

.PHONY: run build exec stop clean all
