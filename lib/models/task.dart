import 'package:flutter/material.dart';

enum TaskStatus { todo, inProgress, done, failed }
enum TaskPriority { low, medium, high, critical }

extension TaskStatusExt on TaskStatus {
  String get label => switch (this) {
        TaskStatus.todo => 'To Do',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.done => 'Done',
        TaskStatus.failed => 'Failed',
      };

  Color get color => switch (this) {
        TaskStatus.todo => const Color(0xFF6B7280),
        TaskStatus.inProgress => const Color(0xFF3B82F6),
        TaskStatus.done => const Color(0xFF10B981),
        TaskStatus.failed => const Color(0xFFEF4444),
      };
}

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

class Task {
  final String id;
  String name;
  String description;
  TaskStatus status;
  TaskPriority priority;
  List<String> tags;
  DateTime createdAt;
  DateTime? dueDate;
  Map<String, dynamic> config;

  Task({
    required this.id,
    required this.name,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.tags = const [],
    DateTime? createdAt,
    this.dueDate,
    Map<String, dynamic>? config,
  })  : createdAt = createdAt ?? DateTime.now(),
        config = config ?? {};

  Task copyWith({
    String? name,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? tags,
    DateTime? dueDate,
    Map<String, dynamic>? config,
  }) =>
      Task(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        tags: tags ?? this.tags,
        createdAt: createdAt,
        dueDate: dueDate ?? this.dueDate,
        config: config ?? this.config,
      );
}
