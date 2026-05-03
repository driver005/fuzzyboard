import 'package:flutter/material.dart';

enum TaskStatus { todo, inProgress, done, blocked }

enum TaskPriority { low, medium, high, critical }

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
  TaskPriority priority;
  TaskStatus status;
  List<String> tags;
  DateTime createdAt;
  DateTime? dueDate;
  Map<String, dynamic> config;

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
  })  : createdAt = createdAt ?? DateTime.now(),
        config = config ?? {};

  Task copyWith({
    String? name,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? tags,
    DateTime? dueDate,
    Map<String, dynamic>? config,
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
      );
}
