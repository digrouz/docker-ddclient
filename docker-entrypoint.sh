#!/usr/bin/env bash

MYUSER="ddclient"
MYGID="10007"
MYUID="10007"
OS=""
MYUPGRADE="0"

DectectOS(){
  if [ -e /etc/alpine-release ]; then
    OS="alpine"
  elif [ -e /etc/os-release ]; then
    if grep -q "NAME=\"Ubuntu\"" /etc/os-release ; then
      OS="ubuntu"
    fi
    if grep -q "NAME=\"CentOS Linux\"" /etc/os-release ; then
      OS="centos"
    fi
  fi
}

AutoUpgrade(){
  if [ "$(id -u)" = '0' ]; then
    if [ -n "${DOCKUPGRADE}" ]; then
      MYUPGRADE="${DOCKUPGRADE}"
    fi
    if [ "${MYUPGRADE}" == 1 ]; then
      if [ "${OS}" == "alpine" ]; then
        apk --no-cache upgrade
        rm -rf /var/cache/apk/*
      elif [ "${OS}" == "ubuntu" ]; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get -y --no-install-recommends dist-upgrade
        apt-get -y autoclean
        apt-get -y clean
        apt-get -y autoremove
        rm -rf /var/lib/apt/lists/*
      elif [ "${OS}" == "centos" ]; then
        yum upgrade -y
        yum clean all
        rm -rf /var/cache/yum/*
      fi
    fi
  fi
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

ConfigureUser () {
  if [ "$(id -u)" = '0' ]; then
    # Managing user
    if [ -n "${DOCKUID}" ]; then
      MYUID="${DOCKUID}"
    fi
    # Managing group
    if [ -n "${DOCKGID}" ]; then
      MYGID="${DOCKGID}"
    fi
    local OLDHOME
    local OLDGID
    local OLDUID
    if grep -q "${MYUSER}" /etc/passwd; then
      OLDUID=$(id -u "${MYUSER}")
    fi
    if grep -q "${MYUSER}" /etc/group; then
      OLDGID=$(id -g "${MYUSER}")
    fi
    if [ -n "${OLDUID}" ] && [ "${MYUID}" != "${OLDUID}" ]; then
      OLDHOME=$(grep "$MYUSER" /etc/passwd | awk -F: '{print $6}')
      if [ "${OS}" == "alpine" ]; then
        deluser "${MYUSER}"
      else
        userdel "${MYUSER}"
      fi
      DockLog "Deleted user ${MYUSER}"
    fi
    if grep -q "${MYUSER}" /etc/group; then
      if [ "${MYGID}" != "${OLDGID}" ]; then
        if [ "${OS}" == "alpine" ]; then
          delgroup "${MYUSER}"
        else
          groupdel "${MYUSER}"
        fi
        DockLog "Deleted group ${MYUSER}"
      fi
    fi
    if ! grep -q "${MYUSER}" /etc/group; then
      if [ "${OS}" == "alpine" ]; then
        addgroup -S -g "${MYGID}" "${MYUSER}"
      else
        groupadd -r -g "${MYGID}" "${MYUSER}"
      fi
      DockLog "Created group ${MYUSER}"
    fi
    if ! grep -q "${MYUSER}" /etc/passwd; then
      if [ -z "${OLDHOME}" ]; then
        OLDHOME="/home/${MYUSER}"
        mkdir "${OLDHOME}"
        DockLog "Created home directory ${OLDHOME}"
      fi
      if [ "${OS}" == "alpine" ]; then
        adduser -S -D -H -s /sbin/nologin -G "${MYUSER}" -h "${OLDHOME}" -u "${MYUID}" "${MYUSER}"
      else
        useradd --system --shell /sbin/nologin --gid "${MYGID}" --home-dir "${OLDHOME}" --uid "${MYUID}" "${MYUSER}"
      fi
      DockLog "Created user ${MYUSER}"

    fi
    if [ -n "${OLDUID}" ] && [ "${MYUID}" != "${OLDUID}" ]; then
      DockLog "Fixing permissions for user ${MYUSER}"
      find / -user "${OLDUID}" -exec chown ${MYUSER} {} \; &> /dev/null
      if [ "${OLDHOME}" == "/home/${MYUSER}" ]; then
        chown -R "${MYUSER}" "${OLDHOME}"
        chmod -R u+rwx "${OLDHOME}"
      fi
      DockLog "... done!"
    fi
    if [ -n "${OLDGID}" ] && [ "${MYGID}" != "${OLDGID}" ]; then
      DockLog "Fixing permissions for group ${MYUSER}"
      find / -group "${OLDGID}" -exec chgrp ${MYUSER} {} \; &> /dev/null
      if [ "${OLDHOME}" == "/home/${MYUSER}" ]; then
        chown -R :"${MYUSER}" "${OLDHOME}"
        chmod -R ga-rwx "${OLDHOME}"
      fi
      DockLog "... done!"
    fi
  fi
}

DockLog(){
  if [ "${OS}" == "centos" ] || [ "${OS}" == "alpine" ]; then
    echo "${1}"
  else
    logger "${1}"
  fi
}

ConfigureSsmtp () {
  # Customizing sstmp
  if [ -f /etc/ssmtp/ssmtp.conf ];then
    # Configure relay
    if [ -n "${DOCKRELAY}" ]; then
      sed -i "s|mailhub=mail|mailhub=${DOCKRELAY}|i" /etc/ssmtp/ssmtp.conf
    fi
    # Configure root
    if [ -n "${DOCKMAIL}" ]; then
      sed -i "s|root=postmaster|root=${DOCKMAIL}|i" /etc/ssmtp/ssmtp.conf
    fi
    # Configure domain
    if [ -n "${DOCKMAILDOMAIN}" ]; then
      sed -i "s|#rewriteDomain=.*|rewriteDomain=${DOCKMAILDOMAIN}|i" /etc/ssmtp/ssmtp.conf
    fi
  fi
}

DectectOS
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
    DockLog "Starting app: ${1}"
    exec su-exec "${MYUSER}" /opt/ddclient/ddclient -foreground -daemon 300 -syslog -pid /var/run/ddclient/ddclient.pid
else
  DockLog "Starting app: ${@}"
  exec "$@"
fi
