#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--env <environment>]"
  echo "  --env: Target environment (dev, test, prod). Default: dev"
  exit 1
}

# Parse arguments
ENVIRONMENT="dev"

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --env) ENVIRONMENT="$2"; shift ;;
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
  echo "Error: .env.$ENVIRONMENT file not found"
  exit 1
fi

# Check for required environment variables
if [ -z "${PGHOST:-}" ] || [ -z "${PGDATABASE:-}" ] || [ -z "${PGUSER:-}" ]; then
  echo "Error: Missing required database environment variables"
  echo "Please ensure PGHOST, PGDATABASE, and PGUSER are set in .env.$ENVIRONMENT"
  exit 1
fi

echo "🗄️ Initializing database for $ENVIRONMENT environment"

# Check if psql is available
if ! command -v psql &> /dev/null; then
  echo "❌ PostgreSQL client (psql) is not installed. Please install it first."
  exit 1
fi

# Directory with SQL scripts
SQL_DIR="./src/database/migrations"

# Check if SQL directory exists
if [ ! -d "$SQL_DIR" ]; then
  echo "Creating SQL migrations directory..."
  mkdir -p "$SQL_DIR"
fi

# Run database migrations
echo "Running database migrations from $SQL_DIR..."

# Sort files to ensure they run in order (assuming filenames are prefixed with numbers)
for sql_file in $(find "$SQL_DIR" -name "*.sql" | sort); do
  echo "Executing $sql_file..."
  psql -v ON_ERROR_STOP=1 "$PGDATABASE" -f "$sql_file"
done

echo "✅ Database initialization completed!"
