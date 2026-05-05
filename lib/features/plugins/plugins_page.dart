import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../extensions/extension_zone.dart';
import '../../models/plugin.dart';
import '../../shared/widgets/app_card.dart';
import '../../app.dart';
import '../config/config_graph_page.dart';
import 'plugin_config_modal.dart';

class PluginsPage extends StatefulWidget {
  const PluginsPage({super.key});

  @override
  State<PluginsPage> createState() => _PluginsPageState();
}

class _PluginsPageState extends State<PluginsPage> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final installed = app.installedPlugins;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.pluginsTitle),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(icon: Icon(Icons.extension, size: 18), text: 'Installed'),
            Tab(icon: Icon(Icons.device_hub, size: 18), text: 'Config Graph'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // Tab 1: Installed plugins
          installed.isEmpty
              ? const _EmptyPlugins()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SectionHeader(
                        title: context.l10n.installedPluginsHeader,
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
                    // [extension zone] below the plugin list — plugins can add
                    // extra panels or status widgets here
                    const ExtensionZone(id: 'plugins.detail_panel'),
                  ],
                ),
          // Tab 2: Config Graph — use LayoutBuilder so InteractiveViewer
          // always gets a finite viewport size regardless of parent constraints.
          LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: const ConfigGraphWidget(),
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
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.18),
                theme.colorScheme.primary.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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

    return AppCard(
      onTap: () {
        HapticFeedback.lightImpact();
        showDialog(
          context: context,
          useSafeArea: false,
          builder: (_) => PluginConfigModal(plugin: plugin),
        );
      },
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  plugin.category.color.withOpacity(0.20),
                  plugin.category.color.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: plugin.category.color.withOpacity(0.20)),
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
                        gradient: LinearGradient(
                          colors: [
                            plugin.category.color.withOpacity(0.20),
                            plugin.category.color.withOpacity(0.10),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
      PluginStatus.active => (const Color(0xFF10B981), context.l10n.pluginStatusActive),
      PluginStatus.inactive => (const Color(0xFF6B7280), context.l10n.pluginStatusInactive),
      PluginStatus.error => (const Color(0xFFEF4444), context.l10n.pluginStatusError),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.18), color.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
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
          const Text('🔌', style: TextStyle(fontSize: 64))
              .animate()
              .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          Text(context.l10n.noPluginsInstalled,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5)))
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.3, delay: 200.ms),
          const SizedBox(height: 8),
          Text(context.l10n.noPluginsInstalledSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4)))
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
