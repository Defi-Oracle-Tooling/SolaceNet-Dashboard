#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--lint] [--format] [--fix]"
  echo "  --lint    : Run linting checks"
  echo "  --format  : Run code formatting"
  echo "  --fix     : Apply automatic fixes when linting"
  echo "If no options are provided, both lint and format will run"
  exit 1
}

# Parse arguments
RUN_LINT=false
RUN_FORMAT=false
FIX_ISSUES=false

# If no arguments, run both
if [ "$#" -eq 0 ]; then
  RUN_LINT=true
  RUN_FORMAT=true
fi

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --lint) RUN_LINT=true ;;
    --format) RUN_FORMAT=true ;;
    --fix) FIX_ISSUES=true ;;
    -h|--help) show_usage ;;
    *) echo "Unknown parameter: $1"; show_usage ;;
  esac
  shift
done

# Run linting if requested
if [ "$RUN_LINT" = true ]; then
  echo "🔍 Running linter checks..."
  
  LINT_CMD="pnpm run lint"
  if [ "$FIX_ISSUES" = true ]; then
    LINT_CMD="$LINT_CMD --fix"
  fi
  
  eval "$LINT_CMD" || {
    echo "❌ Linting failed"
    exit 1
  }
  
  echo "✅ Linting completed successfully"
fi

# Run formatting if requested
if [ "$RUN_FORMAT" = true ]; then
  echo "💅 Running code formatter..."
  
  FORMAT_CMD="pnpm run format"
  if [ "$FIX_ISSUES" = true ]; then
    FORMAT_CMD="$FORMAT_CMD --write"
  else
    FORMAT_CMD="$FORMAT_CMD --check"
  fi
  
  eval "$FORMAT_CMD" || {
    echo "❌ Formatting check failed"
    exit 1
  }
  
  echo "✅ Formatting completed successfully"
fi

echo "✨ Code quality checks completed"
