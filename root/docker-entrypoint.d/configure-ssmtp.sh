#!/usr/bin/env bash

. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYGID="${APPGID}"
MYUID="${APPUID}"


if [ -f /etc/ssmtp/ssmtp.conf ];then
# Configure relay
  if [ -n "${DOCKRELAY}" ]; then
    DockLog "ssmtp: Configuring smtp relay"
    sed -i "s|mailhub=mail|mailhub=${DOCKRELAY}|i" /etc/ssmtp/ssmtp.conf
  fi
# Configure root
  if [ -n "${DOCKMAIL}" ]; then
    DockLog "ssmtp: Configuring root mail"
    sed -i "s|root=postmaster|root=${DOCKMAIL}|i" /etc/ssmtp/ssmtp.conf
  fi
# Configure domain
  if [ -n "${DOCKMAILDOMAIN}" ]; then
    DockLog "ssmtp: Configuring rewriteDomain"
    sed -i "s|#rewriteDomain=.*|rewriteDomain=${DOCKMAILDOMAIN}|i" /etc/ssmtp/ssmtp.conf
  fi
fi
