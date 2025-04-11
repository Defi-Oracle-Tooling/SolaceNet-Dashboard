#!/bin/bash
# Script for setting up Azure resources

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
RESOURCE_GROUP="solacenet-rg"
LOCATION="eastus"
STORAGE_ACCOUNT="solacenetstorage"

# Function to create a resource group
create_resource_group() {
  echo "Creating resource group: $RESOURCE_GROUP"
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
}

# Function to create a storage account
create_storage_account() {
  echo "Creating storage account: $STORAGE_ACCOUNT"
  az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku Standard_LRS
}

# Main script execution
create_resource_group
create_storage_account
