# Instructions how to add new app to existing Traefik environment

## Requirements

- app has to be dockerized

## Setup

1. Declare a traefik network in your docker-compose file \

    It's `TRAEFIK_NETWORK_NAME` in `.env` file.
```yaml
# docker-compose.yml
networks:
  traefik-proxy-blumilk-local-environment:
        external: true
```

2. Add this network **only** to the container which serves your application (nginx, apache, or other built-in servers, etc.)

```yaml
# docker-compose.yml
services:
    your-service:
        networks:
          - traefik-proxy-blumilk-local-environment
```

3. Add labels to the docker compose service

```yaml
# docker-compose.yml
services:
    your-service:
        labels:
            - "traefik.enable=true"
            # It's `TRAEFIK_CUSTOM_LABEL_NAME` from `.env` file
            - "traefik.blumilk.local.environment=true"
            # HTTP
            - "traefik.http.routers.NAME-http-router.rule=Host(`DOMAIN.blumilk.local.env`)"
            - "traefik.http.routers.NAME-http-router.entrypoints=web"
            # MIDDLEWARES
            #- "traefik.http.routers.NAME-http-router.middlewares=https-redirect@file"
            # HTTPS
            - "traefik.http.routers.NAME-https-router.rule=Host(`DOMAIN.blumilk.local.env`)"
            - "traefik.http.routers.NAME-https-router.entrypoints=websecure"
            - "traefik.http.routers.NAME-https-router.tls=true"        
```

Where **NAME** should be replaced with your app name slug (no spaces) and **DOMAIN** should be replaced with an app name that you'll use in url, e.g.: if DOMAING is set to `my-app` then your app will be accessible with: `my-app.blumilk.local.env`.

You can also use `.env` file to provide domain name, e.g.:

```yaml
# docker-compose.yaml
- "traefik.http.routers.NAME.rule=Host(`${YOUR_APP_HOST_NAME}`)"
```

```dotenv
# .env file

YOUR_APP_HOST_NAME=my-app.blumilk.local.env
```

### Notes:

- Traefik, by default, won't redirect HTTP traffic to HTTPS. To enable this, uncomment:\
`- "traefik.http.routers.NAME-http-router.middlewares=https-redirect@file"`

- If you don't need to use **this** Traefik to redirect traffic to your app, either remove `traefik.blumilk.local.environment` label or set it to false:

```yaml
- "traefik.blumilk.local.environment=false"
```

- If you don't need to use **any** Traefik to redirect traffic to your app, either remove `traefik.enable` label or set it to false:
```yaml
- "traefik.enable=false"
```

you can also remove `traefik-proxy-blumilk-local-environment` network.

- Traefik terminates TLS, so **internal traffic** to your container will be served as HTTP not HTTPS, sometimes this needs to set up trusted proxies in your app.

- Traefik will automatically detect **exposed, (not published)** ports and use the first one. If your app exposes more than one port, you need to specify which Traefik should use to redirect traffic correctly. To do this, you can use a label:

```yaml
- "traefik.http.services.NAME.loadbalancer.server.port=9000"
```

Where **NAME** is your app name slug and **9000** is the expected port.

# Examples

### HTTP only

```yaml
# docker-compose.yml
networks:
  traefik-proxy-blumilk-local-environment:
    external: true
    
services:
    your-service:
        labels:
            - "traefik.enable=true"
            - "traefik.blumilk.local.environment=true"
            # HTTP
            - "traefik.http.routers.NAME-http-router.rule=Host(`DOMAIN.blumilk.local.env`)"
            - "traefik.http.routers.NAME-http-router.entrypoints=web"         
        networks:
          - traefik-proxy-blumilk-local-environment
```

### HTTPS only (no access over HTTP)

```yaml
# docker-compose.yml
networks:
  traefik-proxy-blumilk-local-environment:
    external: true
    
services:
    your-service:
        labels:
            - "traefik.enable=true"
            - "traefik.blumilk.local.environment=true"
            # HTTPS
            - "traefik.http.routers.NAME-https-router.rule=Host(`DOMAIN.blumilk.local.env`)"
            - "traefik.http.routers.NAME-https-router.entrypoints=websecure"
            - "traefik.http.routers.NAME-https-router.tls=true"
        networks:
          - traefik-proxy-blumilk-local-environment
```

### HTTP and HTTPS (no auto redirection from HTTP to HTTPS)

```yaml
# docker-compose.yml
networks:
  traefik-proxy-blumilk-local-environment:
    external: true

services:
    your-service:
        labels:
            - "traefik.enable=true"
            - "traefik.blumilk.local.environment=true"
            # HTTP
            - "traefik.http.routers.NAME-http-router.rule=Host(`DOMAIN.blumilk.local.env`)"
            - "traefik.http.routers.NAME-http-router.entrypoints=web"         
            # HTTPS
            - "traefik.http.routers.NAME-https-router.rule=Host(`DOMAIN.blumilk.local.env`)"
            - "traefik.http.routers.NAME-https-router.entrypoints=websecure"
            - "traefik.http.routers.NAME-https-router.tls=true"  
        networks:
          - traefik-proxy-blumilk-local-environment
```

### HTTP and HTTPS (auto redirection from HTTP to HTTPS)

```yaml
# docker-compose.yml
networks:
  traefik-proxy-blumilk-local-environment:
    external: true

services:
    your-service:
        labels:
            - "traefik.enable=true"
            - "traefik.blumilk.local.environment=true"
            # HTTP
            - "traefik.http.routers.NAME-http-router.rule=Host(`DOMAIN.blumilk.local.env`)"
            - "traefik.http.routers.NAME-http-router.entrypoints=web"
            # MIDDLEWARES
            - "traefik.http.routers.NAME-http-router.middlewares=https-redirect@file"
            # HTTPS
            - "traefik.http.routers.NAME-https-router.rule=Host(`DOMAIN.blumilk.local.env`)"
            - "traefik.http.routers.NAME-https-router.entrypoints=websecure"
            - "traefik.http.routers.NAME-https-router.tls=true"        
        networks:
          - traefik-proxy-blumilk-local-environment
```
