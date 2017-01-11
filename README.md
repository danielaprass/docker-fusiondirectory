# docker-fusiondirectory

This image was created from the original [docker-fusiondirectory](https://github.com/hrektts/docker-fusiondirectory) image by [Katsutoshi Horie](https://github.com/hrektts).

The only modification is on the FusionDirectory's version, witch is 1.0.17-1.

[![Travis Build Status](https://travis-ci.org/hrektts/docker-fusiondirectory.svg?branch=master)](https://travis-ci.org/hrektts/docker-fusiondirectory)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

Dockerfile to build a [FusionDirectory](https://www.fusiondirectory.org/)
container image.

Quick Start
-----------

The easiest way to launch the container is using [docker-compose](https://docs.docker.com/compose/):

``` shell
wget https://raw.githubusercontent.com/hrektts/docker-fusiondirectory/master/docker-compose.yml
docker-compose up
```

Otherwise, you can manually launch the container using the docker command:

``` shell
docker run -p 80:80 \
  -e LDAP_DOMAIN="example.org" \
  -e LDAP_HOST="ldap.example.org" \
  -e LDAP_ADMIN_PASSWORD="password" \
  -d hrektts/fusiondirectory:latest
```

Alternatively, you can link this container with previously launched LDAP
container image as follows:

``` shell
docker run --name ldap -p 389:389 \
  -e LDAP_ORGANISATION="Example Organization" \
  -e LDAP_DOMAIN="example.org" \
  -e LDAP_ADMIN_PASSWORD="password" \
  -e FD_ADMIN_PASSWORD="fdadminpassword" \
  -d hrektts/fusiondirectory-openldap:latest

docker run --name fusiondirectory -p 10080:80 --link ldap:ldap \
  -d hrektts/fusiondirectory:latest
```

Access `http://localhost:10080/fd` with your browser and login using the
administrator account:

- username: fd-admin
- password: (the value you specified in FD_ADMIN_PASSWORD)
