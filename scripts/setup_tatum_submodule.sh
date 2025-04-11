#!/usr/bin/env bash
set -euo pipefail

# Display script usage
function show_usage {
  echo "Usage: $0 [--branch <branch-name>] [--update] [--env <environment>] [--init] [--check] [--test]"
  echo "  --branch  : Branch to checkout in the submodule (default: main)"
  echo "  --update  : Update the submodule if it already exists"
  echo "  --env     : Target environment (dev, test, prod). Default: dev"
  echo "  --init    : Initialize npm packages after setup"
  echo "  --check   : Verify configuration and required environment variables"
  echo "  --test    : Run tests in the submodule using vitest"
  exit 1
}

# Default values
BRANCH="main"
UPDATE=false
ENVIRONMENT="dev"
DO_INIT=false
DO_CHECK=false
DO_TEST=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --branch) 
      BRANCH="$2"
      shift 
      ;;
    --update) 
      UPDATE=true
      ;;
    --env)
      ENVIRONMENT="$2"
      shift
      ;;
    --init)
      DO_INIT=true
      ;;
    --check)
      DO_CHECK=true
      ;;
    --test)
      DO_TEST=true
      ;;
    -h|--help) show_usage ;;
    *) echo "Unknown parameter: $1"; show_usage ;;
  esac
  shift
done

echo "🔄 Setting up tatum-ts submodule for $ENVIRONMENT environment"

# Check for git installation
if ! command -v git &> /dev/null; then
  echo "❌ Git is not installed. Please install it first."
  exit 1
fi

# Get the absolute path of the directory this script resides in.
SCRIPT_DIR=$(dirname "$(realpath "$0")")
# Assume the project root is one level up from the scripts directory.
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
echo "📂 Project root detected: $PROJECT_ROOT"

# Load environment variables if available
if [ -f "$PROJECT_ROOT/.env.$ENVIRONMENT" ]; then
  echo "⚙️ Loading environment variables from .env.$ENVIRONMENT"
  export $(grep -v '^#' "$PROJECT_ROOT/.env.$ENVIRONMENT" | xargs)
else
  echo "⚠️ Warning: .env.$ENVIRONMENT file not found"
fi

# Define submodule directory and repository URL.
SUBMODULE_DIR="$PROJECT_ROOT/submodules/tatum-ts"
REPO_URL="https://github.com/Defi-Oracle-Tooling/tatum-ts.git"

# Create the submodules directory if it doesn't exist.
if [ ! -d "$PROJECT_ROOT/submodules" ]; then
  echo "📁 Creating submodules directory at $PROJECT_ROOT/submodules..."
  mkdir -p "$PROJECT_ROOT/submodules"
fi

# Check if the tatum-ts submodule already exists.
if [ -d "$SUBMODULE_DIR" ]; then
  echo "ℹ️ Submodule already exists at $SUBMODULE_DIR."
  if [ "$UPDATE" = true ]; then
    echo "🔄 Updating the submodule..."
    cd "$SUBMODULE_DIR"
    # Pull the latest changes from the specified branch
    git checkout "$BRANCH" || { echo "❌ Failed to checkout branch $BRANCH"; exit 1; }
    git pull origin "$BRANCH" || {
      echo "⚠️ Warning: Failed to update the submodule. Please check your repository status."
    }
    cd "$PROJECT_ROOT"
  fi
else
  echo "➕ Adding tatum-ts as a submodule..."
  cd "$PROJECT_ROOT"
  git submodule add "$REPO_URL" "submodules/tatum-ts" || { 
    echo "❌ Failed to add submodule. Check repository URL and permissions."; 
    exit 1; 
  }
  
  git submodule update --init --recursive || {
    echo "❌ Failed to initialize submodules"; 
    exit 1;
  }
  
  # Checkout the specified branch
  cd "$SUBMODULE_DIR"
  git checkout "$BRANCH" || { 
    echo "❌ Failed to checkout branch $BRANCH"; 
    exit 1; 
  }
  
  cd "$PROJECT_ROOT"
fi

# Function to verify configuration
function verify_configuration {
  echo "🔍 Verifying configuration for the tatum-ts submodule..."
  
  # Check for required environment variables
  local REQUIRED_VARS=("TATUM_API_KEY" "BLOCKCHAIN_RPC_URL")
  local MISSING_VARS=()
  
  for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR:-}" ]; then
      MISSING_VARS+=("$VAR")
    fi
  done
  
  if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo "⚠️ Missing required environment variables in .env.$ENVIRONMENT:"
    for VAR in "${MISSING_VARS[@]}"; do
      echo "   - $VAR"
    done
    echo "Please add these to your .env.$ENVIRONMENT file"
  else
    echo "✅ All required environment variables are present"
  fi
  
  # Check for config file in the submodule
  if [ -f "$SUBMODULE_DIR/src/config/config.ts" ]; then
    echo "✅ Configuration file found"
  else
    echo "⚠️ Configuration file not found at $SUBMODULE_DIR/src/config/config.ts"
    echo "   You may need to create this file based on config.example.ts"
  fi
}

# Function to initialize npm packages
function initialize_packages {
  echo "📦 Initializing npm packages in the submodule..."
  
  # Check for Node.js and npm
  if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install Node.js and npm first."
    return 1
  fi
  
  # Install dependencies in the submodule
  cd "$SUBMODULE_DIR"
  
  # Check if package.json exists
  if [ ! -f "package.json" ]; then
    echo "❌ package.json not found in the submodule"
    return 1
  fi
  
  # Install dependencies using npm or pnpm if available
  if command -v pnpm &> /dev/null; then
    echo "Using pnpm to install dependencies..."
    pnpm install || { 
      echo "❌ Failed to install dependencies with pnpm"; 
      return 1; 
    }
  else
    echo "Using npm to install dependencies..."
    npm install || { 
      echo "❌ Failed to install dependencies with npm"; 
      return 1; 
    }
  fi
  
  # Return to project root
  cd "$PROJECT_ROOT"
  echo "✅ Dependencies installed successfully"
}

# Function to run tests
function run_tests {
  echo "🧪 Running tests in the submodule..."
  
  cd "$SUBMODULE_DIR"
  
  # Check if vitest is available
  if grep -q "\"vitest\"" "package.json" || grep -q "\"test\"" "package.json"; then
    echo "Running vitest tests..."
    
    # Try to use pnpm first, then npm
    if command -v pnpm &> /dev/null; then
      pnpm test || { 
        echo "❌ Tests failed"; 
        return 1; 
      }
    else
      npm test || { 
        echo "❌ Tests failed"; 
        return 1; 
      }
    fi
    
    echo "✅ Tests completed successfully"
  else
    echo "⚠️ No test script found in package.json"
  fi
  
  cd "$PROJECT_ROOT"
}

# If this is for dev environment, also create symlinks for convenience
if [ "$ENVIRONMENT" = "dev" ]; then
  echo "🔗 Setting up symbolic links for development..."
  
  # Create type definitions link if appropriate
  if [ -d "$SUBMODULE_DIR/src/types" ] && [ ! -L "$PROJECT_ROOT/src/types/tatum" ]; then
    mkdir -p "$PROJECT_ROOT/src/types"
    ln -sf "$SUBMODULE_DIR/src/types" "$PROJECT_ROOT/src/types/tatum"
    echo "✅ Created symbolic link for type definitions"
  fi
fi

# Run requested operations
if [ "$DO_CHECK" = true ]; then
  verify_configuration
fi

if [ "$DO_INIT" = true ]; then
  initialize_packages
fi

if [ "$DO_TEST" = true ]; then
  run_tests
fi

echo "✅ Submodule setup complete. tatum-ts is available at $SUBMODULE_DIR."
echo "   Branch: $BRANCH"
echo "   Environment: $ENVIRONMENT"

# Provide next steps
echo ""
echo "Next steps:"
if [ "$DO_INIT" != true ]; then
  echo "1. Initialize the submodule: ./scripts/setup_tatum_submodule.sh --init"
fi
if [ "$DO_CHECK" != true ]; then
  echo "2. Verify configuration: ./scripts/setup_tatum_submodule.sh --check"
fi
echo "3. Update your application to import from the submodule"
echo "   Example: import { TatumClient } from '../submodules/tatum-ts/src'"
echo ""
echo "📝 For more details on Tatum integration, refer to the TODO list:"
echo "   $SUBMODULE_DIR/TODO.md"