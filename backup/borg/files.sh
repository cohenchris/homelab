#!/bin/bash
# Backup files
# To restore: borg extract $BORG_REPO::$BACKUP_NAME
#   note: execute this where you would like the 'files' folder to be placed

# Source env file and prepare env vars
BACKUP_TYPE=$(basename $0 | cut -d "." -f 1)
source $(dirname "$0")/env
DIRNAME=$(basename $FILES_DIR)
STATUS=SUCCESS

# Go to directory that we will backup
cd $FILES_DIR
cd ../

# Backup to local drive
export BORG_REPO=$FILES_BACKUP_DIR
echo "LOCAL BACKUP" >> $MAIL_FILE
backup_and_prune

# Backup to backup server
export BORG_REPO="$BACKUP_SERVER:$FILES_BACKUP_DIR"
echo "REMOTE BACKUP" >> $MAIL_FILE
backup_and_prune

# Backup to Backblaze B2
# b2 sync --delete --replaceNewer $DIRNAME b2://cc-files-backup
cd $FILES_BACKUP_DIR
b2 sync . b2://$FILES_BACKUP_BUCKET
mail_log $? "b2 backup"

finish
