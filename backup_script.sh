#!/bin/bash

function create_directorys() {
    echo "Creating backup directory..."
    mkdir -p "$APP_DIR"
    mkdir -p "$APP_DIR/backups"
    mkdir -p "$APP_DIR/logs"
}

create_directorys 2>&1 | tee -a $APP_DIR/logs/event.log

# # Create the backup directory if it doesn't exist
# echo "Creating backup directory..." >> $APP_DIR/logs/event.log
# mkdir -p "$APP_DIR"
# mkdir -p "$APP_DIR/backups"
# mkdir -p "$APP_DIR/logs"


# Cleanup function
cleanup() {
    # Perform cleanup tasks here
    echo "Cleaning up before exit..." >> $APP_DIR/logs/event.log
    # Example: Close file descriptors, remove temporary files, etc.
    exit 0
}

trap 'cleanup' SIGINT SIGTERM

set -e

echo "Backup directory created successfully."

echo "Starting backup..."

# Generate a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
LOG_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "[$LOG_TIMESTAMP] Starting backup..." >> $APP_DIR/logs/event.log

BACKUP_FILE="$APP_DIR/backups/$DB_NAME-$TIMESTAMP.sql"

echo "Backup file: $BACKUP_FILE" >> $APP_DIR/logs/event.log


# Perform the backup using mysqldump
echo "Running mysqldump..." >> $APP_DIR/logs/event.log
mariadb-dump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > $BACKUP_FILE

# cat $BACKUP_FILE
echo "Running S3 Backup...." >> $APP_DIR/logs/event.log
s3cmd --host=${AWS_HOST}  --host-bucket=s3://${BUCKET} put --acl-${PUB_PRIV} ${BACKUP_FILE} s3://${S3_PATH}

# Adding a change to test

echo "Running Cleanup...." >> $APP_DIR/logs/event.log

# Cleanup   

# Current date in seconds
CURRENT_DATE=$(date +%s)

# List all files in the S3 bucket with their timestamps
s3cmd --host=${AWS_HOST}  --host-bucket=s3://${BUCKET} ls --recursive s3://${S3_PATH} | while read -r line; do
  # Extract the date and file path
  FILE_DATE=$(echo $line | awk '{print $1}')
  FILE_TIME=$(echo $line | awk '{print $2}')
  FILE_NAME=$(echo $line | awk '{print $4}')

  # Combine date and time, then convert to seconds since epoch
  FILE_DATETIME="$FILE_DATE $FILE_TIME"
  FILE_DATE_SECONDS=$(date -d"$FILE_DATETIME" +%s)

  # Calculate the file's age in days
  AGE=$(( ($CURRENT_DATE - $FILE_DATE_SECONDS) / 86400 ))

# Check the file name and age
  if [[ $FILE_NAME != *"CLI"* && $AGE -gt $OLDER_THAN_DAYS ]]; then
    echo "Deleting $FILE_NAME which is $AGE days old." >> $APP_DIR/logs/event.log
    s3cmd --host=${AWS_HOST}  --host-bucket=s3://${BUCKET} del "$FILE_NAME"
  else
    echo "Skipping $FILE_NAME" >> $APP_DIR/logs/event.log
  fi
done

