FROM alpine
MAINTAINER liuxinsong <liuxinsong@uniontech.com>

RUN set -xe \
    && apk add -U rsync \
    && rm -rf /var/cache/apk/*

COPY rsyncd.* /etc/

VOLUME /share
EXPOSE 873

CMD rsync --daemon --no-detach --log-file /dev/stdout
