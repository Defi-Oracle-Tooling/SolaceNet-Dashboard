#!/bin/bash
# Script for deploying to Azure

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
RESOURCE_GROUP="solacenet-rg"
APP_NAME="solacenet-app"
LOCATION="eastus"

# Function to deploy the application
deploy_application() {
  echo "Deploying application: $APP_NAME"
  az webapp up --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION"
  echo "Deployment completed."
}

# Main script execution
deploy_application
