#!/bin/bash
# setup_tatum_submodule.sh
# ------------------------------------------
# This script automates the setup and update of the tatum-ts submodule.
# It will:
#   - Determine the project root based on the script's location.
#   - Create a submodules/ directory if it doesn't exist.
#   - Add the tatum-ts submodule from the URL to submodules/tatum-ts.
#   - Update the submodule if it already exists.
#
# Usage:
#   From the command line in the scripts directory:
#       ./setup_tatum_submodule.sh
#
# Ensure that this script is executable:
#   chmod +x setup_tatum_submodule.sh
# ------------------------------------------

# Exit immediately if a command exits with a non-zero status.
set -e

# Get the absolute path of the directory this script resides in.
SCRIPT_DIR=$(dirname "$(realpath "$0")")
# Assume the project root is one level up from the scripts directory.
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
echo "Project root detected: $PROJECT_ROOT"

# Define submodule directory and repository URL.
SUBMODULE_DIR="$PROJECT_ROOT/submodules/tatum-ts"
REPO_URL="https://github.com/Defi-Oracle-Tooling/tatum-ts.git"

# Create the submodules directory if it doesn't exist.
if [ ! -d "$PROJECT_ROOT/submodules" ]; then
  echo "Creating submodules directory at $PROJECT_ROOT/submodules..."
  mkdir -p "$PROJECT_ROOT/submodules"
fi

# Check if the tatum-ts submodule already exists.
if [ -d "$SUBMODULE_DIR" ]; then
    echo "Submodule already exists at $SUBMODULE_DIR. Updating the submodule..."
    cd "$SUBMODULE_DIR"
    # Pull the latest changes from the main branch.
    git pull origin main || {
      echo "Warning: Failed to update the submodule. Please check your repository status."
    }
    cd "$PROJECT_ROOT"
else
    echo "Adding tatum-ts as a submodule..."
    cd "$PROJECT_ROOT"
    git submodule add "$REPO_URL" "submodules/tatum-ts"
    git submodule update --init --recursive
fi

echo "Submodule setup complete. tatum-ts is available at $SUBMODULE_DIR."