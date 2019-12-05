#!/usr/bin/env bash

. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYUID="${APPUID}"
MYGID="${APPGID}"

AutoUpgrade
ConfigureUser
ConfigureSsmtp

if [ "${1}" == 'ddclient' ]; then
    if [ ! -d /var/run/ddclient ]; then
      DockLog "Creating /var/run/ddclient"
      mkdir /var/run/ddclient
    fi
    if [ -d /var/run/ddclient ]; then
      DockLog "Fixing permissions on /var/run/ddclient"
      chown -R "${MYUSER}":"${MYUSER}" /var/run/ddclient
      chmod 0750 /var/run/ddclient
    fi
    if [ ! -d /var/cache/ddclient ]; then
      DockLog "Creating /var/cache/ddclient"
      mkdir /var/cache/ddclient
    fi
    if [ -d /var/cache/ddclient ]; then
      DockLog "Fixing permissions on /var/cache/ddclient"
      chown -R "${MYUSER}":"${MYUSER}" /var/cache/ddclient
      chmod 0750 /var/cache/ddclient
    fi
    if [ ! -d /etc/ddclient ]; then
      DockLog "Creating /etc/ddclient"
      mkdir /etc/ddclient
    fi
    if [ -d /etc/ddclient ]; then
      DockLog "Fixing permissions on /etc/ddclient"
      chown -R "${MYUSER}":"${MYUSER}" /etc/ddclient
      chmod 0750 /etc/ddclient
    fi

    RunDropletEntrypoint

    DockLog "Starting app: ${1}"
    exec su-exec "${MYUSER}" /opt/ddclient/ddclient -foreground -daemon 300 -syslog -pid /var/run/ddclient/ddclient.pid
else
  DockLog "Starting app: ${@}"
  exec "$@"
fi
