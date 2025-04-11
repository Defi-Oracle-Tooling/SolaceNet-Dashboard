#!/usr/bin/env bash
set -euo pipefill

# Display script usage
function show_usage {
  echo "Usage: $0 [--env <environment>] [--resource-group <resource-group>]"
  echo "  --env             : Target environment (dev, test, prod). Default: dev"
  echo "  --resource-group  : Azure resource group. Default: solacenet-<env>"
  exit 1
}

# Parse arguments
ENVIRONMENT="dev"
RESOURCE_GROUP=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --env) ENVIRONMENT="$2"; shift ;;
    --resource-group) RESOURCE_GROUP="$2"; shift ;;
    -h|--help) show_usage ;;
    *) echo "Unknown parameter: $1"; show_usage ;;
  esac
  shift
done

# Set resource group name if not provided
if [ -z "$RESOURCE_GROUP" ]; then
  RESOURCE_GROUP="solacenet-$ENVIRONMENT"
fi

echo "🔍 Setting up monitoring for $ENVIRONMENT environment in resource group $RESOURCE_GROUP"

# Check for Azure CLI
if ! command -v az &> /dev/null; then
  echo "❌ Azure CLI is not installed. Please install it first."
  exit 1
fi

# Check if logged into Azure
az account show &> /dev/null || { echo "Please log in to Azure first using 'az login'"; exit 1; }

# Create Application Insights resource
APP_NAME="solacenet-dashboard-$ENVIRONMENT"
LOCATION="eastus"  # Change as needed

echo "Creating Application Insights resource..."
AI_RESOURCE=$(az monitor app-insights component create \
  --app "$APP_NAME" \
  --location "$LOCATION" \
  --resource-group "$RESOURCE_GROUP" \
  --application-type web \
  --kind web \
  -o json)

# Get the connection string and instrumentation key
CONNECTION_STRING=$(echo $AI_RESOURCE | jq -r '.connectionString')
INSTRUMENTATION_KEY=$(echo $AI_RESOURCE | jq -r '.instrumentationKey')

echo "Application Insights resource created successfully!"
echo "Connection String: $CONNECTION_STRING"
echo "Instrumentation Key: $INSTRUMENTATION_KEY"

# Update environment file with connection string
ENV_FILE=".env.$ENVIRONMENT"
if [ -f "$ENV_FILE" ]; then
  echo "Updating $ENV_FILE with Application Insights connection string..."
  if grep -q "^APPLICATIONINSIGHTS_CONNECTION_STRING=" "$ENV_FILE"; then
    sed -i '' "s|^APPLICATIONINSIGHTS_CONNECTION_STRING=.*|APPLICATIONINSIGHTS_CONNECTION_STRING=$CONNECTION_STRING|" "$ENV_FILE"
  else
    echo "APPLICATIONINSIGHTS_CONNECTION_STRING=$CONNECTION_STRING" >> "$ENV_FILE"
  fi
else
  echo "Warning: $ENV_FILE not found. Cannot update environment variables."
fi

echo "✅ Monitoring setup completed!"
