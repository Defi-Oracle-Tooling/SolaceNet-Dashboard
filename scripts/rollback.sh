#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--env <environment>] [--version <version>] [--list]"
  echo "  --env       : Target environment (dev, test, prod). Default: dev"
  echo "  --version   : Specific version to roll back to (e.g., v1.2.3)"
  echo "  --list      : List available versions to roll back to"
  exit 1
}

# Default values
ENVIRONMENT="dev"
VERSION=""
LIST_VERSIONS=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --env) 
      ENVIRONMENT="$2"
      shift 
      ;;
    --version) 
      VERSION="$2"
      shift 
      ;;
    --list)
      LIST_VERSIONS=true
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

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
  echo "❌ Azure CLI is not installed. Please install it first."
  exit 1
fi

# Check if logged into Azure
az account show &> /dev/null || { 
  echo "Not logged into Azure. Please login."
  az login || { echo "Azure login failed. Rollback aborted."; exit 1; }
}

# Resource names
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-solacenet-$ENVIRONMENT-rg}"
WEB_APP="${AZURE_WEBAPP_NAME:-solacenet-$ENVIRONMENT-app}"

echo "🔄 Rolling back deployment for $ENVIRONMENT environment"

# List available deployment slots
function list_versions {
  echo "Listing available deployment slots for rollback..."
  az webapp deployment slot list --resource-group "$RESOURCE_GROUP" --name "$WEB_APP" --output table

  echo "Listing available deployment history..."
  az webapp deployment list --resource-group "$RESOURCE_GROUP" --name "$WEB_APP" --output table
}

# Roll back to specific version or slot
function rollback {
  if [ -z "$VERSION" ]; then
    echo "❌ No version specified for rollback. Use --version or --list to see available versions."
    exit 1
  fi
  
  echo "Rolling back to version: $VERSION"
  
  # Check if this is a slot name
  SLOT_EXISTS=$(az webapp deployment slot list \
    --resource-group "$RESOURCE_GROUP" \
    --name "$WEB_APP" \
    --query "[?name=='$VERSION']" \
    --output tsv)
  
  if [ -n "$SLOT_EXISTS" ]; then
    echo "Performing slot swap from $VERSION to production..."
    az webapp deployment slot swap \
      --resource-group "$RESOURCE_GROUP" \
      --name "$WEB_APP" \
      --slot "$VERSION" \
      --target-slot production
  else
    # Try to find a deployment ID that matches the version
    echo "Looking for deployment with ID or version matching: $VERSION"
    DEPLOYMENT_ID=$(az webapp deployment list \
      --resource-group "$RESOURCE_GROUP" \
      --name "$WEB_APP" \
      --query "[?id=='$VERSION' || contains(id, '$VERSION')].id" \
      --output tsv | head -n 1)
    
    if [ -n "$DEPLOYMENT_ID" ]; then
      echo "Rolling back to deployment ID: $DEPLOYMENT_ID"
      az webapp deployment source update \
        --resource-group "$RESOURCE_GROUP" \
        --name "$WEB_APP" \
        --target-deployment "$DEPLOYMENT_ID"
    else
      echo "❌ Could not find a deployment or slot matching: $VERSION"
      list_versions
      exit 1
    fi
  fi
}

# Execute based on options
if [ "$LIST_VERSIONS" = true ]; then
  list_versions
else
  rollback
fi

echo "✅ Rollback completed successfully!"
