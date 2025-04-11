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

echo "🔧 Setting up environment for: $ENVIRONMENT"

# Check for required tools
for cmd in pnpm node az jq; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ $cmd is not installed. Please install it first."
    exit 1
  fi
done

# Create environment file if it doesn't exist
ENV_FILE=".env.$ENVIRONMENT"
if [ ! -f "$ENV_FILE" ]; then
  echo "Creating $ENV_FILE file..."
  cp .env.example "$ENV_FILE" 2>/dev/null || echo "# Environment variables for $ENVIRONMENT" > "$ENV_FILE"
fi

# Install dependencies
echo "Installing dependencies..."
pnpm install

# Azure environment setup
if command -v az &> /dev/null; then
  echo "Setting up Azure resources..."
  
  # Check if logged into Azure
  az account show &> /dev/null || az login
  
  # Get Key Vault secrets
  if [ -n "${AZURE_KEY_VAULT:-}" ]; then
    echo "Fetching secrets from Azure Key Vault: $AZURE_KEY_VAULT"
    
    # List all secrets and save to env file
    secrets=$(az keyvault secret list --vault-name "$AZURE_KEY_VAULT" --query "[].name" -o tsv)
    
    for secret in $secrets; do
      value=$(az keyvault secret show --vault-name "$AZURE_KEY_VAULT" --name "$secret" --query "value" -o tsv)
      echo "Adding $secret to $ENV_FILE"
      # Update or add the secret in the env file
      if grep -q "^$secret=" "$ENV_FILE"; then
        sed -i '' "s/^$secret=.*/$secret=$value/" "$ENV_FILE"
      else
        echo "$secret=$value" >> "$ENV_FILE"
      fi
    done
  fi
fi

echo "✅ Environment setup completed for $ENVIRONMENT!"
