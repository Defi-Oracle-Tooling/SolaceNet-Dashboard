# Project Sitemap

## Root Directory
- **`azure-static-web-apps.yml`**: Azure Static Web Apps CI/CD configuration.
- **`azure.yaml`**: Azure project configuration for deployment.
- **`copilot-instructions.md`**: Coding guidelines (e.g., use Vitest for testing).
- **`docker-compose.yml`**: Docker Compose configuration for local development.
- **`Dockerfile`**: Dockerfile for containerizing the application.
- **`favicon.ico`**: Favicon for the web application.
- **`index.html`**: Entry point for the web application.
- **`ormconfig.js`**: TypeORM configuration for database connection.
- **`package.json`**: Project dependencies and scripts.
- **`README.md`**: Project documentation and setup instructions.
- **`staticwebapp.config.json`**: Configuration for Azure Static Web Apps.
- **`TODO.md`**: List of remaining tasks for the project.
- **`tsconfig.json`**: TypeScript configuration.
- **`validateHeaders.js`**: Middleware for securing HTTP headers.
- **`vite.config.ts`**: Vite configuration for development and build.
- **`vitest.config.ts`**: Vitest configuration for testing.

---

## Documentation
- **`docs/stock_market_investment_guide.md`**: User guide for the stock market investment feature.

---

## Infrastructure
- **`infra/solacenet.bicep`**: Bicep template for Azure resource provisioning.

---

## Scripts
- **`scripts/init_project.sh`**: Script to initialize the project scaffold.
- **`scripts/setup_tatum_submodule.sh`**: Script to set up the `tatum-ts` submodule.
- **`scripts/deploy.sh`**: Script for deployment automation.
- **`scripts/cleanup.sh`**: Script for cleaning up resources after deployment.
- **`scripts/monitoring.sh`**: Script for setting up monitoring and telemetry.
- **`scripts/seed_database.sh`**: Script for seeding the database with initial data.
- **`scripts/test.sh`**: Script for running tests.
- **`scripts/lint.sh`**: Script for linting the codebase.
- **`scripts/build.sh`**: Script for building the application.
- **`scripts/format.sh`**: Script for formatting the codebase.
- **`scripts/upgrade_dependencies.sh`**: Script for upgrading project dependencies.
- **`scripts/rollback.sh`**: Script for rolling back to a previous deployment.
- **`scripts/backup.sh`**: Script for backing up the database.
- **`scripts/restore.sh`**: Script for restoring the database from a backup.
- **`scripts/monitoring_setup.sh`**: Script for setting up monitoring and telemetry.
- **`scripts/security_setup.sh`**: Script for setting up security measures.
- **`scripts/azure_setup.sh`**: Script for setting up Azure resources.
- **`scripts/azure_deploy.sh`**: Script for deploying to Azure.

---

## Source Code
### Root Files
- **`src/App.tsx`**: Main React component for the application.
- **`src/index.ts`**: Entry point for the Node.js server.
- **`src/main.tsx`**: Entry point for the React application.
- **`src/server.ts`**: Express server setup.
- **`src/setupTests.ts`**: Test setup file for Vitest.

### Components
- **`src/components/banking/AccountManagement.tsx`**: Component for managing bank accounts.
- **`src/components/banking/AccountManagement.css`**: Styles for `AccountManagement`.
- **`src/components/banking/AssetCustodyManagement.tsx`**: Component for managing asset custody.
- **`src/components/banking/AssetManagement.tsx`**: Component for managing trust properties.
- **`src/components/banking/CustodianFiduciaryServices.tsx`**: Component for custodian and fiduciary services.
- **`src/components/banking/DigitalAssetManagement.tsx`**: Component for managing digital assets.
- **`src/components/banking/StockMarketInvestment.tsx`**: Component for stock market investments.
- **`src/components/banking/StockMarketInvestment.css`**: Styles for `StockMarketInvestment`.
- **`src/components/banking/TrustServices.tsx`**: Component for trust services.

### Configuration
- **`src/config/db.ts`**: Database configuration using TypeORM.
- **`src/config/env.ts`**: Environment variable management and Azure Key Vault integration.

### Controllers
- **`src/controllers/investmentBankingController.ts`**: Controller for investment banking operations.

### Middleware
- **`src/middleware/auth.ts`**: JWT authentication middleware.
- **`src/middleware/logger.ts`**: Request and error logging middleware.

### Routes
- **`src/routes/index.ts`**: Main router for the application.

### Services
- **`src/services/asset_management.ts`**: Service for managing various asset types.
- **`src/services/banking_services.ts`**: Service for banking operations.
- **`src/services/brokerage_services.ts`**: Service for brokerage operations.
- **`src/services/custodian_fiduciary.ts`**: Service for custodian and fiduciary operations.
- **`src/services/digital_asset_management.ts`**: Service for digital asset management.
- **`src/services/fintech_operations.ts`**: Service for fintech operations.
- **`src/services/investment_banking.ts`**: Service for investment banking operations.
- **`src/services/trust_services.ts`**: Service for trust-related operations.
- **`src/services/versatile_financial.ts`**: Service for versatile financial operations.

#### Additional Features
- **`src/services/additional_features/capital_raising.ts`**: Service for capital raising.
- **`src/services/additional_features/decentralized_trust.ts`**: Service for decentralized trust operations.
- **`src/services/additional_features/global_operations.ts`**: Service for global operations.
- **`src/services/additional_features/loan_borrowing.ts`**: Service for loan and borrowing operations.
- **`src/services/additional_features/regulatory_compliance.ts`**: Service for regulatory compliance.
- **`src/services/additional_features/safe_asset_management.ts`**: Service for safe asset management.
- **`src/services/additional_features/swift_messaging.ts`**: Service for SWIFT messaging.

### Telemetry
- **`src/telemetry/appInsights.ts`**: Azure Application Insights integration.

### Utilities
- **`src/utils/database.ts`**: Database utility functions.
- **`src/utils/exportToPDF.ts`**: Utility for exporting data to PDF.
- **`src/utils/fetchLiveData.ts`**: Utility for fetching live data.
- **`src/utils/monitoring.ts`**: Placeholder for monitoring and telemetry.
- **`src/utils/securityHeaders.ts`**: Utility for applying security headers.

### Tests
- **`src/tests/accessibility.test.tsx`**: Accessibility tests using `vitest-axe`.
- **`src/tests/database.test.ts`**: Tests for database utilities.
- **`src/tests/investInStockMarket.test.ts`**: Tests for the `investInStockMarket` function.
- **`src/tests/manageTrustProperty.test.ts`**: Tests for trust property management.
- **`src/tests/safe_asset_management.test.ts`**: Tests for safe asset management.
- **`src/tests/trust_services.test.ts`**: Tests for trust services.

---

## Submodules
- **`submodules/tatum-ts/TODO.md`**: TODO list for the `tatum-ts` submodule.
