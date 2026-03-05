const bool scheduleDebugLogsEnabled = bool.fromEnvironment(
  'SCHEDULE_DEBUG_LOGS',
  defaultValue: false,
);

const bool syncMetricsMessageEnabled = bool.fromEnvironment(
  'SYNC_METRICS_MESSAGE',
  defaultValue: false,
);
