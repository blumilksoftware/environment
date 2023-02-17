## environment
Blumilk traefik configuration for shared development environment.

---
### Instructions
Go to `/traefik` dir and follow instructions from the `readme.md`.

---
### Usage

used docker network:\
`traefik-proxy-blumilk-local`

used domain names:\
`*.blumilk.localhost`

for `*` you can put anything you want (see details in `/mkcert` readme)

---
### Example app
You can check example project (whoami).
Just run `docker compose up -d` and example app will be run:

http: http://whoami.blumilk.localhost\
https: https://whoami.blumilk.localhost

If you want to enable redirection from HTTP to HTTPS, uncomment:\
`- "traefik.http.routers.whoami-http-router.middlewares=https-redirect@file"`\
in docker-compose.yaml, and restart container.

---
# How to add new app:
[Add new app - instruction](how%20to%20add%20new%20app.md)
