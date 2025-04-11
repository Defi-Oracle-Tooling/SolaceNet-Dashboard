import { Request, Response, NextFunction } from 'express';
import winston from 'winston';

// Create a logger instance
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

// Middleware to log requests
export const requestLogger = (req: Request, res: Response, next: NextFunction): void => {
  logger.info(`${req.method} ${req.url}`);
  next();
};

// Middleware to log errors
export const errorLogger = (err: Error, req: Request, res: Response, next: NextFunction): void => {
  logger.error(`${err.message} - ${req.method} ${req.url}`);
  next(err);
};

export { logger };
