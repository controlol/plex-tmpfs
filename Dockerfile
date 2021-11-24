FROM hotio/plex

RUN set -ex; \
    apt install --no-install-recommends -y \
        cron

ADD ./root/services /etc/supervisor/conf.d/

ADD ./root/scripts /scripts

RUN set -ex; \
    chmod +x /scripts/*.sh; \
    crontab /scripts/cron-backup
