FROM alpine:3.11
LABEL maintainer "DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>"

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' \
    APPUSER='ddclient' \
    APPUID='10007' \
    APPGID='10007'

# Copy config files
COPY root/ /

### Install Application
RUN set -x && \
    chmod 1777 /tmp && \
    . /usr/local/bin/docker-entrypoint-functions.sh && \
    MYUSER=${APPUSER} && \
    MYUID=${APPUID} && \
    MYGID=${APPGID} && \
    ConfigureUser && \
    apk upgrade --no-cache && \
    apk add --no-cache --virtual=build-deps \
      make \
      gcc \
      g++ \
      perl-dev \
      libxml2-dev \
      libressl-dev \
      wget \
      git \
      expat-dev \
    && \
    apk add --no-cache --virtual=run-deps \
      ca-certificates \
      su-exec \
      libressl \
      ssmtp \
      mailx \
      bash \
      perl \
      perl-io-socket-ssl \
      perl-io-socket-inet6 \
    && \
    wget https://cpanmin.us/ -O /usr/local/bin/cpanm && \
    chmod +x /usr/local/bin/cpanm && \
    cpanm Data::Validate::IP && \
    git clone --depth 1 https://github.com/wimpunk/ddclient /opt/ddclient && \
    mkdir /docker-entrypoint.d && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    ln -snf /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh && \
    apk del --no-cache --purge \
      build-deps  && \
    rm -rf /opt/ddclient/.git \
           /usr/local/bin/cpanm \
           /root/.cpan \
           /tmp/* \
           /var/cache/apk/*  \
           /var/tmp/*
    
### Volume

### Expose ports

### Running User: not used, managed by docker-entrypoint.sh
USER root

### Start ddclient
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["ddclient"]
