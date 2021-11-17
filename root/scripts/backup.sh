#!/bin/bash

dbdir_tmp="/plex-db"
dbdir_backup="/config/backup-databases"

rsync -acz --delete "$dbdir_tmp/" "$dbdir_backup"
