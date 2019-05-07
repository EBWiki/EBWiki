run: build
	docker run --rm -it --publish 3000:3000 --name ebwiki ebwiki/ebwiki

build:
	docker build --tag ebwiki/ebwiki .

exec:
	docker exec -it ebwiki bash

stop:
	docker stop ebwiki

clean:
	docker image rm ebwiki/ebwiki:latest || echo "clean"

.PHONY: run build exec stop clean
