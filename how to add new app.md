# Instructions how to add new app to existing Traefik environment

---
## Requirements
- app have to be dockerized
---
## Setup
1. Add network to the docker-compose file
```yaml
# docker-compose.yml
networks:
    traefik-proxy-blumilk-local:
        external: true
```
2. Add network **only** to the container which serve your application (nginx, apache, other built in servers, etc.)
```yaml
# docker-compose.yml
services:
    your-service:
        networks:
            - traefik-proxy-blumilk-local
```
3. Add labels to the docker compose service
```yaml
# docker-compose.yml
services:
    your-service:
        labels:
            - "traefik.enable=true"
            - "traefik.blumilk.environment=true"
            # HTTP
            - "traefik.http.routers.NAME-http-router.rule=Host(`DOMAIN.blumilk.localhost`)"
            - "traefik.http.routers.NAME-http-router.entrypoints=web"
            # MIDDLEWARES
#            - "traefik.http.routers.NAME-http-router.middlewares=https-redirect@file"
            # HTTPS
            - "traefik.http.routers.NAME-https-router.rule=Host(`DOMAIN.blumilk.localhost`)"
            - "traefik.http.routers.NAME-https-router.entrypoints=websecure"
            - "traefik.http.routers.NAME-https-router.tls=true"        
```
For `NAME` set any name (without spaces) related to your app\
For `DOMAIN` set DNS name, where your app will be available over internet, e.g. `my-app` then app will be accessible under: `my-app.blumilk.localhost`.

You can use .env file to load domain name, e.g.:
```yaml
# docker-compose.yaml

- "traefik.http.routers.<<ROUTER NAME>>.rule=Host(`${YOUR_APP_HOST_NAME}`)"
```
```dotenv
# .env file

YOUR_APP_HOST_NAME=my-app.blumilk.localhost
```

---
### Notes:
- Traefik by default will not use auto redirect from HTTP to HTTPS
To enable redirection, uncomment:\
`- "traefik.http.routers.NAME-http-router.middlewares=https-redirect@file"`

- If you will not to use Traefik to redirect traffic to your app, set label, or remove it:
```yaml
- "traefik.enable=false"
```
eventually remove added `traefik-proxy-blumilk-local` network.
- Traefik terminates TLS, so **internal traffic** to your container will be served as HTTP not HTTPS, sometimes this needs to set up trusted proxies in your app.
- Traefik will automatically detect **exposed, (not published)** ports, and use the first one. In case when your app exposes more than 1 port, 
you need to define which one Traefik should use to redirect traffic correctly. Then you have to add label:
```yaml
- "traefik.http.services.<<SERVICE NAME>>.loadbalancer.server.port=9000"
```
For `<<SERVICE NAME>>` use any name (without spaces) related to your app.\
For `9000` use expected port.

---
# Examples
### HTTP only
```yaml
services:
    your-service:
        labels:
            - "traefik.enable=true"
            - "traefik.blumilk.environment=true"
            # HTTP
            - "traefik.http.routers.NAME-http-router.rule=Host(`DOMAIN.blumilk.localhost`)"
            - "traefik.http.routers.NAME-http-router.entrypoints=web"            
```

### HTTPS only (no access over HTTP)
```yaml
services:
    your-service:
        labels:
            - "traefik.enable=true"
            - "traefik.blumilk.environment=true"
            # HTTPS
            - "traefik.http.routers.NAME-https-router.rule=Host(`DOMAIN.blumilk.localhost`)"
            - "traefik.http.routers.NAME-https-router.entrypoints=websecure"
            - "traefik.http.routers.NAME-https-router.tls=true"  
```

### HTTP and HTTPS (no auto redirection from HTTP to HTTPS)
```yaml
services:
    your-service:
        labels:
            - "traefik.enable=true"
            - "traefik.blumilk.environment=true"
            # HTTP
            - "traefik.http.routers.NAME-http-router.rule=Host(`DOMAIN.blumilk.localhost`)"
            - "traefik.http.routers.NAME-http-router.entrypoints=web"         
            # HTTPS
            - "traefik.http.routers.NAME-https-router.rule=Host(`DOMAIN.blumilk.localhost`)"
            - "traefik.http.routers.NAME-https-router.entrypoints=websecure"
            - "traefik.http.routers.NAME-https-router.tls=true"  
```
### HTTP and HTTPS (auto redirection from HTTP to HTTPS)
```yaml
# docker-compose.yml
services:
    your-service:
        labels:
            - "traefik.enable=true"
            - "traefik.blumilk.environment=true"
            # HTTP
            - "traefik.http.routers.NAME-http-router.rule=Host(`DOMAIN.blumilk.localhost`)"
            - "traefik.http.routers.NAME-http-router.entrypoints=web"
            # MIDDLEWARES
            - "traefik.http.routers.NAME-http-router.middlewares=https-redirect@file"
            # HTTPS
            - "traefik.http.routers.NAME-https-router.rule=Host(`DOMAIN.blumilk.localhost`)"
            - "traefik.http.routers.NAME-https-router.entrypoints=websecure"
            - "traefik.http.routers.NAME-https-router.tls=true"        
```
