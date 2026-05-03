import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cms_provider.dart';
import '../../models/cms_entry.dart';
import '../../shared/widgets/app_card.dart';
import '../../app.dart';

class CmsOverviewPage extends StatelessWidget {
  const CmsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cms = context.watch<CmsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.cmsOverviewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatRow(cms: cms),
          const SizedBox(height: 24),
          Text(context.l10n.quickActionsTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickAction(icon: Icons.add_circle_outline, label: context.l10n.newEntryAction, color: const Color(0xFF6C63FF), onTap: () => context.go('/cms/entries')),
              _QuickAction(icon: Icons.upload_outlined, label: context.l10n.uploadMediaAction, color: const Color(0xFF10B981), onTap: () => context.go('/cms/media')),
              _QuickAction(icon: Icons.web_outlined, label: context.l10n.managePagesAction, color: const Color(0xFF3B82F6), onTap: () => context.go('/cms/pages')),
              _QuickAction(icon: Icons.category_outlined, label: context.l10n.categoriesAction, color: const Color(0xFFF59E0B), onTap: () => context.go('/cms/categories')),
              _QuickAction(icon: Icons.schema_outlined, label: context.l10n.contentTypesAction, color: const Color(0xFFEC4899), onTap: () => context.go('/cms/types')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.recentEntriesTitle, style: Theme.of(context).textTheme.titleMedium),
              TextButton(onPressed: () => context.go('/cms/entries'), child: Text(context.l10n.viewAllButton)),
            ],
          ),
          const SizedBox(height: 8),
          ...cms.entries.take(5).toList().asMap().entries.map((e) {
            final entry = e.value;
            final typeIdx = cms.contentTypes.indexWhere((t) => t.id == entry.contentTypeId);
            final type = typeIdx != -1 ? cms.contentTypes[typeIdx] : null;
            final color = type?.color ?? const Color(0xFF6C63FF);
            final icon = type?.icon ?? Icons.article;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 18),
                ),
                title: entry.title,
                subtitle: '${type?.name ?? ''} • ${entry.status.name}',
                actions: [
                  _StatusChip(status: entry.status),
                ],
                onTap: () => context.go('/cms/entries'),
              ).animate(delay: Duration(milliseconds: e.key * 60)).fadeIn().slideX(begin: 0.05),
            );
          }),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final CmsProvider cms;
  const _StatRow({required this.cms});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (context.l10n.totalEntriesStats, '${cms.totalEntries}', Icons.article, const Color(0xFF6C63FF)),
      (context.l10n.publishedStats, '${cms.publishedEntries}', Icons.check_circle_outline, const Color(0xFF10B981)),
      (context.l10n.draftsStats, '${cms.draftEntries}', Icons.edit_note, const Color(0xFFF59E0B)),
      (context.l10n.mediaFilesStats, '${cms.totalMedia}', Icons.photo_library_outlined, const Color(0xFF3B82F6)),
      (context.l10n.pagesStats, '${cms.totalPages}', Icons.web_outlined, const Color(0xFFEC4899)),
    ];
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 700 ? 5 : 2;
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: stats.asMap().entries.map((e) {
          final (title, value, icon, color) = e.value;
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 22),
                const Spacer(),
                Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ).animate(delay: Duration(milliseconds: e.key * 80)).fadeIn().slideY(begin: 0.2);
        }).toList(),
      );
    });
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final CmsEntryStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CmsEntryStatus.published => (context.l10n.publishedStatus, const Color(0xFF10B981)),
      CmsEntryStatus.draft => (context.l10n.draftStatus, const Color(0xFFF59E0B)),
      CmsEntryStatus.archived => ('Archived', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
