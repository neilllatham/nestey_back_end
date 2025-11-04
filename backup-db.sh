#!/bin/bash

# Settings
DB_NAME="nestey"
DB_USER="neill"
REPO_PATH="/Users/neill/Development/nestey/nestey-backend"
DATESTAMP=$(date +%Y-%m-%d_%H-%M)
BACKUP_FILE="backup-${DATESTAMP}.sql"
PG_DUMP="/opt/homebrew/bin/pg_dump"

# Step 1: Dump the database
$PG_DUMP -U "$DB_USER" -d "$DB_NAME" -f "$REPO_PATH/$BACKUP_FILE"

# Step 2: Keep only the last 5 backups
cd "$REPO_PATH" || exit
ls -t backup-*.sql | tail -n +6 | xargs rm -f

# Step 3: Commit and push using SSH Git remote
git add "$BACKUP_FILE"
git commit -m "Database backup on ${DATESTAMP}"
git push
