#!/bin/bash

set -e

dbdir="/config/Plex Media Server/Plug-in Support/Databases"
dbdir_tmp="/plex-db"
dbdir_backup="/config/backup-databases"
dbdir_parent="/config/Plex Media Server/Plug-in Support"

mkdir -p "$dbdir_backup"
mkdir -p "cachedir_tmp"

# copy database to backup folder if it does not exist
if [ ! -d "$dbdir_backup" ]; then
  echo "Backing up existing database..."
  rsync -acz --delete "$dbdir/" "$dbdir_backup"
  echo "Existing database backed up"
fi

# database should only be copied to tmpfs if it is empty
if [[ ( ! -d "$dbdir_tmp" ) || ( -d "$dbdir_tmp" && ! "$(ls -A $dbdir_tmp)" ) ]]; then
  echo "Copying database to tmpfs..."
  rsync -acz --delete "$dbdir_backup/" "$dbdir_tmp"
  echo "Database copied to tmpfs"
fi

if [[ ! "$(find "$dbdir_parent" -lname $dbdir_tmp)" ]]; then
  if [[ -f "$dbdir" ]]; then
    rm -r "$dbdir"
  fi

  ln -s "$dbdir_tmp" "$dbdir"
fi

function backup() {
  echo "Container stopped, performing database backup..."

  rsync -acz --delete "$dbdir_tmp/" "$dbdir_backup"

  echo "Backup was created succesfully"
}

# trap sigterm signal
trap 'backup' SIGINT SIGTERM

# set cronjob, this can probably be done in dockerfile
#crontab /scripts/cron-backup

# start command
runuser -u nobody -- /home/nobody/start.sh &

# wait forr the pid of the last exectued command
wait $!

# perform backup
backup
