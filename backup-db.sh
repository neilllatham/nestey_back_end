#!/bin/bash

# Settings
DB_NAME="nestey"
DB_USER="neill"
REPO_PATH="/Users/neill/Development/nestey/nestey-backend"
DATESTAMP=$(date +%Y-%m-%d_%H-%M)
BACKUP_FILE="backup-${DATESTAMP}.sql"
PG_DUMP="/opt/homebrew/bin/pg_dump"

# Logging function
log() {
    echo "$(date): $1"
}

log "Starting database backup for $DB_NAME"

# Step 1: Dump the database
log "Creating database dump..."
if $PG_DUMP -U "$DB_USER" -d "$DB_NAME" -f "$REPO_PATH/$BACKUP_FILE"; then
    log "Database dump created successfully: $BACKUP_FILE"
else
    log "ERROR: Database dump failed"
    exit 1
fi

# Step 2: Keep only the last 5 backups
log "Cleaning up old backups..."
cd "$REPO_PATH" || exit
ls -t backup-*.sql | tail -n +6 | xargs rm -f
log "Old backups cleaned up"

# Step 3: Commit and push using SSH Git remote
log "Adding backup to git..."
if git add "$BACKUP_FILE"; then
    log "File added to git successfully"
else
    log "ERROR: Failed to add file to git"
    exit 1
fi

log "Committing backup..."
if git commit -m "Database backup on ${DATESTAMP}"; then
    log "Commit successful"
else
    log "ERROR: Commit failed"
    exit 1
fi

log "Pushing to remote repository..."
if git push origin main; then
    log "Push successful"
else
    log "ERROR: Push failed"
    exit 1
fi

log "Database backup completed successfully"
