FROM binhex/arch-plex

RUN set -e; \
    pacman -S --noconfirm \
        cronie

ADD ./root/services /etc/supervisor/conf.d/

#RUN rm /etc/supervisor/conf.d/plexmediaserver.conf

ADD ./root/scripts /scripts

RUN chmod +x /scripts/*.sh

#ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/scripts/entrypoint.sh"]
