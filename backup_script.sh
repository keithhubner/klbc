#!/bin/bash
# Cleanup function


# Array of environment variables
env_vars=("DB_HOST" "DB_USER" "DB_PASSWORD" "DB_NAME" "BUCKET" "S3_PATH" "AWS_HOST" "PUB_PRIV" "OLDER_THAN_DAYS")
for var in "${env_vars[@]}"
do
    if [ -z "${!var}" ]; then
        echo "$var is not set. Exiting..."
        exit 1
    fi
done

cleanup() {
    # Perform cleanup tasks here
    echo "No errors occurred. Exiting..." 
    echo "Cleaning up before exit..." 
    # Example: Close file descriptors, remove temporary files, etc.
    exit 0
}
# Error function
err() {
    # Perform cleanup tasks here
    echo "An error occurred. Exiting..." 
    # Example: Close file descriptors, remove temporary files, etc.
    exit 0
}

trap 'cleanup' SIGINT SIGTERM
trap 'err' ERR

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
LOG_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "Creating backup directory..."
mkdir -p "$APP_DIR"
mkdir -p "$APP_DIR/backups"
mkdir -p "$APP_DIR/logs"
echo "Backup directory created successfully."
# create log file
touch "$LOGFILE" || { echo "Cannot write to $LOGFILE"; exit 1; }
echo "Log file: $LOGFILE"

LOGFILE="$APP_DIR/logs/backup-$TIMESTAMP.log"
BACKUP_FILE="$APP_DIR/backups/$DB_NAME-$TIMESTAMP.sql"

# Current date in seconds
CURRENT_DATE=$(date +%s)

function run_backup() {
    echo "Backup file: $BACKUP_FILE"
    echo "[$LOG_TIMESTAMP] Starting backup..." 
    echo "Running mysqldump..."
    mariadb-dump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > $BACKUP_FILE
    echo "Backup finished."
}

function run_s3_backup() {
    echo "Running S3 Backup...."
    echo "Uploading $BACKUP_FILE to S3..."
    s3cmd --host=${AWS_HOST}  --host-bucket=s3://${BUCKET} put --acl-${PUB_PRIV} $BACKUP_FILE s3://${S3_PATH}
}

function cleanup() {
    echo "Running Cleanup...." 
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
      echo "Deleting $FILE_NAME which is $AGE days old." 
      s3cmd --host=${AWS_HOST}  --host-bucket=s3://${BUCKET} del "$FILE_NAME"
    else
      echo "Skipping $FILE_NAME" 
    fi
  done
}

function main() {
    run_backup 
    run_s3_backup 
    cleanup 
}

main | 2>&1 tee -a $LOGFILE





