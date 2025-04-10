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
