#!/bin/bash
# Script for restoring the database from a backup

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
BACKUP_DIR="/backups"
DB_NAME="solacenet_db"
DB_USER="admin"
DB_HOST="localhost"

# Function to list available backups
list_backups() {
  echo "Available backups:"
  ls -1 "$BACKUP_DIR" | grep "$DB_NAME" || echo "No backups found."
}

# Function to restore the database
restore_database() {
  read -p "Enter the backup file to restore: " BACKUP_FILE
  BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

  if [ ! -f "$BACKUP_PATH" ]; then
    echo "Backup file does not exist: $BACKUP_PATH"
    exit 1
  fi

  echo "Restoring database: $DB_NAME from $BACKUP_PATH"
  psql -U "$DB_USER" -h "$DB_HOST" "$DB_NAME" < "$BACKUP_PATH"
  echo "Restore completed."
}

# Main script execution
list_backups
restore_database
