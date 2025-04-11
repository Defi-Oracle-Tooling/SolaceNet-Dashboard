#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 <npm-command> [npm-arguments]"
  echo "Runs npm commands without showing the CommonJS/ES Module warnings"
  echo ""
  echo "Example: $0 install express"
  exit 1
}

# Show usage if no arguments or help requested
if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  show_usage
fi

# Run npm with NODE_OPTIONS environment variable set to ignore warnings
NODE_OPTIONS="--no-warnings" npm "$@"
