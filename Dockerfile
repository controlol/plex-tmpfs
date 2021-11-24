FROM hotio/plex

RUN set -ex; \
    apt update; \
    apt install --no-install-recommends -y \
        cron; \
    rm -rf /var/lib/apt/lists/*

ADD ./root /

RUN set -ex; \
    crontab /etc/crontab/root
