import express from 'express';
import { loadSecrets } from './config/env';
import { AppDataSource } from './config/db';
import { logger } from './middleware/logger';
import router from './routes';
import { initAppInsights } from './telemetry/appInsights';
import helmet from 'helmet';

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

  // Secure the app with Helmet middleware
  app.use(helmet());

  app.use(express.json());
  app.use(logger);
  app.use('/', router);

  // Error-handling middleware
  app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
  });

  const port = process.env.PORT || '3000';
  app.listen(port, () => {
    console.log(`Server running on port ${port}...`);
  });
}
