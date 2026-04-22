import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../models/plugin.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_input.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  String _search = '';
  PluginCategory? _filterCategory;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final plugins = app.plugins.where((p) {
      if (_search.isNotEmpty &&
          !p.name.toLowerCase().contains(_search.toLowerCase()) &&
          !p.description.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      if (_filterCategory != null && p.category != _filterCategory) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
      ),
      body: Column(
        children: [
          // Hero banner
          _MarketplaceBanner(),
          // Filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: AppInput(
                    hint: 'Search plugins...',
                    prefix: const Icon(Icons.search, size: 18),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 12),
                _CategoryFilter(
                  value: _filterCategory,
                  onChanged: (c) =>
                      setState(() => _filterCategory = c),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Category chips
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                    label: 'All',
                    selected: _filterCategory == null,
                    onTap: () =>
                        setState(() => _filterCategory = null)),
                ...PluginCategory.values.map(
                  (c) => _CategoryChip(
                    label: c.label,
                    color: c.color,
                    selected: _filterCategory == c,
                    onTap: () =>
                        setState(() => _filterCategory = c),
                  ),
                ),
              ],
            ),
          ),
          // Plugin grid
          Expanded(
            child: plugins.isEmpty
                ? const Center(child: Text('No plugins found'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: plugins
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _MarketplaceCard(plugin: e.value)
                                  .animate()
                                  .fadeIn(delay: (e.key * 50).ms),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MarketplaceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.secondary, cs.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🛍️', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plugin Marketplace',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                Text('Extend your workflow engine with community plugins.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }
}

class _MarketplaceCard extends StatelessWidget {
  final Plugin plugin;
  const _MarketplaceCard({required this.plugin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final app = context.read<AppProvider>();

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: plugin.category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(plugin.iconEmoji ?? '🔌',
                  style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(plugin.name,
                          style: theme.textTheme.titleSmall),
                    ),
                    if (plugin.rating != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 13, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text('${plugin.rating}',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                  ],
                ),
                Text(plugin.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: plugin.category.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(plugin.category.label,
                          style: TextStyle(
                              fontSize: 10,
                              color: plugin.category.color,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Text('by ${plugin.author}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.4))),
                    if (plugin.downloadCount != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.download, size: 12),
                      Text(
                          ' ${_formatCount(plugin.downloadCount!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.4))),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          plugin.isInstalled
              ? AppButton(
                  label: 'Installed',
                  variant: AppButtonVariant.ghost,
                  size: AppButtonSize.sm,
                  onPressed: null,
                )
              : AppButton(
                  label: 'Install',
                  icon: const Icon(Icons.download),
                  size: AppButtonSize.sm,
                  onPressed: () => app.installPlugin(plugin.id),
                ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = color ?? cs.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? effectiveColor
                : effectiveColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : effectiveColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final PluginCategory? value;
  final ValueChanged<PluginCategory?> onChanged;

  const _CategoryFilter({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PluginCategory?>(
      icon: const Icon(Icons.filter_list, size: 20),
      onSelected: onChanged,
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All Categories')),
        ...PluginCategory.values.map((c) =>
            PopupMenuItem(value: c, child: Text(c.label))),
      ],
    );
  }
}
