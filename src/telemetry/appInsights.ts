import appInsights from 'applicationinsights';

export function initAppInsights(instrumentationKey: string | undefined) {
  if (!instrumentationKey) {
    console.warn("No App Insights instrumentation key set; skipping init...");
    return;
  }
  appInsights.setup(instrumentationKey).start();
  console.log("Azure Application Insights started.");
}
