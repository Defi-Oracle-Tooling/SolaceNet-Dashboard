#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--env <environment>] [--apply] [--check]"
  echo "  --env     : Target environment (dev, test, prod). Default: dev"
  echo "  --apply   : Apply security configurations"
  echo "  --check   : Check security configurations"
  exit 1
}

# Default values
ENVIRONMENT="dev"
DO_APPLY=false
DO_CHECK=false

# Parse arguments
if [ "$#" -eq 0 ]; then
  # Default behavior if no arguments provided
  DO_CHECK=true
fi

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --env) 
      ENVIRONMENT="$2"
      shift 
      ;;
    --apply) DO_APPLY=true ;;
    --check) DO_CHECK=true ;;
    -h|--help) show_usage ;;
    *) echo "Unknown parameter: $1"; show_usage ;;
  esac
  shift
done

echo "🔒 Setting up security measures for $ENVIRONMENT environment"

# Load environment variables
if [ -f ".env.$ENVIRONMENT" ]; then
  echo "Loading environment variables from .env.$ENVIRONMENT"
  export $(grep -v '^#' .env.$ENVIRONMENT | xargs)
else
  echo "Warning: .env.$ENVIRONMENT file not found"
fi

# Create security config directory if needed
CONFIG_DIR="./config/security"
mkdir -p "$CONFIG_DIR"

# Define security configuration file
SECURITY_CONFIG="$CONFIG_DIR/security-$ENVIRONMENT.json"

# Function to configure security settings
function configure_security {
  echo "Setting up security configuration..."
  
  # Create or update security configuration
  cat <<EOF > "$SECURITY_CONFIG"
{
  "environment": "$ENVIRONMENT",
  "enableFirewall": true,
  "enforceSSL": true,
  "securityHeaders": {
    "Content-Security-Policy": "default-src 'self'; script-src 'self'",
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "X-XSS-Protection": "1; mode=block",
    "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
    "Referrer-Policy": "strict-origin-when-cross-origin"
  },
  "rateLimit": {
    "windowMs": 15 * 60 * 1000,
    "max": 100
  },
  "corsOptions": {
    "origin": [
      "https://solacenet-$ENVIRONMENT.azurewebsites.net",
      "https://solacenet-$ENVIRONMENT-app.azurestaticapps.net"
    ],
    "methods": ["GET", "POST", "PUT", "DELETE"],
    "allowedHeaders": ["Content-Type", "Authorization"],
    "credentials": true
  },
  "updatedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
  echo "Security configuration saved to $SECURITY_CONFIG"

  # Update staticwebapp.config.json if exists
  if [ -f "staticwebapp.config.json" ]; then
    echo "Updating staticwebapp.config.json with security headers..."
    # This requires a JSON processor like jq
    if command -v jq &> /dev/null; then
      # Create a temporary file with updated security headers
      jq '.globalHeaders = {
        "Content-Security-Policy": "default-src '\''self'\''",
        "X-Content-Type-Options": "nosniff",
        "X-Frame-Options": "DENY",
        "X-XSS-Protection": "1; mode=block",
        "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
        "Referrer-Policy": "strict-origin-when-cross-origin"
      }' staticwebapp.config.json > staticwebapp.config.json.tmp
      mv staticwebapp.config.json.tmp staticwebapp.config.json
    else
      echo "Warning: jq is not installed. Could not update staticwebapp.config.json"
    fi
  fi
  
  # Check for Azure Key Vault configuration
  if [ -n "${KEY_VAULT_NAME:-}" ]; then
    echo "Setting up Key Vault access policies..."
    
    # Check for Azure CLI
    if ! command -v az &> /dev/null; then
      echo "❌ Azure CLI is not installed. Please install it first."
      return 1
    fi
    
    # Check if logged into Azure
    az account show &> /dev/null || { 
      echo "Not logged into Azure. Please login."
      az login || { echo "Azure login failed."; return 1; }
    }
    
    # Get current user object ID
    CURRENT_USER_ID=$(az ad signed-in-user show --query id -o tsv)
    
    # Update Key Vault access policy
    echo "Setting up Key Vault access policy for current user..."
    az keyvault set-policy \
      --name "$KEY_VAULT_NAME" \
      --object-id "$CURRENT_USER_ID" \
      --secret-permissions get list set delete
  fi
  
  echo "✅ Security configuration applied successfully"
}

# Function to validate security setup
function validate_security {
  echo "Validating security setup..."
  
  if [ -f "$SECURITY_CONFIG" ]; then
    echo "Security configuration file exists at: $SECURITY_CONFIG"
    
    # Show last updated date if jq is available
    if command -v jq &> /dev/null; then
      UPDATED_AT=$(jq -r '.updatedAt' "$SECURITY_CONFIG")
      echo "Last updated: $UPDATED_AT"
      
      # Check if firewall is enabled
      FIREWALL_ENABLED=$(jq -r '.enableFirewall' "$SECURITY_CONFIG")
      if [ "$FIREWALL_ENABLED" = "true" ]; then
        echo "✅ Firewall is enabled"
      else
        echo "⚠️ Firewall is disabled"
      fi
      
      # Check if SSL is enforced
      SSL_ENFORCED=$(jq -r '.enforceSSL' "$SECURITY_CONFIG")
      if [ "$SSL_ENFORCED" = "true" ]; then
        echo "✅ SSL is enforced"
      else
        echo "⚠️ SSL is not enforced"
      fi
      
      # Check if security headers are configured
      if jq -e '.securityHeaders' "$SECURITY_CONFIG" > /dev/null; then
        echo "✅ Security headers are configured"
      else
        echo "⚠️ Security headers are not configured"
      fi
      
      # Check if CORS is properly configured
      if jq -e '.corsOptions' "$SECURITY_CONFIG" > /dev/null; then
        echo "✅ CORS options are configured"
      else
        echo "⚠️ CORS options are not configured"
      fi
    else
      echo "Warning: jq is not installed. Cannot perform detailed validation."
    fi
    
    # Check for Key Vault access
    if [ -n "${KEY_VAULT_NAME:-}" ]; then
      if command -v az &> /dev/null; then
        if az keyvault show --name "$KEY_VAULT_NAME" &> /dev/null; then
          echo "✅ Key Vault '$KEY_VAULT_NAME' exists and is accessible"
        else
          echo "⚠️ Key Vault '$KEY_VAULT_NAME' does not exist or is not accessible"
        fi
      else
        echo "⚠️ Cannot check Key Vault access (Azure CLI not installed)"
      fi
    else
      echo "⚠️ Key Vault name not specified in environment variables"
    fi
  else
    echo "❌ Security configuration file does not exist at: $SECURITY_CONFIG"
    echo "Run with --apply to generate the configuration"
    return 1
  fi
}

# Execute based on options
if [ "$DO_APPLY" = true ]; then
  configure_security
fi

if [ "$DO_CHECK" = true ]; then
  validate_security
fi

echo "Security setup process completed!"
