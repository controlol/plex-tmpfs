FROM hotio/plex

RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        rsync && \
    # clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ADD ./root /

RUN set -ex; \
    chmod +x /scripts/backup-db.sh /etc/cont-init.d/*.sh /etc/services.d/*/run
