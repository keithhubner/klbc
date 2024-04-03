#!/bin/bash
set -e

# Define a function to handle errors
handle_error() {
    echo "An error occurred in the script at line $1"
    # You can perform any cleanup or logging actions here
}

# Set up error handling with trap
trap 'handle_error $LINENO' ERR

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
mariadb-dump --ssl -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > $BACKUP_FILE


# Optionally compress the backup file (uncomment the line below if you want to compress)
# gzip "$APP_DIR/$DB_NAME-$TIMESTAMP.sql"

# Check if mysqldump encountered any errors
# if [ $? -ne 0 ]; then
#     echo "[$LOG_TIMESTAMP] Error: mysqldump encountered an error. See $APP_DIR/logs/error.log for details." >> $APP_DIR/logs/event.log
#     rm -rf $BACKUP_FILE
# else
#     echo "[$LOG_TIMESTAMP] Backup completed successfully: $BACKUP_FILE" >> $APP_DIR/logs/event.log
# fi
