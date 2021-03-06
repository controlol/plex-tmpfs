#!/usr/bin/with-contenv bash

set -e

dbdir_parent="/config/Plug-in Support"
dbdir="${dbdir_parent}/Databases"
dbdir_tmp="/plex-db"
dbdir_backup="/config/backup-databases"

mkdir -p "$dbdir_backup"
mkdir -p "cachedir_tmp"

# copy database to backup folder if it does not exist or is empty
if [[ ( ! -d "$dbdir_backup" ) || ( -d "$dbdir_backup" && ! "$(ls -A $dbdir_backup)" ) ]]; then
  echo "Backing up existing database..."
  rsync -ac --delete "$dbdir/" "$dbdir_backup"
  echo "Existing database backed up"
fi

# database should only be copied to tmpfs if it is empty
if [[ ( ! -d "$dbdir_tmp" ) || ( -d "$dbdir_tmp" && ! "$(ls -A $dbdir_tmp)" ) ]]; then
  echo "Copying database to tmpfs..."
  rsync -ac --delete --stats -h "$dbdir_backup/" "$dbdir_tmp" | grep "Total file size"
  echo "Database copied to tmpfs"
fi

# link tmpfs database to original database
if [[ ! "$(find "$dbdir_parent" -maxdepth 1 -lname $dbdir_tmp)" ]]; then
  if [[ -e "$dbdir" ]]; then
    rm -r "$dbdir"
  fi

  ln -s "$dbdir_tmp" "$dbdir"
fi
