# Local Blumilk traefik environment

This repo contains default Blumilk traefik configuration for local dev environment.

## Usage

Before first setup, make sure you have the required dependencies:

    sudo apt install make libnss3-tools

Also note that ports `:80` and `:443` need to be unoccupied.

To initialize the environment:

    make init

This will:

- generate locally-trusted development certificates needed to run traefik over https
- create an `.env` file (if none exists) 
- set up a docker network

To actually run the environment:

    make run

This will start a preconfigured traefik docker container. The container will occupy your ports `:80` and `:443`. It will also automatically start with the system but you can manage it with: `make stop` and `make restart`.

Traefik dashboard will be available here:

- http: http://traefik.blumilk.localhost
- https: https://traefik.blumilk.localhost

If you want to force HTTPS, uncomment this line: \
`- "traefik.http.routers.traefik-dashboard-http-router.middlewares=https-redirect@file"`\
in `traefik/docker-compose.yaml`, and restart traefik (`make restart`).

## Sample app

You can verify the environment is working with an included sample app `whoami`. Just run (in the same directory as this file): 

    docker compose up -d

The sample app should be available here:

- http: http://whoami.blumilk.localhost
- https: https://whoami.blumilk.localhost

Optionally, you can redirect all HTTP traffic to HTTPS. To do so, uncomment: \
`- "traefik.http.routers.whoami-http-router.middlewares=https-redirect@file"` \
in `docker-compose.yaml`, and restart the container.

## Local domains

Everything with `*.localhost` will be resolved to `127.0.0.1` so there's no need to edit `/etc/hosts` file.

The environment uses domain names matching: `*.blumilk.localhost`.

## Certificates

We're using *mkcert* to generate self-signed certificates to support https in local development. These certificates will cover a local domain ***.blumilk.localhost**.

Keep in mind that *X.509 wildcard certificates* only go **one level deep**. So a domain `a.blumilk.localhost` is valid but `a.b.blumilk.localhost` is not.

Certificates will be valid for **2 years**.

### More on mkcert

- github: https://github.com/FiloSottile/mkcert
- releases: https://github.com/FiloSottile/mkcert/releases

## Docker

A docker network `traefik-proxy-blumilk-local` will be created if it does not exist.

# Using the environment with your project

Detailed instructions on how to use this environment with your project are available
[here](project_usage.md).

# Troubleshooting

- Traefik requires ports `:80` and `:443` and the container will refuse to start if something is blocking any of these.
    - to see what's listening on port 80, you can use this command: `ss -peanut | grep ":80" | grep LISTEN`
