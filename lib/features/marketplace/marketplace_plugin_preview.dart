import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/gamification_provider.dart';
import '../../models/plugin.dart';
import '../../shared/widgets/app_button.dart';

/// Full-screen preview modal for a marketplace plugin showing its README.
class MarketplacePluginPreview extends StatelessWidget {
  final Plugin plugin;
  const MarketplacePluginPreview({super.key, required this.plugin});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final devMode = app.devMode;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

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
                  Text(plugin.iconEmoji ?? '🔌', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    plugin.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  _CategoryBadge(plugin: plugin),
                  const Spacer(),
                  if (!devMode && !plugin.isInstalled)
                    Tooltip(
                      message: 'Enable Dev Mode in Settings to install plugins',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, size: 14, color: cs.onSurface.withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text(
                            'Dev Mode Required',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.5)),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  if (plugin.isInstalled)
                    AppButton(
                      label: context.l10n.installedBadge,
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      onPressed: null,
                    )
                  else
                    AppButton(
                      label: context.l10n.installButton,
                      icon: const Icon(Icons.download),
                      size: AppButtonSize.sm,
                      onPressed: devMode
                          ? () {
                              app.installPlugin(plugin.id);
                              context.read<GamificationProvider>().onPluginInstalled();
                              Navigator.of(context).pop();
                            }
                          : null,
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Body: README + meta
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main: README
                  Expanded(
                    flex: 3,
                    child: _ReadmeView(readme: plugin.readme),
                  ),
                  VerticalDivider(width: 1, color: cs.outline.withOpacity(0.15)),
                  // Sidebar: metadata
                  SizedBox(
                    width: 240,
                    child: _PluginMetaPanel(plugin: plugin),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final Plugin plugin;
  const _CategoryBadge({required this.plugin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: plugin.category.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        plugin.category.label,
        style: TextStyle(fontSize: 11, color: plugin.category.color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ReadmeView extends StatelessWidget {
  final String? readme;
  const _ReadmeView({this.readme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final content = readme ?? '_No documentation available for this plugin._';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text('README', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
            ],
          ),
        ),
        Divider(height: 1, color: cs.outline.withOpacity(0.1)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _SimpleMarkdown(content: content),
          ),
        ),
      ],
    );
  }
}

/// Simple markdown-like renderer (no external package needed).
class _SimpleMarkdown extends StatelessWidget {
  final String content;
  const _SimpleMarkdown({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    final lines = content.split('\n');
    final widgets = <Widget>[];

    bool inCodeBlock = false;
    final codeBuffer = StringBuffer();

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('```')) {
        if (!inCodeBlock) {
          inCodeBlock = true;
          codeBuffer.clear();
        } else {
          inCodeBlock = false;
          widgets.add(Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF5F5FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outline.withOpacity(0.12)),
            ),
            child: SelectableText(
              codeBuffer.toString().trim(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF10B981), height: 1.5),
            ),
          ));
        }
        continue;
      }

      if (inCodeBlock) {
        codeBuffer.writeln(line);
        continue;
      }

      if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(line.substring(2), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(line.substring(3), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ));
      } else if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(line.substring(4), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 6),
                child: Container(width: 5, height: 5, decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
              ),
              Expanded(child: Text(line.substring(2), style: theme.textTheme.bodyMedium)),
            ],
          ),
        ));
      } else if (line.startsWith('| ')) {
        // Simple table row
        final cells = line.split('|').where((c) => c.trim().isNotEmpty).map((c) => c.trim()).toList();
        final isHeader = i + 1 < lines.length && lines[i + 1].contains('---');
        if (!line.contains('---')) {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: cells.map((c) => Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isHeader ? cs.primary.withOpacity(0.08) : null,
                  child: Text(c, style: isHeader
                      ? theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)
                      : theme.textTheme.bodySmall),
                ),
              )).toList(),
            ),
          ));
        }
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(line, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _PluginMetaPanel extends StatelessWidget {
  final Plugin plugin;
  const _PluginMetaPanel({required this.plugin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: plugin.category.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(plugin.iconEmoji ?? '🔌', style: const TextStyle(fontSize: 34)),
            ),
          ),
        ),
        _MetaRow('Author', plugin.author),
        _MetaRow('Version', 'v${plugin.version}'),
        _MetaRow('Category', plugin.category.label),
        if (plugin.rating != null)
          _MetaRow('Rating', '⭐ ${plugin.rating?.toStringAsFixed(1)}'),
        if (plugin.downloadCount != null)
          _MetaRow('Downloads', _formatCount(plugin.downloadCount!)),
        const SizedBox(height: 16),
        Divider(color: cs.outline.withOpacity(0.15)),
        const SizedBox(height: 8),
        Text('Config Fields', style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurface.withOpacity(0.5), fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        if (plugin.configSchema.isEmpty)
          Text('No config fields', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4)))
        else
          ...plugin.configSchema.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                _TypeDot(f.type),
                const SizedBox(width: 6),
                Expanded(child: Text(f.label, style: theme.textTheme.bodySmall)),
              ],
            ),
          )),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5))),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _TypeDot extends StatelessWidget {
  final PluginConfigFieldType type;
  const _TypeDot(this.type);

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      PluginConfigFieldType.string => const Color(0xFF3B82F6),
      PluginConfigFieldType.number => const Color(0xFF10B981),
      PluginConfigFieldType.boolean => const Color(0xFFF59E0B),
      PluginConfigFieldType.secret => const Color(0xFFEF4444),
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
