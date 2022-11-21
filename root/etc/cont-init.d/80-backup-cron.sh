#!/usr/bin/with-contenv bash

set -e

if [ ! -f /setupcron ]; then
  export DB_BACKUP_INTERVAL="${DB_BACKUP_INTERVAL:-15 */3 * * *}"
  cron_file="/etc/crontab"

  # create crontask
  echo "$DB_BACKUP_INTERVAL /scripts/backup-db.sh" > "$cron_file"
  crontab "$cron_file"

  touch /setupcron
fi
