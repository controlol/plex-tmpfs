#!/bin/bash

dbdir_tmp="/tmp/databases"
dbdir_backup="/config/backup-databases"

rsync -acz --delete "$dbdir_tmp/" "$dbdir_backup"
