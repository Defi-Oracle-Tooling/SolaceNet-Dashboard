#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--env <environment>] [--file <seed-file>]"
  echo "  --env       : Target environment (dev, test, prod). Default: dev"
  echo "  --file      : Path to seed data file. Default: ./seeds/default.sql"
  exit 1
}

# Default values
ENVIRONMENT="dev"
SEED_FILE="./seeds/default.sql"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --env) 
      ENVIRONMENT="$2"
      shift 
      ;;
    --file) 
      SEED_FILE="$2"
      shift 
      ;;
    -h|--help) show_usage ;;
    *) echo "Unknown parameter: $1"; show_usage ;;
  esac
  shift
done

echo "🌱 Seeding database for $ENVIRONMENT environment"

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

# Create seeds directory if it doesn't exist
mkdir -p ./seeds

# If the seed file doesn't exist, create a default one
if [ ! -f "$SEED_FILE" ]; then
  echo "Creating default seed file at $SEED_FILE..."
  mkdir -p "$(dirname "$SEED_FILE")"
  cat <<'EOF' > "$SEED_FILE"
-- Default seed data for SolaceNet Dashboard
-- This file contains initial data to populate the database

-- Sample users
INSERT INTO users (username, email, role, created_at)
VALUES 
  ('admin', 'admin@solacenet.com', 'admin', NOW()),
  ('user1', 'user1@example.com', 'user', NOW()),
  ('user2', 'user2@example.com', 'user', NOW())
ON CONFLICT (username) DO NOTHING;

-- Sample trust accounts
INSERT INTO trust_accounts (account_number, client_id, balance, currency, created_at)
VALUES
  ('TRUST-001', 1, 10000.00, 'USD', NOW()),
  ('TRUST-002', 2, 25000.00, 'EUR', NOW()),
  ('TRUST-003', 3, 15000.00, 'GBP', NOW())
ON CONFLICT (account_number) DO NOTHING;

-- Add more seed data as needed
EOF
  echo "Default seed file created at $SEED_FILE"
fi

echo "Executing seed file: $SEED_FILE"

# Run the seed file against the database
if [ -n "$DB_PASSWORD" ]; then
  PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SEED_FILE"
else
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SEED_FILE"
fi

if [ $? -eq 0 ]; then
  echo "✅ Database seeding completed successfully!"
else
  echo "❌ Database seeding failed!"
  exit 1
fi
