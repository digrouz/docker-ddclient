# docker-alp-ddclient
Install ddclient into an Alpine Linux container

![ddclient](https://rnxtras.com/wp-content/uploads/edd/2014/02/dyndns-logo.png)

## Description

DDclient is a Perl client used to update dynamic DNS entries for accounts on Dynamic DNS Network Service Provider. It has the capability to update more than just dyndns and it can fetch your WAN-ipaddress in a few different ways. 

https://sourceforge.net/p/ddclient/wiki/Home/

## Usage
    docker create --name=ddclient \
      -v <path to ddclient.conf>:/etc/ddclient/ddclient.conf \
      -v /etc/localtime:/etc/localtime:ro \
      -e DOCKUID=<UID default:10007> \
      -e DOCKGID=<GID default:10007> \
      -e DOCKMAIL=<mail address> \
      -e DOCKRELAY=<smtp relay> \
      -e DOCKMAILDOMAIN=<originating mail domain> \
      digrouz/docker-alp-ddclient
      
## Environment Variables

When you start the `ddclient` image, you can adjust the configuration of the `ddclient` instance by passing one or more environment variables on the `docker run` command line.

### `DOCKUID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `10007`.

### `DOCKGID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `10007`.

### `DOCKRELAY`

This variable is not mandatory and specifies the smtp relay that will be used to send email. Do not specify any if mail notifications are not required.

### `DOCKMAIL`

This variable is not mandatory and specifies the mail that has to be used to send email. Do not specify any if mail notifications are not required.

### `DOCKMAILDOMAIN`

This variable is not mandatory and specifies the address where the mail appears to come from for user authentication. Do not specify any if mail notifications are not required.
