# Makefile for Docker Compose

# Default target, will build and run the app and its services
all: build up browse

# Build the containers as defined in the docker-compose.yml file
build:
	docker-compose build

# Start the services in the background
up run start:
	docker-compose up --detach

browse:
	open http://localhost:3000

# Stop the services
down stop:
	docker-compose down

# Show the logs of all services; using `-` to ignore errors
logs:
	-docker-compose logs --follow

# Start a shell in the app's container; using `-` to ignore errors
shell:
	-docker-compose exec web bash

# Run tests
test: up
	./dev_provisions/run_tests.sh

# Reindex Searchkick TODO
searchkick reindex:
	@echo "## Please note that searchkick requires the container to be running and"
	@echo "## takes a while to complete"
	@echo "## Reindexing..."
	docker-compose exec web bash -c 'rake searchkick:reindex:all'

# Run rspec tests TODO
rspec:
	@echo "## Please note that rspec requires the container to be running and"
	@echo "## takes a while to complete"
	docker-compose exec web bash -c 'source dev_provisions/environment.sh && rspec spec/'

# Run codeclimate TODO
codeclimate:
	@echo "## Please note that codeclimate takes a while to run and does not"
	@echo "## generate any output until all jobs are complete...."
	@echo "Running codeclimate analysis..."
	codeclimate analyze

# Clean up
clean:
	docker-compose down
	docker-compose kill
	docker-compose rm --force

# Clean up everything
nuke:
	@echo "## Please note that this is a destructive action! Use with caution."
	@echo "## This will remove all containers, volumes, and images"
	@echo "## Press Ctrl-C to cancel"
	@echo "## Press Enter to continue"
	@read
	docker-compose down --volumes --remove-orphans --rmi all

# Add phony entries for all targets; in alphabetical order
.PHONY: all build clean codeclimate down logs reindex rspec run searchkick shell start stop test up
