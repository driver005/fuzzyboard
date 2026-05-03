import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/providers/app_provider.dart';
import '../../models/plugin.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_input.dart';
import 'package:provider/provider.dart';

/// Full-screen modal showing an installed plugin's config fields
/// with a live JSON/YAML preview.
class PluginConfigModal extends StatefulWidget {
  final Plugin plugin;
  const PluginConfigModal({super.key, required this.plugin});

  @override
  State<PluginConfigModal> createState() => _PluginConfigModalState();
}

class _PluginConfigModalState extends State<PluginConfigModal> {
  late Map<String, dynamic> values;
  bool useYaml = false;
  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> boolValues = {};

  @override
  void initState() {
    super.initState();
    // Merge defaults with stored values
    values = {};
    for (final field in widget.plugin.configSchema) {
      final stored = widget.plugin.configValues[field.key];
      values[field.key] = stored ?? field.defaultValue;
    }
    // Build controllers
    for (final field in widget.plugin.configSchema) {
      if (field.type != PluginConfigFieldType.boolean) {
        controllers[field.key] = TextEditingController(
          text: '${values[field.key] ?? ''}',
        );
      } else {
        boolValues[field.key] = (values[field.key] as bool?) ?? false;
      }
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> get currentValues {
    final m = <String, dynamic>{};
    for (final field in widget.plugin.configSchema) {
      if (field.type == PluginConfigFieldType.boolean) {
        m[field.key] = boolValues[field.key] ?? false;
      } else if (field.type == PluginConfigFieldType.number) {
        m[field.key] = num.tryParse(controllers[field.key]?.text ?? '') ?? field.defaultValue;
      } else {
        m[field.key] = controllers[field.key]?.text ?? '';
      }
    }
    return m;
  }

  String get jsonPreview {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(currentValues);
  }

  String get yamlPreview => _toYaml(currentValues, 0);

  String _toYaml(dynamic value, int indent) {
    final pad = '  ' * indent;
    if (value is Map) {
      if (value.isEmpty) return '{}';
      final buf = StringBuffer();
      for (final entry in value.entries) {
        final v = entry.value;
        if (v is Map || v is List) {
          buf.writeln('$pad${entry.key}:');
          buf.write(_toYaml(v, indent + 1));
        } else {
          buf.writeln('$pad${entry.key}: ${_scalar(v)}');
        }
      }
      return buf.toString();
    } else if (value is List) {
      if (value.isEmpty) return '$pad[]\n';
      final buf = StringBuffer();
      for (final item in value) {
        buf.writeln('$pad- ${_scalar(item)}');
      }
      return buf.toString();
    }
    return '$pad${_scalar(value)}\n';
  }

  String _scalar(dynamic v) {
    if (v == null) return 'null';
    if (v is bool) return v ? 'true' : 'false';
    if (v is num) return '$v';
    final s = '$v';
    if (s.contains(':') || s.isEmpty) return '"$s"';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 800;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? const Color(0xFF12121E) : cs.surface,
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16162A) : Colors.white,
                border: Border(bottom: BorderSide(color: cs.outline.withOpacity(0.15))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(widget.plugin.iconEmoji ?? '🔌', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.plugin.name} — Config',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  _PreviewToggle(useYaml: useYaml, onToggle: (v) => setState(() => useYaml = v)),
                  const SizedBox(width: 12),
                  AppButton(
                    label: 'Save Config',
                    onPressed: () {
                      for (final entry in currentValues.entries) {
                        widget.plugin.configValues[entry.key] = entry.value;
                      }
                      context.read<AppProvider>().updatePlugin(widget.plugin);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Body
            Expanded(
              child: isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: _ConfigPreviewPanel(
                            content: useYaml ? yamlPreview : jsonPreview,
                            useYaml: useYaml,
                            onToggle: (v) => setState(() => useYaml = v),
                          ),
                        ),
                        VerticalDivider(width: 1, color: cs.outline.withOpacity(0.15)),
                        Expanded(
                          child: _ConfigFieldsPanel(
                            plugin: widget.plugin,
                            controllers: controllers,
                            boolValues: boolValues,
                            onChanged: () => setState(() {}),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _ConfigPreviewPanel(
                            content: useYaml ? yamlPreview : jsonPreview,
                            useYaml: useYaml,
                            onToggle: (v) => setState(() => useYaml = v),
                          ),
                          const SizedBox(height: 16),
                          _ConfigFieldsPanel(
                            plugin: widget.plugin,
                            controllers: controllers,
                            boolValues: boolValues,
                            onChanged: () => setState(() {}),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewToggle extends StatelessWidget {
  final bool useYaml;
  final ValueChanged<bool> onToggle;
  const _PreviewToggle({required this.useYaml, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleChip(label: 'JSON', selected: !useYaml, onTap: () => onToggle(false), cs: cs),
        const SizedBox(width: 4),
        _ToggleChip(label: 'YAML', selected: useYaml, onTap: () => onToggle(true), cs: cs),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _ToggleChip({required this.label, required this.selected, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : cs.primary,
          ),
        ),
      ),
    );
  }
}

class _ConfigPreviewPanel extends StatelessWidget {
  final String content;
  final bool useYaml;
  final ValueChanged<bool> onToggle;
  const _ConfigPreviewPanel({required this.content, required this.useYaml, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    return Container(
      color: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF5F5FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(Icons.data_object, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  useYaml ? 'YAML Preview' : 'JSON Preview',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                ),
                const Spacer(),
                _PreviewToggle(useYaml: useYaml, onToggle: onToggle),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outline.withOpacity(0.1)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                content,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.6,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigFieldsPanel extends StatelessWidget {
  final Plugin plugin;
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> boolValues;
  final VoidCallback onChanged;

  const _ConfigFieldsPanel({
    required this.plugin,
    required this.controllers,
    required this.boolValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configuration', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          if (plugin.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(plugin.description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
          const SizedBox(height: 20),
          if (plugin.configSchema.isEmpty)
            Center(
              child: Text('No configuration fields', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4))),
            )
          else
            ...plugin.configSchema.asMap().entries.map((entry) {
              final field = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ConfigFieldWidget(
                  field: field,
                  controller: controllers[field.key],
                  boolValue: boolValues[field.key],
                  onChanged: (v) {
                    if (v is bool) boolValues[field.key] = v;
                    onChanged();
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ConfigFieldWidget extends StatelessWidget {
  final PluginConfigField field;
  final TextEditingController? controller;
  final bool? boolValue;
  final ValueChanged<dynamic> onChanged;

  const _ConfigFieldWidget({
    required this.field,
    this.controller,
    this.boolValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (field.type == PluginConfigFieldType.boolean) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field.label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                if (field.description != null)
                  Text(field.description!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.5))),
              ],
            ),
          ),
          Switch(
            value: boolValue ?? false,
            onChanged: onChanged,
          ),
        ],
      );
    }

    return AppInput(
      label: field.label,
      hint: field.description ?? 'Enter ${field.label}',
      controller: controller,
      obscureText: field.type == PluginConfigFieldType.secret,
      keyboardType: field.type == PluginConfigFieldType.number ? TextInputType.number : null,
      onChanged: (_) => onChanged(null),
    );
  }
}
