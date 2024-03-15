FROM hotio/plex

RUN set -ex; \
    apk add --no-cache \
        rsync

ADD ./root /

RUN set -ex; \
    chmod +x /scripts/backup-db.sh /etc/cont-init.d/*.sh /etc/services.d/*/run
