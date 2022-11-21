FROM hotio/plex

RUN set -ex; \
    apt update; \
    apt install --no-install-recommends -y \
        rsync \
        cron; \
    rm -rf /var/lib/apt/lists/*

ADD ./root /

RUN set -ex; \
    chmod +x /scripts/backup-db.sh /etc/cont-init.d/*.sh /etc/services.d/*/run
