import 'package:flutter/material.dart';

enum PluginCategory { trigger, action, integration, ui, utility }
enum PluginStatus { active, inactive, error }

extension PluginCategoryExt on PluginCategory {
  String get label => switch (this) {
        PluginCategory.trigger => 'Trigger',
        PluginCategory.action => 'Action',
        PluginCategory.integration => 'Integration',
        PluginCategory.ui => 'UI',
        PluginCategory.utility => 'Utility',
      };

  Color get color => switch (this) {
        PluginCategory.trigger => const Color(0xFF6C63FF),
        PluginCategory.action => const Color(0xFF3B82F6),
        PluginCategory.integration => const Color(0xFF10B981),
        PluginCategory.ui => const Color(0xFFEC4899),
        PluginCategory.utility => const Color(0xFFF59E0B),
      };
}

class Plugin {
  final String id;
  String name;
  String description;
  String author;
  String version;
  PluginCategory category;
  PluginStatus status;
  bool isInstalled;
  double? rating;
  int? downloadCount;
  String? iconEmoji;
  List<String> tags;

  Plugin({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.version,
    required this.category,
    this.status = PluginStatus.inactive,
    this.isInstalled = false,
    this.rating,
    this.downloadCount,
    this.iconEmoji,
    this.tags = const [],
  });
}
