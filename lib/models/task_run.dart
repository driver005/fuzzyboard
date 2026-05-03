import 'package:flutter/material.dart';

enum TaskRunStatus { running, done, failed }

extension TaskRunStatusExt on TaskRunStatus {
  String get label => switch (this) {
        TaskRunStatus.running => 'Running',
        TaskRunStatus.done => 'Done',
        TaskRunStatus.failed => 'Failed',
      };

  Color get color => switch (this) {
        TaskRunStatus.running => const Color(0xFF3B82F6),
        TaskRunStatus.done => const Color(0xFF10B981),
        TaskRunStatus.failed => const Color(0xFFEF4444),
      };
}

class TaskRun {
  final String id;
  final String taskId;
  final String taskName;
  TaskRunStatus status;
  final DateTime startedAt;
  DateTime? finishedAt;
  final List<String> logs;

  TaskRun({
    required this.id,
    required this.taskId,
    required this.taskName,
    this.status = TaskRunStatus.running,
    DateTime? startedAt,
    this.finishedAt,
    List<String>? logs,
  })  : startedAt = startedAt ?? DateTime.now(),
        logs = logs ?? [];

  Duration? get duration =>
      finishedAt != null ? finishedAt!.difference(startedAt) : null;
}
