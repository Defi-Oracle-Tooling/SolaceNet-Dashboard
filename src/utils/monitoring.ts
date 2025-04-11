// Check if we're in a browser environment
const isBrowser = typeof window !== 'undefined';

// Import winston only in non-browser environments
let winston;
let appInsights: any;

if (!isBrowser) {
  // Only import Winston in Node.js environment
  winston = require('winston');
  appInsights = require('applicationinsights');
}

// Create a browser-compatible logger for client-side
const browserLogger = {
  info: (message: string, data?: any) => {
    console.info(`[INFO] ${message}`, data || '');
  },
  error: (message: string, error?: Error) => {
    console.error(`[ERROR] ${message}`, error || '');
  },
  warn: (message: string, data?: any) => {
    console.warn(`[WARN] ${message}`, data || '');
  },
  debug: (message: string, data?: any) => {
    console.debug(`[DEBUG] ${message}`, data || '');
  }
};

// Create a server-side logger with Winston
const serverLogger = !isBrowser && winston ? winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
}) : null;

// Initialize Application Insights if configuration exists (server-side only)
if (!isBrowser && appInsights && process.env.APPLICATIONINSIGHTS_CONNECTION_STRING) {
  appInsights.setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .start();
}

// Use the appropriate logger based on environment
const logger = isBrowser ? browserLogger : serverLogger || browserLogger;

// Export the logging functions
export function logError(message: string, error?: Error): void {
  logger.error(message, error);
  
  // Also log to Application Insights if available (server-side)
  if (!isBrowser && appInsights && appInsights.defaultClient) {
    appInsights.defaultClient.trackException({ exception: error || new Error(message) });
  }
}

export function logInfo(message: string, data?: any): void {
  logger.info(message, data);
  
  if (!isBrowser && appInsights && appInsights.defaultClient) {
    appInsights.defaultClient.trackTrace({ message, severity: appInsights.Contracts.SeverityLevel.Information });
  }
}

// Add other logging methods as needed...