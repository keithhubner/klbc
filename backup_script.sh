#!/bin/bash
set -e

# Create the backup directory if it doesn't exist
echo "Creating backup directory..."
mkdir -p "$APP_DIR"
mkdir -p "$APP_DIR/backups"
mkdir -p "$APP_DIR/logs"

echo "Backup directory created successfully."

echo "Starting backup..."

# Generate a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
LOG_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "[$LOG_TIMESTAMP] Starting backup..." >> $APP_DIR/logs/event.log

BACKUP_FILE="$APP_DIR/backups/$DB_NAME-$TIMESTAMP.sql"
echo "Backup file: $BACKUP_FILE"


# Perform the backup using mysqldump
# mariadb-dump --ssl -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > $BACKUP_FILE
mariadb-dump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > $BACKUP_FILE

cat $BACKUP_FILE
