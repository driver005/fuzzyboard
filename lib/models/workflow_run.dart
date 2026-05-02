enum WorkflowRunStatus { running, success, failed, cancelled }

class WorkflowRun {
  final String id;
  final String workflowId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  WorkflowRunStatus status;
  final List<String> logs;

  WorkflowRun({
    required this.id,
    required this.workflowId,
    required this.startedAt,
    this.finishedAt,
    this.status = WorkflowRunStatus.running,
    List<String>? logs,
  }) : logs = logs ?? [];

  Duration? get duration =>
      finishedAt != null ? finishedAt!.difference(startedAt) : null;
}
