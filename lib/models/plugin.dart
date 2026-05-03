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
  /// README markdown shown in marketplace preview
  String? readme;
  /// Schema defining available config keys with type/default/description
  List<PluginConfigField> configSchema;
  /// User-configured values for this plugin instance
  Map<String, dynamic> configValues;

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
    this.readme,
    List<PluginConfigField>? configSchema,
    Map<String, dynamic>? configValues,
  })  : configSchema = configSchema ?? [],
        configValues = configValues ?? {};
}

enum PluginConfigFieldType { string, number, boolean, secret }

class PluginConfigField {
  final String key;
  final String label;
  final PluginConfigFieldType type;
  final dynamic defaultValue;
  final String? description;
  const PluginConfigField({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.description,
  });
}
