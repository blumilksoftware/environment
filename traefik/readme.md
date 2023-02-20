# Overview
This folder contains Traefik proxy, to manage traffic between dockerized apps.

Traefik docker network:\
**traefik-proxy-blumilk-local**

---
# Usage

Go to `mkcert` dir and generate certificates. See `readme.md`.\
Cut generated certs and paste in `/crets` dir in traefik directory

Init traefik:
```
make init
```
Init command need to be run at least once.
Then you can run traefik via `make run`
---
Traefik will be accessible under:

HTTP: [http://traefik.blumilk.localhost](http://traefik.blumilk.localhost)\
HTTPS [https://traefik.blumilk.localhost](https://traefik.blumilk.localhost)

If you want to enable redirection from HTTP to HTTPS, uncomment:
```
- "traefik.http.routers.traefik-dashboard-http-router.middlewares=https-redirect@file"
```
in `docker-compose.yaml`, and restart traefik (`make restart`).

### Make commands:
`make init` - init traefik container\
`make run` - run traefik container\
`make stop` - stop traefik container\
`make restart` - restart traefik container

---
# Troubleshooting
- Traefik listen on ports 80 and 443, so these ports need to be free.
