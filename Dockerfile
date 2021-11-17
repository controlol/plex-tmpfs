FROM binhex/arch-plex

RUN set -ex; \
    pacman -S --noconfirm \
        cronie

ADD ./root/services /etc/supervisor/conf.d/

ADD ./root/scripts /scripts

RUN set -ex; \
    chmod +x /scripts/*.sh; \
    crontab /scripts/cron-backup
