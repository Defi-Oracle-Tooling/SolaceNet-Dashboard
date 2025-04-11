import appInsights from 'applicationinsights';

export function initAppInsights(instrumentationKey: string | undefined) {
  if (!instrumentationKey) {
    console.warn("No App Insights instrumentation key set; skipping init...");
    return;
  }

  appInsights.setup(instrumentationKey)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectConsole(true, true)
    .setSendLiveMetrics(true)
    .start();

  const client = appInsights.defaultClient;

  // Add a telemetry processor to enrich telemetry data
  client.addTelemetryProcessor((envelope) => {
    envelope.tags['ai.cloud.role'] = 'solacenet-dashboard'; // Set cloud role name
    envelope.tags['ai.cloud.roleInstance'] = 'instance-1'; // Set instance name
    return true;
  });

  console.log("Azure Application Insights started with enhanced telemetry.");
}
