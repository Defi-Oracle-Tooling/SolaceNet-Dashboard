import helmet from 'helmet';
import { Express } from 'express';

export function applySecurityHeaders(app: Express): void {
  // Use Helmet to secure HTTP headers
  app.use(helmet());

  // Example: Add custom headers
  app.use((req, res, next) => {
    res.setHeader('X-Custom-Header', 'SecureApp');
    next();
  });

  console.log('Security headers applied.');
}