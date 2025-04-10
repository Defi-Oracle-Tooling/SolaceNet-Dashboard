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
