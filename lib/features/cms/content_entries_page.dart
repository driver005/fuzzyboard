import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/cms_provider.dart';
import '../../models/cms_content_type.dart';
import '../../models/cms_entry.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_input.dart';
import '../../app.dart';

class ContentEntriesPage extends StatefulWidget {
  const ContentEntriesPage({super.key});
  @override
  State<ContentEntriesPage> createState() => _ContentEntriesPageState();
}

class _ContentEntriesPageState extends State<ContentEntriesPage> {
  String selectedTypeId = '';
  CmsEntryStatus? filterStatus;
  String search = '';

  @override
  Widget build(BuildContext context) {
    final cms = context.watch<CmsProvider>();

    if (selectedTypeId.isEmpty && cms.contentTypes.isNotEmpty) {
      selectedTypeId = cms.contentTypes.first.id;
    }

    final type = cms.contentTypes.where((t) => t.id == selectedTypeId).isEmpty
        ? null
        : cms.contentTypes.firstWhere((t) => t.id == selectedTypeId);

    final filtered = cms.entries.where((e) {
      if (e.contentTypeId != selectedTypeId) return false;
      if (filterStatus != null && e.status != filterStatus) return false;
      if (search.isNotEmpty && !e.title.toLowerCase().contains(search.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.contentEntriesTitle),
        actions: [
          if (type != null)
            AppButton(
              label: context.l10n.newEntryButton,
              icon: const Icon(Icons.add),
              size: AppButtonSize.sm,
              onPressed: () => show_entry_dialog(context, type),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cms.contentTypes.map((ct) {
                  final isSelected = ct.id == selectedTypeId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text('${ct.name} (${cms.entriesForType(ct.id).length})'),
                      avatar: Icon(ct.icon, size: 14, color: isSelected ? ct.color : null),
                      onSelected: (_) => setState(() { selectedTypeId = ct.id; filterStatus = null; }),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: AppInput(hint: context.l10n.searchEntriesHint, prefix: const Icon(Icons.search, size: 18), onChanged: (v) => setState(() => search = v))),
              const SizedBox(width: 8),
              _StatusFilterChips(value: filterStatus, onChanged: (s) => setState(() => filterStatus = s)),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.article_outlined, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text(context.l10n.noEntriesEmpty, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final entry = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        title: entry.title,
                        subtitle: 'by ${entry.author} • ${format_date(entry.updatedAt)}',
                        actions: [
                          _StatusBadge(status: entry.status),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (action) {
                              switch (action) {
                                case 'edit': show_entry_dialog(context, type!, entry: entry);
                                case 'publish': context.read<CmsProvider>().publishEntry(entry.id);
                                case 'archive': context.read<CmsProvider>().archiveEntry(entry.id);
                                case 'delete': context.read<CmsProvider>().deleteEntry(entry.id);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: ListTile(dense: true, leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
                              if (entry.status != CmsEntryStatus.published)
                                const PopupMenuItem(value: 'publish', child: ListTile(dense: true, leading: Icon(Icons.publish), title: Text('Publish'))),
                              if (entry.status != CmsEntryStatus.archived)
                                const PopupMenuItem(value: 'archive', child: ListTile(dense: true, leading: Icon(Icons.archive_outlined), title: Text('Archive'))),
                              const PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete_outline, color: Color(0xFFEF4444)), title: Text('Delete', style: TextStyle(color: Color(0xFFEF4444))))),
                            ],
                          ),
                        ],
                        onTap: () => show_entry_dialog(context, type!, entry: entry),
                      ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().slideX(begin: 0.05),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  String format_date(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void show_entry_dialog(BuildContext context, CmsContentType type, {CmsEntry? entry}) {
    showDialog(context: context, builder: (_) => _EntryDialog(type: type, existing: entry));
  }
}

class _StatusFilterChips extends StatelessWidget {
  final CmsEntryStatus? value;
  final ValueChanged<CmsEntryStatus?> onChanged;
  const _StatusFilterChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (final s in [null, CmsEntryStatus.published, CmsEntryStatus.draft, CmsEntryStatus.archived])
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: FilterChip(
            label: Text(s == null ? 'All' : s.name, style: const TextStyle(fontSize: 12)),
            selected: value == s,
            onSelected: (_) => onChanged(s),
          ),
        ),
    ]);
  }
}

class _StatusBadge extends StatelessWidget {
  final CmsEntryStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CmsEntryStatus.published => ('Published', const Color(0xFF10B981)),
      CmsEntryStatus.draft => ('Draft', const Color(0xFFF59E0B)),
      CmsEntryStatus.archived => ('Archived', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _EntryDialog extends StatefulWidget {
  final CmsContentType type;
  final CmsEntry? existing;
  const _EntryDialog({required this.type, this.existing});

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  final uuid = const Uuid();
  late TextEditingController titleController;
  CmsEntryStatus status = CmsEntryStatus.draft;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.existing?.title ?? '');
    status = widget.existing?.status ?? CmsEntryStatus.draft;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void save() {
    final title = titleController.text.trim();
    if (title.isEmpty) return;
    final cms = context.read<CmsProvider>();
    if (widget.existing != null) {
      widget.existing!.title = title;
      widget.existing!.status = status;
      widget.existing!.updatedAt = DateTime.now();
      cms.updateEntry(widget.existing!);
    } else {
      cms.addEntry(CmsEntry(
        id: uuid.v4(), contentTypeId: widget.type.id,
        title: title, status: status,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.existing != null ? context.l10n.editEntryTitle : context.l10n.newEntryTitle(widget.type.name),
              style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppInput(label: context.l10n.entryTitleLabel, controller: titleController, hint: context.l10n.entryTitleHint, autofocus: true),
            const SizedBox(height: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Status', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(children: CmsEntryStatus.values.map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(label: Text(s.name), selected: status == s, onSelected: (_) => setState(() => status = s)),
              )).toList()),
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancelButton)),
              const SizedBox(width: 8),
              AppButton(label: widget.existing != null ? 'Update' : context.l10n.createButton, onPressed: save),
            ]),
          ]),
        ),
      ),
    );
  }
}
