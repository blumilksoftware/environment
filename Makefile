TLD := blumilk.localhost
MKCERT_BINARY := ./bin/mkcert-v1.4.4-linux-amd64

CERTS_DIRECTORY := ./traefik/certs

DOMAIN := *.${TLD}
CERT_FILENAME := _wildcard.${TLD}.pem
KEY_FILENAME := _wildcard.${TLD}-key.pem

TRAEFIK_NETWORK_NAME := traefik-proxy-blumilk-local

export COMPOSE_DOCKER_CLI_BUILD = 1
export DOCKER_BUILDKIT = 1

certs:
	$(shell ${MKCERT_BINARY} --install) \
	$(shell ${MKCERT_BINARY} \
		--cert-file=${CERTS_DIRECTORY}/${CERT_FILENAME} \
		--key-file=${CERTS_DIRECTORY}/${KEY_FILENAME} \
		${DOMAIN})

init: certs
	@cd traefik && \
	[ ! -f ".env" ] && cp .env.example .env; \
	docker network inspect ${TRAEFIK_NETWORK_NAME} --format {{.Id}} 2>/dev/null || \
	docker network create ${TRAEFIK_NETWORK_NAME}

run:
	cd traefik && docker compose up --detach

stop:
	cd traefik && docker compose stop

restart: stop run

.PHONY: certs init run stop restart
