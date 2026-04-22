import 'package:flutter/material.dart';

enum NodeType { trigger, action, condition, delay, script, end }
enum ConnectionType { success, failure, always }

class WorkflowNode {
  final String id;
  String label;
  NodeType type;
  Offset position;
  Map<String, dynamic> config;

  WorkflowNode({
    required this.id,
    required this.label,
    required this.type,
    required this.position,
    Map<String, dynamic>? config,
  }) : config = config ?? {};

  static Color colorForType(NodeType type) => switch (type) {
        NodeType.trigger => const Color(0xFF6C63FF),
        NodeType.action => const Color(0xFF3B82F6),
        NodeType.condition => const Color(0xFFF59E0B),
        NodeType.delay => const Color(0xFF8B5CF6),
        NodeType.script => const Color(0xFF10B981),
        NodeType.end => const Color(0xFFEF4444),
      };

  static IconData iconForType(NodeType type) => switch (type) {
        NodeType.trigger => Icons.bolt,
        NodeType.action => Icons.play_arrow,
        NodeType.condition => Icons.call_split,
        NodeType.delay => Icons.timer,
        NodeType.script => Icons.code,
        NodeType.end => Icons.stop,
      };
}

class WorkflowConnection {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final ConnectionType type;
  String? label;

  WorkflowConnection({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.type = ConnectionType.always,
    this.label,
  });
}

class Workflow {
  final String id;
  String name;
  String description;
  bool isActive;
  List<WorkflowNode> nodes;
  List<WorkflowConnection> connections;
  DateTime createdAt;
  int runCount;

  Workflow({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = false,
    List<WorkflowNode>? nodes,
    List<WorkflowConnection>? connections,
    DateTime? createdAt,
    this.runCount = 0,
  })  : nodes = nodes ?? [],
        connections = connections ?? [],
        createdAt = createdAt ?? DateTime.now();
}
