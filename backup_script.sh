#!/bin/bash

# Cleanup function
cleanup() {
    # Perform cleanup tasks here
    echo "Cleaning up before exit..."
    # Example: Close file descriptors, remove temporary files, etc.
    exit 0
}

trap 'cleanup' SIGINT SIGTERM

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
mariadb-dump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" | s3cmd put --host=${AWS_HOST}  --host-bucket=s3://${BUCKET} put --acl-${PUB_PRIV} ${BACKUP_FILE} s3://${S3_PATH}

# cat $BACKUP_FILE
# echo "Running S3 Backup...."
# s3cmd --host=${AWS_HOST}  --host-bucket=s3://${BUCKET} put --acl-${PUB_PRIV} ${BACKUP_FILE} s3://${S3_PATH}

cleanup