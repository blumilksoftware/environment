# Local Blumilk Traefik environment

This repo contains default Blumilk Traefik configuration for local development environment.

# Requirements

---
- Linux system
- one free port on host system (default 301)
- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose (version 2)](https://docs.docker.com/compose/install/)
- [Taskfile](https://taskfile.dev/) (min. version 3.42.1)

# Installation

---
## Taskfile setup
### Linux

If you don't have Task binary installed, you can install it by running command below. \
If you don't want to install to `/usr/local/bin` (dir for all users in the system) change `-b` flag value. \
Be sure that provided path is in system $PATH, that binary will be available in the terminal. 
To check system paths type `$PATH` in the terminal.

```shell
sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin v3.42.1
```
_-b sets bindir or installation directory, Defaults to ./bin_ \
_-d turns on debug logging_

Other installation methods: https://taskfile.dev/installation \
GitHub: https://github.com/go-task/task \
Taskfile releases: https://github.com/go-task/task/releases

### Other OS

If you are using other OS, please contribute and create pull request.

# Task commands

---
To list all task commands just run:
```shell
task
```
### Task commands completions:

---
Add this line to `.bashrc` if you are using bash:
```
eval "$(task --completion bash)"
```
For other shells see: \
https://taskfile.dev/installation/#option-1-load-the-completions-in-your-shells-startup-config-recommended

# Project initialization

Before first use, project has to be initialized.

First, prepare `.env` file
```shell
cp .env.example .env
```

By default `.env` file is ready to go, and prepared for Blumilk local environment purposes. So no changes are needed. \
But if you need to customize it, just edit `.env` file. \
Project is flexible and all important settings are customizable via `.env` file.

### Docker network

By default, project uses `172.31.0.0/16` network subnet and requires 172.31.100.100 (Traefik) and 172.31.200.200 (Dnsmasq) IPs. \
So if you have allocated this network and IPs, you need to remove it before initialization or change network settings in `.env` file.

### Certificates and domain

By default `blumilk.local.env` domain will be used. \
mkcert generate wildcard certificate for `*.blumilk.local.env` domains.

## Project init

This command will prepare all necessary files and configs based on `.env` file.
```shell
task init
```
This need to be run only once. This command will create `.initialized` file. \
If you want to re-initialize, run `task init --force` or remove `.initialized` file.

WARNING, these files will be replaced during initialization:
- ./traefik/config/static/traefik.yml
- ./traefik/config/dynamic/certificates.yml
- ./portainer/portainer-admin-password-file - if Portainer has been created, changing password in this file won't change admin password. To change password you need to remove portainer container, volume and recreate it or check Portianer [docs](https://docs.portainer.io/advanced/reset-admin.)
- ./dns/dnsmasq/dnsmasq.d/blumilk-local-environment.conf
- ./dns/systemd/resolved.conf.d/blumilk-local-environment.conf
- .initialized

## Usage

To run environment:
```shell
task run
```

### Portainer access

By default: \
user: admin \
password: passwordpassword \
dashborad: [https://portainer.blumilk.local.env](https://portainer.blumilk.local.env)

### Traefik access
dashborad: [https://traefik.blumilk.local.env](https://traefik.blumilk.local.env)

### Redirect entry point
Traefik requires one free host port to use redirect entrypoint for `localhost` hostnames. \
By default it is `301` port. \
You can customize this host port for this entrypoint in `.env` file via `TRAEFIK_REDIRECT_ENTRYPOINT_HOST_PORT`. \

If project has been initialized already, and you changed this value, you need to initialize project again or update `regex` key in `middlewares.yml` file manually.

This entrypoint redirect permanent (301 HTTP code) to the part after `/`. \
Example:
```
http://localhost:301/https://blumilk.pl
```
will be redirected to `https://blumilk.pl`.

It is created to handle OAuth2 providers redirects URI (e.g. Google OAuth web app clients). Because you can use only `localhost`, `example.com` or real TLD domain. \
This allows us to use custom domains (e.g. `my-app.blumilk.local.env`) and OAuth locally. \

For example, redirect URI will be: `http://localhost:301/https://my-app.blumilk.local.env/something`

# Certificates

We're using *mkcert* to generate self-signed certificates to support https in local development. \
These certificates will cover a local domain ***.blumilk.local.env**.

Keep in mind that *X.509 wildcard certificates* only go **one level deep**. \
So a domain `a.blumilk.local.env` is valid but `a.b.blumilk.local.env` is not.

Certificates will be valid for **2 years**.

## Additional certificates for other domains/subdomains

By default, all 1st level subdomains under `*.blumilk.local.env` will be covered. E.g. `foo.blumilk.local.env`.

If you need to cover 2nd level subdomains under. `*.foo.blumilk.local.env`, e.g. `bar.foo.blumilk.local.env` \
you have to generate new certs. Adjust filenames and domain for your needs:
```shell
task generate-certs \
  CERT_FILENAME=_wildcard.foo.blumilk.local.env.pem \
  KEY_FILENAME=_wildcard.foo.blumilk.local.env-key.pem \
  DOMAIN=*.foo.blumilk.local.env
```

Then **add** certificates to `./traefik/config/dynamic/certificates.yml` file:
```
    - certFile: /certs/_wildcard.foo.blumilk.local.env.pem
      keyFile: /certs/_wildcard.foo.blumilk.local.env-key.pem
```

And restart Traefik (`task restart`)

# HTTPS in containers

If you need to call any `*.blumilk.local.env` subdomains via https from container, you have to add mkcert CA cert to the docker container.

To do it run container from which you want to send requests via https. \
Use container name or ID.
```shell
task copy-ca-cert-to-container CONTAINER_NAME=your-container-name
```

Now you will be able to send requests via https to `*.blumilk.local.env` domains or others generated via mkcert.

## HTTPS in browsers in containers

To use self-signed certs in browsers, we have to add root CA (from mkcert) to the trust store.

To do it, run the container from which you want to add mkcert root CA to the trust store. \
Use container name or ID.
```shell
task copy-ca-cert-to-trust-store-in-container CONTAINER_NAME=your-container-name
```

### More on mkcert

- github: https://github.com/FiloSottile/mkcert
- releases: https://github.com/FiloSottile/mkcert/releases

# Reload systemd-resolved configuration
If you changed `blumilk-local-environment.conf` in `./systemd/resolved.conf.d` after project initialization, or want to customize it, run:
```shell
task configure-systemd-resolved
```
It will copy this file to the `/etc/systemd/resolved.conf.d` and restart `systemd-resolved`.

# Using the environment with your project

Detailed instructions on how to use this environment with your project are available
[here](project_usage.md).

# Migration from previous version

1. Remove old docker stuff:
   - traefik container (`traefik-proxy-blumilk-local-container`)
   - traefik network (`traefik-proxy-blumilk-local`)
2. In projects, you need to update:
   - custom Traefik label from `traefik.blumilk.environment` to `traefik.blumilk.local.environment`
   - Traefik network from `traefik-proxy-blumilk-local` to `traefik-proxy-blumilk-local-environment`
   - domains from `blumilk.localhost` to `blumilk.local.env`
