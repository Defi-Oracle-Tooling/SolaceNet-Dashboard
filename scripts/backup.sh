#!/bin/bash
# Script for backing up the database

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
BACKUP_DIR="/backups"
DB_NAME="solacenet_db"
DB_USER="admin"
DB_HOST="localhost"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql"

# Function to check if the backup directory exists
check_backup_dir() {
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory does not exist. Creating it at $BACKUP_DIR."
    mkdir -p "$BACKUP_DIR"
  fi
}

# Function to perform the database backup
backup_database() {
  echo "Backing up database: $DB_NAME"
  pg_dump -U "$DB_USER" -h "$DB_HOST" "$DB_NAME" > "$BACKUP_FILE"
  echo "Backup completed: $BACKUP_FILE"
}

# Main script execution
check_backup_dir
backup_database
