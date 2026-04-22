import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../models/plugin.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';

class PluginsPage extends StatelessWidget {
  const PluginsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final installed = app.installedPlugins;

    return Scaffold(
      appBar: AppBar(title: const Text('Plugins')),
      body: installed.isEmpty
          ? const _EmptyPlugins()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(
                    title: 'Installed Plugins',
                    count: installed.length),
                const SizedBox(height: 12),
                ...installed.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PluginCard(plugin: e.value)
                            .animate()
                            .fadeIn(delay: (e.key * 60).ms)
                            .slideX(begin: 0.1),
                      ),
                    ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary)),
        ),
      ],
    );
  }
}

class _PluginCard extends StatelessWidget {
  final Plugin plugin;
  const _PluginCard({required this.plugin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final app = context.read<AppProvider>();

    return AppCard(
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: plugin.category.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(plugin.iconEmoji ?? '🔌',
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(plugin.name, style: theme.textTheme.titleSmall),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: plugin.category.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(plugin.category.label,
                          style: TextStyle(
                              fontSize: 10,
                              color: plugin.category.color,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Text(plugin.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('v${plugin.version}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.4))),
                    const SizedBox(width: 8),
                    if (plugin.rating != null) ...[
                      const Icon(Icons.star, size: 12,
                          color: Color(0xFFF59E0B)),
                      const SizedBox(width: 2),
                      Text('${plugin.rating}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.6))),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Status & actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusBadge(status: plugin.status),
              const SizedBox(height: 8),
              AppButton(
                label: 'Remove',
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                onPressed: () => app.uninstallPlugin(plugin.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PluginStatus? status;
  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();
    final (color, label) = switch (status!) {
      PluginStatus.active => (const Color(0xFF10B981), 'Active'),
      PluginStatus.inactive => (const Color(0xFF6B7280), 'Inactive'),
      PluginStatus.error => (const Color(0xFFEF4444), 'Error'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyPlugins extends StatelessWidget {
  const _EmptyPlugins();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔌', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No plugins installed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5))),
          const SizedBox(height: 8),
          Text('Visit the Marketplace to install plugins.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4))),
        ],
      ),
    );
  }
}
