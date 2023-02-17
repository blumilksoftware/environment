# Overview
This directory will help to generate self-signed certificates, \
for local development under Blumilk projects.

Domain: ***.blumilk.localhost**\
X.509 wildcards only go **one level deep**. See examples.

`.localhost` will be autoresolve to 127.0.0.1 by TLD, \
so you don't need to edit hosts file.

Valid example domains:
- a.blumilk.localhost
- b.blumilk.localhost
- foo.blumilk.localhost
- foo-bar.blumilk.localhost

Invalid example domains:
- a.b.blumilk.localhost
- foo.bar.blumilk.localhost
---
Certificates will be created in `/certs` directory.\
Certificates will be valid for **2 years**.

---
## Usage

### Linux
- install required dependencies:
```
sudo apt install libnss3-tools
```
- generate certificates
```
make get-certs-linux
```
---
### mkcert:
- github: https://github.com/FiloSottile/mkcert
- releases: https://github.com/FiloSottile/mkcert/releases
