FROM alpine:latest
LABEL maintainer "DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>"

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' 

### Install Application
RUN apk upgrade --no-cache && \
    apk add --no-cache --virtual=build-deps \
      make \
      gcc \
      g++ \
      perl-dev \
      libxml2-dev \
      libressl-dev \
      wget \
      git \
      expat-dev 
    && \
    apk add --no-cache --virtual=run-deps \
      ca-certificates \
      su-exec \
      libressl \
      ssmtp \
      mailx \
      bash \
      perl 
    && \
    wget https://cpanmin.us/ -O /usr/local/bin/cpanm && \
    chmod +x /usr/local/bin/cpanm && \
    /usr/local/bin/cpanm  IO::Socket::SSL JSON::Any IO::Socket::INET6 Data::Validate::IP && \
    git clone --depth 1 https://github.com/wimpunk/ddclient /opt/ddclient && \
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
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["ddclient"]
