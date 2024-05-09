# Use the official MariaDB image as the base image
FROM mariadb:latest

# Install necessary packages (if any) for backup script
RUN apt-get update && apt-get install -y \
    mariadb-client s3cmd mailutils \
    && rm -rf /var/lib/apt/lists/*

# Copy the backup script to the container
COPY backup_script.sh /usr/local/bin/backup_script.sh

# Make the backup script executable
RUN chmod +x /usr/local/bin/backup_script.sh

# Set the entrypoint to the backup script
ENTRYPOINT ["backup_script.sh"]
