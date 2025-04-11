#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--update] [--check] [--audit] [--dedupe] [--clean]"
  echo "  --update  : Update all dependencies"
  echo "  --check   : Check for outdated dependencies"
  echo "  --audit   : Run security audit"
  echo "  --dedupe  : Deduplicate dependencies"
  echo "  --clean   : Clean node_modules and reinstall"
  exit 1
}

# Default actions
DO_UPDATE=false
DO_CHECK=false
DO_AUDIT=false
DO_DEDUPE=false
DO_CLEAN=false

# If no arguments, show usage
if [ "$#" -eq 0 ]; then
  show_usage
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --update) DO_UPDATE=true ;;
    --check) DO_CHECK=true ;;
    --audit) DO_AUDIT=true ;;
    --dedupe) DO_DEDUPE=true ;;
    --clean) DO_CLEAN=true ;;
    -h|--help) show_usage ;;
    *) echo "Unknown parameter: $1"; show_usage ;;
  esac
  shift
done

# Function to check if pnpm is installed
function check_pnpm {
  if ! command -v pnpm &> /dev/null; then
    echo "❌ pnpm is not installed. Please install it first."
    exit 1
  fi
}

# Check for outdated dependencies
function check_outdated {
  echo "🔍 Checking for outdated dependencies..."
  pnpm outdated
}

# Update dependencies
function update_dependencies {
  echo "🔄 Updating dependencies..."
  pnpm update --latest
  echo "✅ Dependencies updated"
}

# Run security audit
function audit_dependencies {
  echo "🛡️ Running security audit..."
  pnpm audit
}

# Deduplicate dependencies
function dedupe_dependencies {
  echo "🧹 Deduplicating dependencies..."
  pnpm dedupe
  echo "✅ Dependencies deduplicated"
}

# Clean and reinstall
function clean_dependencies {
  echo "🗑️ Removing node_modules..."
  rm -rf node_modules
  echo "📦 Reinstalling dependencies..."
  pnpm install
  echo "✅ Dependencies reinstalled"
}

# Main execution
check_pnpm

if [ "$DO_CHECK" = true ]; then
  check_outdated
fi

if [ "$DO_UPDATE" = true ]; then
  update_dependencies
fi

if [ "$DO_AUDIT" = true ]; then
  audit_dependencies
fi

if [ "$DO_DEDUPE" = true ]; then
  dedupe_dependencies
fi

if [ "$DO_CLEAN" = true ]; then
  clean_dependencies
fi

echo "✨ Dependency management completed"
