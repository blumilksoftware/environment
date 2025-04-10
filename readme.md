# Local Blumilk Traefik environment

This repo contains default Blumilk traefik configuration for local development environment.

# Requirements

---
- Linux system
- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose (version 2)](https://docs.docker.com/compose/install/)
- [Taskfile](https://taskfile.dev/) (version 3.42.1)

# Installation

---
## Taskfile setup
### Linux

If you don't have Task binary installed, you can install it by running:

```shell
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin v3.42.1 
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

By default:
user: admin
password: passwordpassword
dashborad: [https://portainer.blumilk.local.env](https://portainer.blumilk.local.env)

### Traefik access
dashborad: [https://traefik.blumilk.local.env](https://traefik.blumilk.local.env)

# Certificates

We're using *mkcert* to generate self-signed certificates to support https in local development. These certificates will cover a local domain ***.blumilk.local.env**.

Keep in mind that *X.509 wildcard certificates* only go **one level deep**. So a domain `a.blumilk.local.env` is valid but `a.b.blumilk.local.env` is not.

Certificates will be valid for **2 years**.

## Additional certificates for other domains/subdomains

By default, all 1st level subdomains under `*.blumilk.local.env` will be covered. E.g. `foo.blumilk.local.env`.

If you need to cover 2nd level subdomains under. `*.foo.blumilk.local.env`, e.g. `bar.foo.blumilk.local.env` \
you have to generate new certs:
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

And restart Traefik (task restart)

# HTTPS in containers

If you need to call any `*.blumilk.local.env` subdomains via https, you have to add mkcert CA cert to the docker container.

To do it run container from which you want to send requests via https. \
Use container name or ID.
```shell
task copy-ca-cert-to-container CONTAINER_NAME=your-container-name
```

Now you will be able to send requests via https to `*.blumilk.local.env` domains.

### More on mkcert

- github: https://github.com/FiloSottile/mkcert
- releases: https://github.com/FiloSottile/mkcert/releases

# Using the environment with your project

Detailed instructions on how to use this environment with your project are available
[here](project_usage.md).
