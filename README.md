[![auto-update](https://github.com/digrouz/docker-ddclient/actions/workflows/auto-update.yml/badge.svg)](https://github.com/digrouz/docker-ddclient/actions/workflows/auto-update.yml)
[![update-alpine](https://github.com/digrouz/docker-ddclient/actions/workflows/update-alpine.yml/badge.svg)](https://github.com/digrouz/docker-ddclient/actions/workflows/update-alpine.yml)
[![dockerhub](https://github.com/digrouz/docker-ddclient/actions/workflows/dockerhub.yml/badge.svg)](https://github.com/digrouz/docker-ddclient/actions/workflows/dockerhub.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/digrouz/ddclient)

# docker-ddclient
Install ddclient into a Linux container

![ddclient](https://rnxtras.com/wp-content/uploads/edd/2014/02/dyndns-logo.png)

## Tags

Several tags are available:
* latest: see alpine
* centos7: [Dokerfile_centos7](https://github.com/digrouz/docker-ddclient/blob/master/Dockerfile_centos7)
* alpine: [Dockerfile_alpine](https://github.com/digrouz/docker-ddclient/blob/master/Dockerfile_alpine)

## Description

DDclient is a Perl client used to update dynamic DNS entries for accounts on Dynamic DNS Network Service Provider. It has the capability to update more than just dyndns and it can fetch your WAN-ipaddress in a few different ways. 

https://sourceforge.net/p/ddclient/wiki/Home/

## Usage
    docker create --name=ddclient \
      -v <path to ddclient.conf>:/etc/ddclient/ddclient.conf \
      -v /etc/localtime:/etc/localtime:ro \
      -e DOCKUID=<UID default:10007> \
      -e DOCKGID=<GID default:10007> \
      -e DOCKUPGRADE=<0|1 default:0> \
      -e DOCKMAIL=<mail address> \
      -e DOCKRELAY=<smtp relay> \
      -e DOCKMAILDOMAIN=<originating mail domain> \
      digrouz/ddclient
      
## Environment Variables

When you start the `ddclient` image, you can adjust the configuration of the `ddclient` instance by passing one or more environment variables on the `docker run` command line.

### `DOCKUID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `10007`.

### `DOCKGID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `10007`.

### `DOCKUPGRADE`

This variable is not mandatory and specifies if the container has to launch software update at startup or not. Valid values are `0` and `1`. It has default value `0`.

### `DOCKRELAY`

This variable is not mandatory and specifies the smtp relay that will be used to send email. Do not specify any if mail notifications are not required.

### `DOCKMAIL`

This variable is not mandatory and specifies the mail that has to be used to send email. Do not specify any if mail notifications are not required.

### `DOCKMAILDOMAIN`

This variable is not mandatory and specifies the address where the mail appears to come from for user authentication. Do not specify any if mail notifications are not required.

## Notes

* The docker entrypoint can upgrade operating system at each startup. To enable this feature, just add `-e DOCKUPGRADE=1` at container creation.

## Issues

If you encounter an issue please open a ticket at [github](https://github.com/digrouz/docker-ddclient/issues)

