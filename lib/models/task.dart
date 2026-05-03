import 'package:flutter/material.dart';

enum TaskStatus { todo, inProgress, done, blocked }

enum TaskPriority { low, medium, high, critical }

enum TaskRetryPolicy { fixed, exponentialBackoff, linearBackoff }

extension TaskPriorityExt on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
        TaskPriority.critical => 'Critical',
      };

  Color get color => switch (this) {
        TaskPriority.low => const Color(0xFF10B981),
        TaskPriority.medium => const Color(0xFFF59E0B),
        TaskPriority.high => const Color(0xFFEF4444),
        TaskPriority.critical => const Color(0xFF7C3AED),
      };
}

extension TaskRetryPolicyExt on TaskRetryPolicy {
  String get label => switch (this) {
        TaskRetryPolicy.fixed => 'FIXED',
        TaskRetryPolicy.exponentialBackoff => 'EXPONENTIAL_BACKOFF',
        TaskRetryPolicy.linearBackoff => 'LINEAR_BACKOFF',
      };
}

class Task {
  final String id;
  String name;
  String description;
  TaskPriority priority;
  TaskStatus status;
  List<String> tags;
  DateTime createdAt;
  DateTime? dueDate;
  Map<String, dynamic> config;

  // Conductor-inspired fields
  int timeoutSeconds;
  int retryCount;
  TaskRetryPolicy retryPolicy;
  int retryDelaySeconds;
  int responseTimeoutSeconds;
  String ownerEmail;
  String? pluginId;
  /// Input parameter definitions: key → type/description
  Map<String, String> inputKeys;
  /// Output parameter definitions: key → type/description
  Map<String, String> outputKeys;
  /// Concurrency limit (0 = unlimited)
  int concurrentExecLimit;

  Task({
    required this.id,
    required this.name,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.tags = const [],
    DateTime? createdAt,
    this.dueDate,
    Map<String, dynamic>? config,
    this.timeoutSeconds = 3600,
    this.retryCount = 3,
    this.retryPolicy = TaskRetryPolicy.fixed,
    this.retryDelaySeconds = 60,
    this.responseTimeoutSeconds = 600,
    this.ownerEmail = '',
    this.pluginId,
    Map<String, String>? inputKeys,
    Map<String, String>? outputKeys,
    this.concurrentExecLimit = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        config = config ?? {},
        inputKeys = inputKeys ?? {},
        outputKeys = outputKeys ?? {};

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'ownerEmail': ownerEmail,
        'retryCount': retryCount,
        'retryLogic': retryPolicy.label,
        'retryDelaySeconds': retryDelaySeconds,
        'timeoutSeconds': timeoutSeconds,
        'responseTimeoutSeconds': responseTimeoutSeconds,
        'concurrentExecLimit': concurrentExecLimit,
        'inputKeys': inputKeys,
        'outputKeys': outputKeys,
      };

  Task copyWith({
    String? name,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? tags,
    DateTime? dueDate,
    Map<String, dynamic>? config,
    int? timeoutSeconds,
    int? retryCount,
    TaskRetryPolicy? retryPolicy,
    int? retryDelaySeconds,
    int? responseTimeoutSeconds,
    String? ownerEmail,
    String? pluginId,
    Map<String, String>? inputKeys,
    Map<String, String>? outputKeys,
    int? concurrentExecLimit,
  }) =>
      Task(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        tags: tags ?? this.tags,
        createdAt: createdAt,
        dueDate: dueDate ?? this.dueDate,
        config: config ?? this.config,
        timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
        retryCount: retryCount ?? this.retryCount,
        retryPolicy: retryPolicy ?? this.retryPolicy,
        retryDelaySeconds: retryDelaySeconds ?? this.retryDelaySeconds,
        responseTimeoutSeconds: responseTimeoutSeconds ?? this.responseTimeoutSeconds,
        ownerEmail: ownerEmail ?? this.ownerEmail,
        pluginId: pluginId ?? this.pluginId,
        inputKeys: inputKeys ?? Map.of(this.inputKeys),
        outputKeys: outputKeys ?? Map.of(this.outputKeys),
        concurrentExecLimit: concurrentExecLimit ?? this.concurrentExecLimit,
      );
}
