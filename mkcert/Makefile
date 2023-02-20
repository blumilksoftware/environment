SHELL := /bin/bash

CERTS_DIRECTORY=./certs

DOMAIN=*.blumilk.localhost

CERT_FILENAME=_wildcard.blumilk.localhost.pem
KEY_FILENAME=_wildcard.blumilk.localhost-key.pem

MKCERT_BINARY_LINUX=./binaries/linux/mkcert-v1.4.4-linux-amd64

get-certs-linux:
	$(shell ${MKCERT_BINARY_LINUX} --install) \
	$(shell ${MKCERT_BINARY_LINUX} \
		--cert-file=${CERTS_DIRECTORY}/${CERT_FILENAME} \
		--key-file=${CERTS_DIRECTORY}/${KEY_FILENAME} \
		${DOMAIN})

.PHONY: get-certs-linux
