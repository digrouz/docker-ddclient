# docker-alp-ddclient
Install ddclient into an Alpine Linux container

![ddclient](https://rnxtras.com/wp-content/uploads/edd/2014/02/dyndns-logo.png)

## Description

DDclient is a Perl client used to update dynamic DNS entries for accounts on Dynamic DNS Network Service Provider. It has the capability to update more than just dyndns and it can fetch your WAN-ipaddress in a few different ways. 

https://sourceforge.net/p/ddclient/wiki/Home/

## Usage
    docker create --name=ddclient \
      -v <path to ddclient.conf>:/etc/ddclient.conf \
      -v /etc/localtime:/etc/localtime:ro digrouz/docker-alp-ddclient
