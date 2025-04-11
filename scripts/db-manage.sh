#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--backup] [--restore <file>] [--list] [--env <environment>]"
  echo "  --backup        : Create a new database backup"
  echo "  --restore <file>: Restore database from backup file"
  echo "  --list          : List available backups"
  echo "  --env           : Target environment (dev, test, prod). Default: dev"
  exit 1
}

# Default values
ENVIRONMENT="dev"
ACTION=""
RESTORE_FILE=""
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --backup) ACTION="backup" ;;
    --restore) 
      ACTION="restore"
      if [[ "$#" -gt 1 && ! "$2" =~ ^-- ]]; then
        RESTORE_FILE="$2"
        shift
      fi
      ;;
    --list) ACTION="list" ;;
    --env) 
      ENVIRONMENT="$2"
      shift 
      ;;
    -h|--help) show_usage ;;
    *) echo "Unknown parameter: $1"; show_usage ;;
  esac
  shift
done

# Load environment variables
if [ -f ".env.$ENVIRONMENT" ]; then
  echo "Loading environment variables from .env.$ENVIRONMENT"
  export $(grep -v '^#' .env.$ENVIRONMENT | xargs)
else
  echo "Warning: .env.$ENVIRONMENT file not found"
fi

# Ensure database connection details are available
DB_NAME="${PGDATABASE:-solacenet_db}"
DB_USER="${PGUSER:-postgres}"
DB_HOST="${PGHOST:-localhost}"
DB_PORT="${PGPORT:-5432}"
DB_PASSWORD="${PGPASSWORD:-}"

# Check if psql is available
if ! command -v psql &> /dev/null; then
  echo "❌ PostgreSQL client (psql) is not installed"
  exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to list available backups
function list_backups {
  echo "📋 Available backups:"
  if [ -d "$BACKUP_DIR" ]; then
    find "$BACKUP_DIR" -name "*.sql" -type f | sort -r
  else
    echo "No backups found (backup directory doesn't exist)"
  fi
}

# Function to create a backup
function backup_database {
  BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql"
  echo "📦 Creating backup: $BACKUP_FILE"
  
  if [ -n "$DB_PASSWORD" ]; then
    PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_FILE"
  else
    pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_FILE"
  fi
  
  if [ $? -eq 0 ]; then
    echo "✅ Backup completed successfully"
  else
    echo "❌ Backup failed"
    exit 1
  fi
}

# Function to restore a backup
function restore_database {
  if [ -z "$RESTORE_FILE" ]; then
    list_backups
    echo ""
    read -p "Enter the backup file to restore: " RESTORE_FILE
  fi
  
  if [ ! -f "$RESTORE_FILE" ]; then
    echo "❌ Backup file does not exist: $RESTORE_FILE"
    exit 1
  fi
  
  echo "🔄 Restoring database from $RESTORE_FILE"
  
  if [ -n "$DB_PASSWORD" ]; then
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$RESTORE_FILE"
  else
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$RESTORE_FILE"
  fi
  
  if [ $? -eq 0 ]; then
    echo "✅ Restore completed successfully"
  else
    echo "❌ Restore failed"
    exit 1
  fi
}

# Run the requested action
case "$ACTION" in
  "backup")
    backup_database
    ;;
  "restore")
    restore_database
    ;;
  "list")
    list_backups
    ;;
  *)
    show_usage
    ;;
esac
