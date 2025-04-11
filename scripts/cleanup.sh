#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--env <environment>] [--all] [--node-modules] [--logs] [--temp] [--dist]"
  echo "  --env           : Target environment (dev, test, prod). Default: dev"
  echo "  --all           : Clean all temporary files, logs, build artifacts, and deployments"
  echo "  --node-modules  : Remove node_modules directory"
  echo "  --logs          : Remove all log files"
  echo "  --temp          : Remove temporary directories"
  echo "  --dist          : Remove build artifacts"
  exit 1
}

# Default values
ENVIRONMENT="dev"
CLEAN_TEMP=false
CLEAN_LOGS=false
CLEAN_DIST=false
CLEAN_NODE_MODULES=false
CLEAN_ALL=false

# Parse arguments
if [ "$#" -eq 0 ]; then
  # Default behavior if no arguments provided
  CLEAN_TEMP=true
fi

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --env) 
      ENVIRONMENT="$2"
      shift 
      ;;
    --all) CLEAN_ALL=true ;;
    --node-modules) CLEAN_NODE_MODULES=true ;;
    --logs) CLEAN_LOGS=true ;;
    --temp) CLEAN_TEMP=true ;;
    --dist) CLEAN_DIST=true ;;
    -h|--help) show_usage ;;
    *) echo "Unknown parameter: $1"; show_usage ;;
  esac
  shift
done

# If --all is specified, clean everything
if [ "$CLEAN_ALL" = true ]; then
  CLEAN_TEMP=true
  CLEAN_LOGS=true
  CLEAN_DIST=true
  CLEAN_NODE_MODULES=true
fi

echo "🧹 Starting cleanup for $ENVIRONMENT environment..."

# Clean temporary files
if [ "$CLEAN_TEMP" = true ]; then
  echo "Removing temporary files..."
  rm -rf /tmp/solacenet-temp
  rm -rf ./.cache
  rm -rf ./.temp
  rm -f ./dist.zip
  
  # Remove Azure Storage Emulator files if they exist
  rm -f ./__azurite*
  
  echo "✅ Temporary files removed"
fi

# Clean log files
if [ "$CLEAN_LOGS" = true ]; then
  echo "Removing log files..."
  rm -rf ./logs
  rm -f ./*.log
  rm -f ./npm-debug.log*
  echo "✅ Log files removed"
fi

# Clean build artifacts
if [ "$CLEAN_DIST" = true ]; then
  echo "Removing build artifacts..."
  rm -rf ./dist
  rm -rf ./build
  rm -rf ./.vite
  echo "✅ Build artifacts removed"
fi

# Clean node_modules
if [ "$CLEAN_NODE_MODULES" = true ]; then
  echo "⚠️  Removing node_modules (this may take a while)..."
  rm -rf ./node_modules
  echo "✅ node_modules removed"
fi

# Check if .env file for current environment exists and prompt for cleanup
ENV_FILE=".env.$ENVIRONMENT"
if [ -f "$ENV_FILE" ]; then
  read -p "Do you want to clean the $ENV_FILE file? (y/N): " CLEAN_ENV
  if [[ "$CLEAN_ENV" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Backing up $ENV_FILE to ${ENV_FILE}.bak"
    cp "$ENV_FILE" "${ENV_FILE}.bak"
    echo "Removing sensitive data from $ENV_FILE"
    sed -i.tmp '/PASSWORD\|SECRET\|KEY/d' "$ENV_FILE"
    rm -f "${ENV_FILE}.tmp"
    echo "✅ Environment file cleaned (backup created at ${ENV_FILE}.bak)"
  fi
fi

echo "🎉 Cleanup completed successfully!"
