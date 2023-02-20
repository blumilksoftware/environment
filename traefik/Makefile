export COMPOSE_DOCKER_CLI_BUILD = 1
export DOCKER_BUILDKIT = 1

SHELL := /bin/bash

TRAEFIK_NETWORK_NAME=traefik-proxy-blumilk-local

init:
	@if [ ! -f ".env" ]; then \
	  echo "Creating .env file." ;\
	  cp .env.example .env ;\
	fi; \
	docker network create ${TRAEFIK_NETWORK_NAME} || true \
	&& docker compose up --detach

run:
	docker compose up --detach

stop:
	docker compose stop

restart: stop run

.PHONY: init run stop restart
