#!/usr/bin/env bash
#
# init_project.sh
#
# Creates a scaffold for a "production-style" TypeScript + Express + TypeORM + Winston
# + Key Vault + Docker + GitHub Actions, referencing the final solution layout.
# Only creates files if they do not exist. Safe to re-run multiple times.

echo "=== Creating directories... ==="

# Main directories
mkdir -p src
mkdir -p src/config
mkdir -p src/controllers
mkdir -p src/middleware
mkdir -p src/routes
mkdir -p src/services
mkdir -p src/services/additional_features
mkdir -p src/telemetry
mkdir -p .github/workflows

# 1) .env.example
if [ ! -f .env.example ]; then
cat <<'EOF' > .env.example
# Copy to .env and fill in real values
NODE_ENV=development
PORT=3000

# Database
DB_HOST=myazuresqlserver.database.windows.net
DB_PORT=1433
DB_NAME=solacenetdb
DB_USER=azuresqladmin
DB_PASS=SuperSecurePassword123!

# Azure Key Vault (OPTIONAL)
KEY_VAULT_NAME=solacenetkv
KEY_VAULT_SECRET_NAME=DbPassword

# Logging
LOG_LEVEL=info

# JWT
JWT_SECRET=supersecretjwtkey

# (Add more env variables as needed)
EOF
  echo "Created .env.example"
fi

# 2) .gitignore
if [ ! -f .gitignore ]; then
cat <<'EOF' > .gitignore
node_modules
dist
.env
Dockerfile
*.log
EOF
  echo "Created .gitignore"
fi

# 3) Dockerfile
if [ ! -f Dockerfile ]; then
cat <<'EOF' > Dockerfile
# Use a Node base image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package.json & package-lock.json first to leverage Docker cache
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the project
RUN npm run build

# Expose port
EXPOSE 3000

# Start the app (you may adjust the command if your app runs differently)
CMD ["npm", "run", "dev"]
EOF
  echo "Created Dockerfile"
fi

# 4) docker-compose.yml (optional)
if [ ! -f docker-compose.yml ]; then
cat <<'EOF' > docker-compose.yml
version: '3.9'
services:
  solacenet-dashboard:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DB_HOST=mssql
      - DB_USER=sa
      - DB_PASS=YourStrong!Passw0rd
      - DB_NAME=solacedb
    depends_on:
      - mssql

  mssql:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong!Passw0rd
    ports:
      - "1433:1433"
EOF
  echo "Created docker-compose.yml"
fi

# 5) package.json
if [ ! -f package.json ]; then
cat <<'EOF' > package.json
{
  "name": "solacenet-dashboard",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "test": "vitest run",
    "start": "ts-node src/index.ts"
  },
  "dependencies": {
    "@azure/identity": "^3.1.0",
    "@azure/keyvault-secrets": "^4.6.0",
    "applicationinsights": "^2.8.4",
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.0",
    "mssql": "^9.0.1",
    "typeorm": "^0.3.12",
    "winston": "^3.8.2"
  },
  "devDependencies": {
    "typescript": "^4.8.4",
    "vite": "^4.0.0",
    "vitest": "^0.27.0",
    "ts-node": "^10.9.1"
  }
}
EOF
  echo "Created package.json"
fi

# 6) tsconfig.json
if [ ! -f tsconfig.json ]; then
cat <<'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "Node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
EOF
  echo "Created tsconfig.json"
fi

# 7) vite.config.ts
if [ ! -f vite.config.ts ]; then
cat <<'EOF' > vite.config.ts
import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    port: 3000,
  },
  build: {
    target: 'esnext'
  }
});
EOF
  echo "Created vite.config.ts"
fi

# 8) vitest.config.ts
if [ ! -f vitest.config.ts ]; then
cat <<'EOF' > vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node'
  }
});
EOF
  echo "Created vitest.config.ts"
fi

# 9) README.md
if [ ! -f README.md ]; then
cat <<'EOF' > README.md
# SolaceNet Dashboard

This is a TypeScript + Express + TypeORM + Winston + Azure Key Vault + Docker + GitHub Actions scaffold.

## Getting Started

1. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

2. Run development server (Vite):
   \`\`\`bash
   npm run dev
   \`\`\`

3. Build:
   \`\`\`bash
   npm run build
   \`\`\`

4. Test:
   \`\`\`bash
   npm run test
   \`\`\`

5. Start (Express server):
   \`\`\`bash
   npm run start
   \`\`\`

See \`docker-compose.yml\` for an optional local SQL Server instance.

## Production Deployments

- Dockerize with \`Dockerfile\`
- Azure WebApp or Container Instances
- GitHub Actions config in \`.github/workflows\`

## Key Technologies

- **TypeScript** + **Node**
- **Express** for APIs
- **TypeORM** for Azure SQL integration
- **Winston** for logging
- **Application Insights** for telemetry
- **Key Vault** for secrets (optional)
EOF
  echo "Created README.md"
fi

# 10) TODO.md
if [ ! -f TODO.md ]; then
cat <<'EOF' > TODO.md
# TODO List

- [ ] Replace stub functions with actual logic
- [ ] Integrate real external systems (databases, blockchains, payment APIs, etc.)
- [ ] Add error handling, validations, transaction logic
- [ ] Expand testing with Vitest
- [ ] Configure production Docker/CI/CD
EOF
  echo "Created TODO.md"
fi

# 11) ormconfig.js
if [ ! -f ormconfig.js ]; then
cat <<'EOF' > ormconfig.js
module.exports = {
  type: "mssql",
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || "1433", 10),
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  synchronize: false,  // set to true in dev only
  logging: false,
  options: {
    encrypt: true,
    trustServerCertificate: false
  },
  entities: [
    "src/entities/*.ts"
  ],
  migrations: [
    "src/migrations/*.ts"
  ],
  cli: {
    entitiesDir: "src/entities",
    migrationsDir: "src/migrations"
  }
};
EOF
  echo "Created ormconfig.js"
fi

# 12) src/index.ts
if [ ! -f src/index.ts ]; then
cat <<'EOF' > src/index.ts
import { bootstrap } from './server';

// This file is your standard entrypoint for local dev or Node starts.
bootstrap().catch((err) => {
  console.error("Fatal error in index.ts:", err);
  process.exit(1);
});
EOF
  echo "Created src/index.ts"
fi

# 13) src/server.ts
if [ ! -f src/server.ts ]; then
cat <<'EOF' > src/server.ts
import express from 'express';
import { loadSecrets, PORT } from './config/env';
import { AppDataSource } from './config/db';
import { requestLogger } from './middleware/logger';
import router from './routes';
import { initAppInsights } from './telemetry/appInsights';

export async function bootstrap() {
  // 1) Load secrets (Key Vault + .env)
  await loadSecrets();

  // 2) Initialize DB
  await AppDataSource.initialize();
  console.log("Database connected to:", process.env.DB_NAME);

  // 3) Initialize App Insights
  initAppInsights(process.env.APPINSIGHTS_INSTRUMENTATIONKEY);

  // 4) Express app
  const app = express();
  app.use(express.json());
  app.use(requestLogger);
  app.use('/', router);

  const port = PORT || '3000';
  app.listen(port, () => {
    console.log(\`Server running on port \${port}...\`);
  });
}
EOF
  echo "Created src/server.ts"
fi

# 14) src/routes/index.ts
if [ ! -f src/routes/index.ts ]; then
cat <<'EOF' > src/routes/index.ts
import { Router } from 'express';
import investmentBankingController from '../controllers/investmentBankingController';
// import other controllers as needed

const router = Router();

// Example route for investment banking
router.use('/investment-banking', investmentBankingController);

export default router;
EOF
  echo "Created src/routes/index.ts"
fi

# 15) src/middleware/auth.ts
if [ ! -f src/middleware/auth.ts ]; then
cat <<'EOF' > src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { JWT_SECRET } from '../config/env';

export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'No auth token provided.' });
  }

  const token = authHeader.split(' ')[1];
  try {
    jwt.verify(token, JWT_SECRET || 'fallbacksecret');
    // attach user info if desired
    // (req as any).user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token.' });
  }
}
EOF
  echo "Created src/middleware/auth.ts"
fi

# 16) src/middleware/logger.ts
if [ ! -f src/middleware/logger.ts ]; then
cat <<'EOF' > src/middleware/logger.ts
import winston from 'winston';
import { Request, Response, NextFunction } from 'express';
import { LOG_LEVEL } from '../config/env';

export const logger = winston.createLogger({
  level: LOG_LEVEL || 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console()
  ]
});

export function requestLogger(req: Request, res: Response, next: NextFunction) {
  logger.info(\`\${req.method} \${req.url}\`);
  next();
}
EOF
  echo "Created src/middleware/logger.ts"
fi

# 17) src/config/env.ts
if [ ! -f src/config/env.ts ]; then
cat <<'EOF' > src/config/env.ts
import * as dotenv from 'dotenv';
dotenv.config();

import { DefaultAzureCredential } from '@azure/identity';
import { SecretClient } from '@azure/keyvault-secrets';

export const {
  NODE_ENV,
  PORT,
  DB_HOST,
  DB_PORT,
  DB_NAME,
  DB_USER,
  DB_PASS,
  KEY_VAULT_NAME,
  KEY_VAULT_SECRET_NAME,
  LOG_LEVEL,
  JWT_SECRET
} = process.env;

/**
 * Attempt to fetch secrets from Azure Key Vault,
 * if KEY_VAULT_NAME + KEY_VAULT_SECRET_NAME are set.
 */
async function fetchKeyVaultSecret(vaultName: string, secretName: string): Promise<string | undefined> {
  try {
    const credential = new DefaultAzureCredential();
    const url = \`https://\${vaultName}.vault.azure.net\`;
    const client = new SecretClient(url, credential);
    const secret = await client.getSecret(secretName);
    return secret.value;
  } catch (err) {
    console.error(\`Key Vault Error: \${err}\`);
    return undefined;
  }
}

/**
 * loadSecrets: tries to override DB_PASS with Key Vault secret if configured.
 * You can expand this logic for more secrets as needed.
 */
export async function loadSecrets() {
  if (KEY_VAULT_NAME && KEY_VAULT_SECRET_NAME) {
    console.log(\`Attempting to fetch secret '\${KEY_VAULT_SECRET_NAME}' from Key Vault '\${KEY_VAULT_NAME}'...\`);
    const fromKV = await fetchKeyVaultSecret(KEY_VAULT_NAME, KEY_VAULT_SECRET_NAME);
    if (fromKV) {
      process.env.DB_PASS = fromKV;
      console.log("Overrode DB_PASS with Key Vault secret!");
    }
  }
}
EOF
  echo "Created src/config/env.ts"
fi

# 18) src/config/db.ts
if [ ! -f src/config/db.ts ]; then
cat <<'EOF' > src/config/db.ts
import { DataSource } from 'typeorm';
import config from '../../ormconfig.js';

export const AppDataSource = new DataSource({
  ...config
});
EOF
  echo "Created src/config/db.ts"
fi

# 19) src/telemetry/appInsights.ts
if [ ! -f src/telemetry/appInsights.ts ]; then
cat <<'EOF' > src/telemetry/appInsights.ts
import appInsights from 'applicationinsights';

export function initAppInsights(instrumentationKey: string | undefined) {
  if (!instrumentationKey) {
    console.warn("No App Insights instrumentation key set; skipping init...");
    return;
  }
  appInsights.setup(instrumentationKey).start();
  console.log("Azure Application Insights started.");
}
EOF
  echo "Created src/telemetry/appInsights.ts"
fi

# 20) src/controllers/investmentBankingController.ts
if [ ! -f src/controllers/investmentBankingController.ts ]; then
cat <<'EOF' > src/controllers/investmentBankingController.ts
import { Router, Request, Response } from 'express';
import { provideGlobalInvestmentBankingServices, issueAndTradeSecurities, offerFinancialGuarantees } from '../services/investment_banking';

const router = Router();

// GET /investment-banking/global-services
router.get('/global-services', (req: Request, res: Response) => {
  const result = provideGlobalInvestmentBankingServices();
  return res.json({ success: true, data: result });
});

// POST /investment-banking/securities
router.post('/securities', (req: Request, res: Response) => {
  const result = issueAndTradeSecurities();
  return res.json({ success: true, data: result });
});

// POST /investment-banking/guarantees
router.post('/guarantees', (req: Request, res: Response) => {
  const result = offerFinancialGuarantees();
  return res.json({ success: true, data: result });
});

export default router;
EOF
  echo "Created src/controllers/investmentBankingController.ts"
fi

#
# Service stubs:
#

# 21) src/services/investment_banking.ts
if [ ! -f src/services/investment_banking.ts ]; then
cat <<'EOF' > src/services/investment_banking.ts
export function provideGlobalInvestmentBankingServices() {
  console.log('Providing global investment banking services...');
  // Actual logic here, e.g. DB calls
  return { message: "Global investment banking complete." };
}

export function issueAndTradeSecurities() {
  console.log('Issuing and trading securities...');
  return { message: "Securities issued/traded." };
}

export function offerFinancialGuarantees() {
  console.log('Offering financial guarantees...');
  return { message: "Financial guarantee offered." };
}
EOF
  echo "Created src/services/investment_banking.ts"
fi

# 22) src/services/trust_services.ts
if [ ! -f src/services/trust_services.ts ]; then
cat <<'EOF' > src/services/trust_services.ts
export function holdAndManageAssetsInTrust(): void {
  console.log('Managing trust assets...');
  // TODO: Implement logic
}

export function openInvestmentAndTrustAccounts(): void {
  console.log('Opening investment and trust accounts...');
  // TODO: Implement logic
}

export function handleDepositsAndLoans(): void {
  console.log('Handling deposits and loans...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/trust_services.ts"
fi

# 23) src/services/digital_asset_management.ts
if [ ! -f src/services/digital_asset_management.ts ]; then
cat <<'EOF' > src/services/digital_asset_management.ts
export function issueAndTrackSharesBlockchain(): void {
  console.log('Issuing and tracking shares on blockchain...');
  // TODO: Implement logic
}

export function tradeTokensNFTsCrypto(): void {
  console.log('Trading tokens, NFTs, and cryptocurrencies...');
  // TODO: Implement logic
}

export function exchangeVirtualCurrencies(): void {
  console.log('Exchanging virtual currencies...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/digital_asset_management.ts"
fi

# 24) src/services/custodian_fiduciary.ts
if [ ! -f src/services/custodian_fiduciary.ts ]; then
cat <<'EOF' > src/services/custodian_fiduciary.ts
export function custodyOfAssets(): void {
  console.log('Holding custody of assets...');
  // TODO: Implement logic
}

export function issueSKR(): void {
  console.log('Issuing Safe Keeping Receipts (SKRs)...');
  // TODO: Implement logic
}

export function provideSwiftMessaging(): void {
  console.log('Providing SWIFT messaging...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/custodian_fiduciary.ts"
fi

# 25) src/services/fintech_operations.ts
if [ ! -f src/services/fintech_operations.ts ]; then
cat <<'EOF' > src/services/fintech_operations.ts
export function operatePaymentSystems(): void {
  console.log('Operating payment systems...');
  // TODO: Implement logic
}

export function currencyExchangeAndWallet(): void {
  console.log('Providing currency exchange and wallet services...');
  // TODO: Implement logic
}

export function onlineLendingAndSecuritization(): void {
  console.log('Offering online lending, loans, securitization...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/fintech_operations.ts"
fi

# 26) src/services/asset_management.ts
if [ ! -f src/services/asset_management.ts ]; then
cat <<'EOF' > src/services/asset_management.ts
export function manageAssetTypes(): void {
  console.log('Managing various asset types...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/asset_management.ts"
fi

# 27) src/services/brokerage_services.ts
if [ ! -f src/services/brokerage_services.ts ]; then
cat <<'EOF' > src/services/brokerage_services.ts
export function forexAndSecuritiesBrokerage(): void {
  console.log('Handling forex and securities brokerage...');
  // TODO: Implement logic
}

export function cryptoBrokerageAndCustody(): void {
  console.log('Providing crypto brokerage and custody services...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/brokerage_services.ts"
fi

# 28) src/services/banking_services.ts
if [ ! -f src/services/banking_services.ts ]; then
cat <<'EOF' > src/services/banking_services.ts
export function openAndMaintainBankAccounts(): void {
  console.log('Opening and maintaining various bank accounts...');
  // TODO: Implement logic
}

export function issueCreditCardsAndContracts(): void {
  console.log('Issuing credit cards and credit contracts...');
  // TODO: Implement logic
}

export function provideComplianceBankServices(): void {
  console.log('Providing bank-like services with regulatory compliance...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/banking_services.ts"
fi

# 29) src/services/versatile_financial.ts
if [ ! -f src/services/versatile_financial.ts ]; then
cat <<'EOF' > src/services/versatile_financial.ts
export function serveInvestmentFirms(): void {
  console.log('Serving investment firms...');
  // TODO: Implement logic
}

export function serveCryptoExchanges(): void {
  console.log('Serving crypto exchanges...');
  // TODO: Implement logic
}

export function serveOnlineLendingPlatforms(): void {
  console.log('Serving online lending platforms...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/versatile_financial.ts"
fi

# Additional Features
# 30) src/services/additional_features/loan_borrowing.ts
mkdir -p src/services/additional_features
if [ ! -f src/services/additional_features/loan_borrowing.ts ]; then
cat <<'EOF' > src/services/additional_features/loan_borrowing.ts
export function issuePromissoryNotes(): void {
  console.log('Issuing promissory notes...');
  // TODO: Implement logic
}

export function engageInMTNTransactions(): void {
  console.log('Engaging in MTN transactions...');
  // TODO: Implement logic
}

export function tradeFinanceAndInvoiceFactoring(): void {
  console.log('Providing trade finance and invoice factoring...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/additional_features/loan_borrowing.ts"
fi

# 31) src/services/additional_features/regulatory_compliance.ts
if [ ! -f src/services/additional_features/regulatory_compliance.ts ]; then
cat <<'EOF' > src/services/additional_features/regulatory_compliance.ts
export function ensureBankingLicenseCompliance(): void {
  console.log('Ensuring compliance with banking licenses...');
  // TODO: Implement logic
}

export function verifyPartnerIds(): void {
  console.log('Verifying partner IDs...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/additional_features/regulatory_compliance.ts"
fi

# 32) src/services/additional_features/decentralized_trust.ts
if [ ! -f src/services/additional_features/decentralized_trust.ts ]; then
cat <<'EOF' > src/services/additional_features/decentralized_trust.ts
export function operateDecentralizedFinancialInstitution(): void {
  console.log('Operating as a decentralized financial institution...');
  // TODO: Implement logic
}

export function manageGlobalClientAssets(): void {
  console.log('Managing global client assets...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/additional_features/decentralized_trust.ts"
fi

# 33) src/services/additional_features/capital_raising.ts
if [ ! -f src/services/additional_features/capital_raising.ts ]; then
cat <<'EOF' > src/services/additional_features/capital_raising.ts
export function raiseCapital(): void {
  console.log('Raising capital via securities sale...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/additional_features/capital_raising.ts"
fi

# 34) src/services/additional_features/safe_asset_management.ts
if [ ! -f src/services/additional_features/safe_asset_management.ts ]; then
cat <<'EOF' > src/services/additional_features/safe_asset_management.ts
export function secureAssetCustody(): void {
  console.log('Ensuring safe asset custody...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/additional_features/safe_asset_management.ts"
fi

# 35) src/services/additional_features/global_operations.ts
if [ ! -f src/services/additional_features/global_operations.ts ]; then
cat <<'EOF' > src/services/additional_features/global_operations.ts
export function operateWithoutCurrencyRestrictions(): void {
  console.log('Operating globally without currency restrictions...');
  // TODO: Implement logic
}

export function serveGlobalClientele(): void {
  console.log('Serving clients of all nationalities and residencies...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/additional_features/global_operations.ts"
fi

# 36) src/services/additional_features/swift_messaging.ts
if [ ! -f src/services/additional_features/swift_messaging.ts ]; then
cat <<'EOF' > src/services/additional_features/swift_messaging.ts
export function sendFinancialGuaranteeSwift(): void {
  console.log('Sending financial guarantee via SWIFT...');
  // TODO: Implement logic
}
EOF
  echo "Created src/services/additional_features/swift_messaging.ts"
fi

# 37) GitHub Actions: .github/workflows/ci-cd.yml
if [ ! -f .github/workflows/ci-cd.yml ]; then
cat <<'EOF' > .github/workflows/ci-cd.yml
name: CI-CD

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Use Node
        uses: actions/setup-node@v2
        with:
          node-version: 18

      - name: Install dependencies
        run: npm install

      - name: Build
        run: npm run build

      - name: Test
        run: npm run test

      - name: Docker Build
        run: docker build -t solacenet-dashboard .

      # - name: Docker Login
      #   run: docker login -u \${{ secrets.DOCKER_USER }} -p \${{ secrets.DOCKER_PASS }}

      # - name: Docker Push
      #   run: docker push <your-registry>/solacenet-dashboard:latest

  # Example deploy job (uncomment and configure if you have Azure details):
  # deploy:
  #   needs: build-and-test
  #   runs-on: ubuntu-latest
  #   steps:
  #     - name: Checkout
  #       uses: actions/checkout@v2
  #     - name: Use Node
  #       uses: actions/setup-node@v2
  #       with:
  #         node-version: 18
  #     - name: Install dependencies
  #       run: npm install
  #     - name: Azure WebApp Deploy
  #       uses: azure/webapps-deploy@v2
  #       with:
  #         app-name: "solacenet"
  #         slot-name: "production"
  #         publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
  #         package: .
EOF
  echo "Created .github/workflows/ci-cd.yml"
fi

echo "=== Scaffold creation complete! ==="
echo "Run 'npm install' then 'npm run dev' or 'npm run test' or 'npm run start'."
echo "You can also build a Docker image: 'docker build -t solacenet-dashboard .'"