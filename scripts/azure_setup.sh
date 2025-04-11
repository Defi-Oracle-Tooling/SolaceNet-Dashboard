#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--env <environment>] [--location <location>]"
  echo "  --env       : Target environment (dev, test, prod). Default: dev"
  echo "  --location  : Azure region for resources. Default: eastus"
  exit 1
}

# Default values
ENVIRONMENT="dev"
LOCATION="eastus"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --env) 
      ENVIRONMENT="$2"
      shift 
      ;;
    --location)
      LOCATION="$2"
      shift
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

# Resource names
RESOURCE_GROUP="solacenet-$ENVIRONMENT-rg"
STORAGE_ACCOUNT="solacenet${ENVIRONMENT}st"
APP_SERVICE_PLAN="solacenet-$ENVIRONMENT-plan"
WEB_APP="solacenet-$ENVIRONMENT-app"
KEY_VAULT="solacenet-$ENVIRONMENT-kv"
APP_INSIGHTS="solacenet-$ENVIRONMENT-ai"
DB_SERVER="solacenet-$ENVIRONMENT-db"
DB_NAME="solacenet_db"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
  echo "❌ Azure CLI is not installed. Please install it first."
  exit 1
fi

# Check if logged into Azure
az account show &> /dev/null || { 
  echo "Not logged into Azure. Please login."
  az login || { echo "Azure login failed. Setup aborted."; exit 1; }
}

# Function to create a resource group
function create_resource_group {
  echo "Creating resource group: $RESOURCE_GROUP"
  az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags Environment="$ENVIRONMENT" Application="SolaceNet"
}

# Function to create a storage account
function create_storage_account {
  echo "Creating storage account: $STORAGE_ACCOUNT"
  az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --https-only true \
    --min-tls-version TLS1_2
}

# Function to create a Key Vault
function create_key_vault {
  echo "Creating Key Vault: $KEY_VAULT"
  az keyvault create \
    --name "$KEY_VAULT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --enable-rbac-authorization true
  
  # Get current user object ID to assign permissions
  CURRENT_USER_ID=$(az ad signed-in-user show --query id -o tsv)
  
  echo "Granting Key Vault permissions to current user"
  az role assignment create \
    --role "Key Vault Administrator" \
    --assignee "$CURRENT_USER_ID" \
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT"
}

# Function to create App Service resources
function create_app_service {
  echo "Creating App Service Plan: $APP_SERVICE_PLAN"
  az appservice plan create \
    --name "$APP_SERVICE_PLAN" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku B1
  
  echo "Creating Web App: $WEB_APP"
  az webapp create \
    --name "$WEB_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$APP_SERVICE_PLAN" \
    --runtime "NODE:18-lts"
}

# Function to create Application Insights
function create_app_insights {
  echo "Creating Application Insights: $APP_INSIGHTS"
  az monitor app-insights component create \
    --app "$APP_INSIGHTS" \
    --location "$LOCATION" \
    --resource-group "$RESOURCE_GROUP" \
    --application-type web
  
  # Get the connection string
  AI_CONNECTION_STRING=$(az monitor app-insights component show \
    --app "$APP_INSIGHTS" \
    --resource-group "$RESOURCE_GROUP" \
    --query connectionString -o tsv)
  
  # Store the connection string in Key Vault
  az keyvault secret set \
    --vault-name "$KEY_VAULT" \
    --name "ApplicationInsightsConnectionString" \
    --value "$AI_CONNECTION_STRING"
  
  echo "Application Insights connection string stored in Key Vault"
}

# Function to create PostgreSQL database
function create_database {
  echo "Creating PostgreSQL server: $DB_SERVER"
  
  # Generate a strong password
  DB_PASSWORD=$(openssl rand -base64 16)
  
  # Create PostgreSQL server
  az postgres server create \
    --name "$DB_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --admin-user "solacenet_admin" \
    --admin-password "$DB_PASSWORD" \
    --sku-name GP_Gen5_2
  
  # Create database
  echo "Creating database: $DB_NAME"
  az postgres db create \
    --name "$DB_NAME" \
    --server-name "$DB_SERVER" \
    --resource-group "$RESOURCE_GROUP"
  
  # Allow Azure services to access the PostgreSQL server
  echo "Configuring firewall rules"
  az postgres server firewall-rule create \
    --name "AllowAzureServices" \
    --server "$DB_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --start-ip-address "0.0.0.0" \
    --end-ip-address "0.0.0.0"
  
  # Store database credentials in Key Vault
  az keyvault secret set \
    --vault-name "$KEY_VAULT" \
    --name "DatabaseUser" \
    --value "solacenet_admin"
  
  az keyvault secret set \
    --vault-name "$KEY_VAULT" \
    --name "DatabasePassword" \
    --value "$DB_PASSWORD"
  
  az keyvault secret set \
    --vault-name "$KEY_VAULT" \
    --name "DatabaseHost" \
    --value "$DB_SERVER.postgres.database.azure.com"
  
  az keyvault secret set \
    --vault-name "$KEY_VAULT" \
    --name "DatabaseName" \
    --value "$DB_NAME"
  
  echo "Database credentials stored in Key Vault"
}

# Function to configure the web app to use Key Vault
function configure_web_app {
  echo "Configuring Web App to use Key Vault"
  
  # Enable managed identity for the web app
  az webapp identity assign \
    --name "$WEB_APP" \
    --resource-group "$RESOURCE_GROUP"
  
  # Get the managed identity principal ID
  WEB_APP_PRINCIPAL_ID=$(az webapp identity show \
    --name "$WEB_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --query principalId -o tsv)
  
  # Grant Key Vault Secrets User role to the web app
  az role assignment create \
    --role "Key Vault Secrets User" \
    --assignee "$WEB_APP_PRINCIPAL_ID" \
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT"
  
  # Set Key Vault reference in app settings
  echo "Setting Key Vault reference in app settings"
  az webapp config appsettings set \
    --name "$WEB_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
      "KEY_VAULT_NAME=$KEY_VAULT" \
      "APPLICATIONINSIGHTS_CONNECTION_STRING=@Microsoft.KeyVault(SecretUri=https://$KEY_VAULT.vault.azure.net/secrets/ApplicationInsightsConnectionString/)" \
      "PGHOST=@Microsoft.KeyVault(SecretUri=https://$KEY_VAULT.vault.azure.net/secrets/DatabaseHost/)" \
      "PGUSER=@Microsoft.KeyVault(SecretUri=https://$KEY_VAULT.vault.azure.net/secrets/DatabaseUser/)" \
      "PGPASSWORD=@Microsoft.KeyVault(SecretUri=https://$KEY_VAULT.vault.azure.net/secrets/DatabasePassword/)" \
      "PGDATABASE=@Microsoft.KeyVault(SecretUri=https://$KEY_VAULT.vault.azure.net/secrets/DatabaseName/)"
}

# Main setup process
echo "🔧 Setting up Azure resources for $ENVIRONMENT environment"
create_resource_group
create_storage_account
create_key_vault
create_app_service
create_app_insights
create_database
configure_web_app

echo "✅ Azure resources have been provisioned successfully!"
echo "Resource Group: $RESOURCE_GROUP"
echo "Web App URL: https://$WEB_APP.azurewebsites.net"
echo "Key Vault: $KEY_VAULT"
echo "Database Server: $DB_SERVER.postgres.database.azure.com"
echo "Don't forget to set up your local .env.$ENVIRONMENT file with these connection details."
