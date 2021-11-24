#!/usr/bin/with-contenv bash

dbdir_tmp="/plex-db"
dbdir_backup="/config/backup-databases"
status_file="/backup-running"

if [ ! -f "$status_file" ]; then
  touch "$status_file"
  echo "starting database backup"

  rsync -acz --delete "$dbdir_tmp/" "$dbdir_backup"

  unlink "$status_file"
  echo "database backup succesful"
fi