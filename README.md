# About
This package provides images for [BareOS](http://www.bareos.org) :
* Director ![License badge][license-img] [![Build Status][build-img-dir]][build-url-dir] [![Docker badge][docker-img-dir]][docker-url-dir]
* Storage Daemon ![License badge][license-img] [![Build Status][build-img-sd]][build-url-sd] [![Docker badge][docker-img-sd]][docker-url-sd]
* Client/File Daemon ![License badge][license-img] [![Build Status][build-img-fd]][build-url-fd] [![Docker badge][docker-img-fd]][docker-url-fd]
* webUI. ![License badge][license-img] [![Build Status][build-img-ui]][build-url-ui] [![Docker badge][docker-img-ui]][docker-url-ui]

It's based on Ubuntu Trusty and the BareOS package repository.

BareOS Director also required :
* PostgreSQL or MySQL as catalog backend
* SMTP Daemon as local mail router (backup reports)

Each component runs in an single container and are linked together by docker-compose.

:+1: Tested with BareOS 16.2

# Security advice
The default passwords inside the configuration files are created when building the docker image. Hence for production either build the image yourself using the sources from Github.

:o: Do not use this container for anything else, as passwords gets exposed to the BareOS containers.

# Setup 

## with [docker-compose](https://docs.docker.com/compose/) 

Exemple :
```yml
version: '2'
services:
  bareos-dir:
    #image: barcus/bareos-director:pgsql
    image: barcus/bareos-director:mysql
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos
    environment:
      - DB_PASSWORD=<PASSWORD>
      - DB_HOST=bareos-db
      - DB_PORT=3306
      - BAREOS_FD_HOST=bareos-fd
      - BAREOS_SD_HOST=bareos-sd
      - BAREOS_FD_PASSWORD=<PASSWORD>
      - BAREOS_SD_PASSWORD=<PASSWORD>
      - BAREOS_WEBUI_PASSWORD=<PASSWORD>
      - SMTP_HOST=smtpd
      - ADMIN_MAIL=your@mail.address
    depends_on:
      - bareos-db

  bareos-sd:
    image: barcus/bareos-storage
    ports:
      - 9103:9103
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos
      - <BAREOS_BKP_VOLUME_PATH>:/var/lib/bareos/storage
    environment:
      - BAREOS_SD_PASSWORD=<PASSWORD>

  bareos-fd:
    image: barcus/bareos-client
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos
    environment:
      - BAREOS_FD_PASSWORD=<PASSWORD>

  bareos-webui:
    image: barcus/bareos-webui
    ports:
      - 8080:80
    environment:
      - BAREOS_DIR_HOST=bareos-dir
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos-webui

  bareos-db:
    image: mysql:5.6
    volumes:
      - <DB_DATA_PATH>:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=<PASSWORD>

  #bareos-db:
  #  image: postgres:9.3
  #  volumes:
  #    - <DB_DATA_PATH>:/var/lib/postgresql/data
  #  environment:
  #    - POSTGRES_PASSWORD=<PASSWORD>

  smtpd:
    image: namshi/smtp
```

BareOS Director (bareos-dir)
* `<BAREOS_CONF_PATH>` is the path to share your Director config folder from the host side (optional/recommended)
* DB_PASSWORD must be same `<PASSWORD>` as BareOS Database section
* Set BAREOS_DB_PASSWORD here with a strong `<PASSWORD>`
* Set BAREOS_SD_PASSWORD here with a strong `<PASSWORD>`
* Set BAREOS_FD_PASSWORD here with a strong `<PASSWORD>`
* Set BAREOS_WEBUI_PASSWORD here with a strong `<PASSWORD>`
* SMTP_HOST is the name of smtp container
* ADMIN_MAIL is your email address

BareOS Storage Daemon (bareos-sd)
* `<BAREOS_CONF_PATH>` is the path to share your Storage config folder from the host side (optional/recommended)
* `<BAREOS_BKP_VOLUME_PATH>` is the path to share your data folder from the host side. (optional)
* BAREOS_SD_PASSWORD must be same `<PASSWORD>` as BareOS Director section

BareOS Client/File Daemon (bareos-fd)
* `<BAREOS_CONF_PATH>` is the path to share your Client config folder from the host side (optional/recommended)
* BAREOS_FD_PASSWORD must be same `<PASSWORD>` as BareOS Director section

Database MySQL or PostgreSQL (bareos-db)
Required as catalog backend, simply use the official MySQL/PostgreSQL image
* `<DB_DATA_PATH>` is the path to share your MySQL/PostgreSQL data from the host side
* Set DB_PASSWORD here with a strong `<PASSWORD>`

BareOS WebUI (bareos-webui)
* `<BAREOS_CONF_PATH>` is the path to share your WebUI config folder from the host side. (optional)
* default user is `admin`

:warning: Remember variables *_HOST must be set with container name

# Build

## Build your own BareOS images !
```bash
git clone https://github.com/barcus/bareos-director
cd bareos-director/mysql
docker build .
```
```bash
git clone https://github.com/barcus/bareos-storage
cd bareos-storage
docker build .
```
```bash
git clone https://github.com/barcus/bareos-client
cd bareos-client
docker build .
```
```bash
git clone https://github.com/barcus/bareos-webui
cd bareos-webui
docker build .
```

## Build your own Trusty base system image !
```bash
git clone https://github.com/rockyluke/docker-ubuntu
cd docker-ubuntu
./build.sh -d trusty
```

Thanks to @rockyluke :)

# Usage

## WebUI
Open http://your-docker-host:8080/bareos-webui in your browser (user: admin / pass: `<BAREOS_WEBUI_PASSWORD>`)

## bconsole
Run `docker exec -it bareos-dir bconsole`

# Links

## Github/Dockerfile
For more information visit the Github repositories :
* [bareos-director](https://github.com/barcus/bareos-director)
* [bareos-storage](https://github.com/barcus/bareos-storage)
* [bareos-client](https://github.com/barcus/bareos-client)
* [bareos-webui](https://github.com/barcus/bareos-webui)
* [docker-ubuntu](https://github.com/rockyluke/docker-ubuntu)

[license-img]: https://img.shields.io/badge/license-ISC-blue.svg
[build-img-dir]: https://travis-ci.org/barcus/bareos-director.svg?branch=master
[build-url-dir]: https://travis-ci.org/barcus/bareos-director
[docker-img-dir]: https://img.shields.io/docker/pulls/barcus/bareos-director.svg
[docker-url-dir]: https://registry.hub.docker.com/u/barcus/bareos-director
[build-img-sd]: https://travis-ci.org/barcus/bareos-storage.svg?branch=master
[build-url-sd]: https://travis-ci.org/barcus/bareos-storage
[docker-img-sd]: https://img.shields.io/docker/pulls/barcus/bareos-storage.svg
[docker-url-sd]: https://registry.hub.docker.com/u/barcus/bareos-storage
[build-img-fd]: https://travis-ci.org/barcus/bareos-client.svg?branch=master
[build-url-fd]: https://travis-ci.org/barcus/bareos-client
[docker-img-fd]: https://img.shields.io/docker/pulls/barcus/bareos-client.svg
[docker-url-fd]: https://registry.hub.docker.com/u/barcus/bareos-client
[build-img-ui]: https://travis-ci.org/barcus/bareos-webui.svg?branch=master
[build-url-ui]: https://travis-ci.org/barcus/bareos-webui
[docker-img-ui]: https://img.shields.io/docker/pulls/barcus/bareos-webui.svg
[docker-url-ui]: https://registry.hub.docker.com/u/barcus/bareos-webui
