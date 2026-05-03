enum WorkerStatus { running, stopped, error }

enum WorkerType { httpWorker, cronWorker, dbWorker, scriptWorker, notificationWorker }

extension WorkerTypeExt on WorkerType {
  String get label => switch (this) {
        WorkerType.httpWorker => 'HTTP Worker',
        WorkerType.cronWorker => 'Cron Worker',
        WorkerType.dbWorker => 'DB Worker',
        WorkerType.scriptWorker => 'Script Worker',
        WorkerType.notificationWorker => 'Notification Worker',
      };
}

extension WorkerStatusExt on WorkerStatus {
  String get label => switch (this) {
        WorkerStatus.running => 'Running',
        WorkerStatus.stopped => 'Stopped',
        WorkerStatus.error => 'Error',
      };
}

class Worker {
  final String id;
  String name;
  String description;
  WorkerType type;
  WorkerStatus status;
  int concurrency;
  int maxRetries;
  int timeoutSeconds;
  String? endpoint;
  Map<String, String> envVars;
  DateTime? lastRunAt;
  int runCount;

  Worker({
    required this.id,
    required this.name,
    this.description = '',
    this.type = WorkerType.httpWorker,
    this.status = WorkerStatus.stopped,
    this.concurrency = 1,
    this.maxRetries = 3,
    this.timeoutSeconds = 30,
    this.endpoint,
    Map<String, String>? envVars,
    this.lastRunAt,
    this.runCount = 0,
  }) : envVars = envVars ?? {};
}
