#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--env <environment>] [--skip-tests] [--no-zip]"
  echo "  --env         : Target environment (dev, test, prod). Default: dev"
  echo "  --skip-tests  : Skip running tests before deployment"
  echo "  --no-zip      : Skip creating a zip file (for static web app deployment)"
  exit 1
}

# Parse arguments
ENVIRONMENT="dev"
RUN_TESTS=true
CREATE_ZIP=true

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --env) ENVIRONMENT="$2"; shift ;;
    --skip-tests) RUN_TESTS=false ;;
    --no-zip) CREATE_ZIP=false ;;
    -h|--help) show_usage ;;
    *) echo "Unknown parameter: $1"; show_usage ;;
  esac
  shift
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
  echo "Error: Environment must be dev, test, or prod"
  exit 1
fi

echo "🚀 Deploying to $ENVIRONMENT environment"

# Load environment variables
if [ -f ".env.$ENVIRONMENT" ]; then
  echo "Loading environment variables from .env.$ENVIRONMENT"
  export $(grep -v '^#' .env.$ENVIRONMENT | xargs)
else
  echo "Warning: .env.$ENVIRONMENT file not found"
fi

# Run tests if not skipped
if [ "$RUN_TESTS" = true ]; then
  echo "Running tests before deployment..."
  pnpm test || { echo "Tests failed. Deployment aborted."; exit 1; }
fi

# Build the application
echo "Building application..."
pnpm run build || { echo "Build failed. Deployment aborted."; exit 1; }

# Check if Azure CLI is installed and user is logged in
if ! command -v az &> /dev/null; then
  echo "Error: Azure CLI is not installed. Please install it first."
  exit 1
fi

# Check if logged into Azure
az account show &> /dev/null || { 
  echo "Not logged into Azure. Please login."
  az login || { echo "Azure login failed. Deployment aborted."; exit 1; }
}

# Create zip file if required
if [ "$CREATE_ZIP" = true ]; then
  echo "Creating deployment package..."
  cd dist && zip -r ../dist.zip . && cd .. || { echo "Failed to create zip file"; exit 1; }
fi

# Deploy to Azure
echo "Deploying to Azure..."

# Determine deployment type (Web App or Static Web App)
if [ -n "${AZURE_WEBAPP_NAME:-}" ]; then
  # Web App deployment
  echo "Deploying to Azure Web App: $AZURE_WEBAPP_NAME"
  
  RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-solacenet-$ENVIRONMENT}"
  echo "Using resource group: $RESOURCE_GROUP"
  
  # Check if resource group exists
  if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo "Resource group $RESOURCE_GROUP does not exist. Creating..."
    az group create --name "$RESOURCE_GROUP" --location "${AZURE_LOCATION:-eastus}"
  fi
  
  if [ "$CREATE_ZIP" = true ]; then
    # Deploy using zip deployment
    az webapp deployment source config-zip \
      --resource-group "$RESOURCE_GROUP" \
      --name "$AZURE_WEBAPP_NAME" \
      --src dist.zip || { echo "Deployment failed"; exit 1; }
  else
    # Deploy using git or other method
    echo "Skipping zip deployment. Please deploy using another method."
  fi
elif [ -n "${AZURE_STATIC_WEBAPP_NAME:-}" ]; then
  # Static Web App deployment
  echo "Deploying to Azure Static Web App: $AZURE_STATIC_WEBAPP_NAME"
  
  # For Static Web Apps, GitHub Actions is recommended, but we can use CLI for manual deployments
  echo "Manual Static Web App deployments are typically done through GitHub Actions."
  echo "Please see your GitHub workflows in .github/workflows directory."
  
  # Display available static web apps
  az staticwebapp list --output table
else
  echo "Error: Neither AZURE_WEBAPP_NAME nor AZURE_STATIC_WEBAPP_NAME environment variables are set."
  echo "Please define at least one of these variables for deployment."
  exit 1
fi

# Check and run post-deployment tasks if script exists
if [ -f "./scripts/post-deploy.sh" ]; then
  echo "Running post-deployment tasks..."
  bash ./scripts/post-deploy.sh --env "$ENVIRONMENT" || { echo "Post-deployment tasks failed"; exit 1; }
fi

echo "✅ Deployment completed successfully!"
