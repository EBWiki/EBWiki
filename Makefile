COMPOSE := docker compose

build:
	$(COMPOSE) build

run up start: build
	$(COMPOSE) up --detach
	./dev_provisions/prewarm.sh

logs:
	$(COMPOSE) logs --follow

exec shell:
	$(COMPOSE) exec web bash

stop down:
	$(COMPOSE) down

clean: down
	$(COMPOSE) down --volumes --remove-orphans
	-docker image rm ebwiki/ebwiki:dev ebwiki/ebwiki:latest

test:
	./dev_provisions/run_tests.sh

rspec:
	@echo "## rspec requires the stack to be running (\`make run\`)"
	$(COMPOSE) exec -e RAILS_ENV=test -e DATABASE_URL=postgres://blackops:ebwiki@postgres:5432/blackops_test web \
		bundle exec rspec spec/

all: clean run

prchecks: rspec
	$(COMPOSE) exec web bundle exec rubocop
	$(COMPOSE) exec web bundle exec brakeman -A --no-pager

.PHONY: all build clean down exec logs prchecks rspec run shell start stop test up
