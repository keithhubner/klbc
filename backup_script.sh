#!/bin/bash

# Create the backup directory if it doesn't exist
mkdir -p "$APP_DIR"

# Generate a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
LOG_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

BACKUP_FILE="$APP_DIR/backups/$DB_NAME-$TIMESTAMP.sql"

# Perform the backup using mysqldump
mariadb-dump --ssl -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > $BACKUP_FILE 2>> "$APP_DIR/logs/error.log"

# Optionally compress the backup file (uncomment the line below if you want to compress)
# gzip "$APP_DIR/$DB_NAME-$TIMESTAMP.sql"

# Check if mysqldump encountered any errors
if [ $? -ne 0 ]; then
    echo "[$LOG_TIMESTAMP] Error: mysqldump encountered an error. See $APP_DIR/logs/error.log for details." >> $APP_DIR/logs/event.log
    rm -rf $BACKUP_FILE
else
    echo "[$LOG_TIMESTAMP] Backup completed successfully: $BACKUP_FILE" >> $APP_DIR/logs/event.log
fi
