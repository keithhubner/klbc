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
mariadb-dump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > $BACKUP_FILE

# cat $BACKUP_FILE
echo "Running S3 Backup...."
s3cmd --host=${AWS_HOST}  --host-bucket=s3://${BUCKET} put --acl-${PUB_PRIV} ${BACKUP_FILE} s3://${S3_PATH}

# Adding a change to test

echo "Running Cleanup...."  

# Cleanup   

#!/bin/bash

# Specify the number of days
OLDER_THAN_DAYS=30

# Current date in seconds
CURRENT_DATE=$(date +%s)

# List all files in the S3 bucket with their timestamps
s3cmd ls s3://${BUCKET}/ --recursive | while read -r line; do
  # Extract the date and file path
  FILE_DATE=$(echo $line | awk '{print $1}')
  FILE_TIME=$(echo $line | awk '{print $2}')
  FILE_NAME=$(echo $line | awk '{print $4}')

  # Combine date and time, then convert to seconds since epoch
  FILE_DATETIME="$FILE_DATE $FILE_TIME"
  FILE_DATE_SECONDS=$(date -d"$FILE_DATETIME" +%s)

  # Calculate the file's age in days
  AGE=$(( ($CURRENT_DATE - $FILE_DATE_SECONDS) / 86400 ))

  # If the file is older than the specified number of days, delete it
  if [ $AGE -gt $OLDER_THAN_DAYS ]; then
    echo "Deleting $FILE_NAME which is $AGE days old."
    s3cmd del $FILE_NAME
  fi
done
