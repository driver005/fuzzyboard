import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/cms_provider.dart';
import '../../models/cms_page.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_input.dart';
import '../../app.dart';

class PagesManagerPage extends StatefulWidget {
  const PagesManagerPage({super.key});
  @override
  State<PagesManagerPage> createState() => _PagesManagerPageState();
}

class _PagesManagerPageState extends State<PagesManagerPage> {
  CmsPageStatus? filterStatus;

  @override
  Widget build(BuildContext context) {
    final cms = context.watch<CmsProvider>();
    final filtered = filterStatus == null ? cms.pages : cms.pages.where((p) => p.status == filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.pagesTitle),
        actions: [
          AppButton(label: context.l10n.newPageButton, icon: const Icon(Icons.add), size: AppButtonSize.sm, onPressed: () => show_page_dialog(context)),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            for (final s in [null, CmsPageStatus.published, CmsPageStatus.draft, CmsPageStatus.scheduled])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(s == null ? 'All' : s.name, style: const TextStyle(fontSize: 12)),
                  selected: filterStatus == s,
                  onSelected: (_) => setState(() => filterStatus = s),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(context.l10n.noPages))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final page = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        leading: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: status_color(page.status).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.web_outlined, color: status_color(page.status), size: 18),
                        ),
                        title: page.title,
                        subtitle: '${page.slug} • ${page.template} template',
                        actions: [
                          _PageStatusChip(status: page.status),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (action) {
                              if (action == 'edit') show_page_dialog(context, page);
                              if (action == 'delete') context.read<CmsProvider>().deletePage(page.id);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: ListTile(dense: true, leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
                              const PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete_outline, color: Color(0xFFEF4444)), title: Text('Delete', style: TextStyle(color: Color(0xFFEF4444))))),
                            ],
                          ),
                        ],
                        onTap: () => show_page_dialog(context, page),
                      ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().slideX(begin: 0.05),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Color status_color(CmsPageStatus s) => switch (s) {
    CmsPageStatus.published => const Color(0xFF10B981),
    CmsPageStatus.draft => const Color(0xFFF59E0B),
    CmsPageStatus.scheduled => const Color(0xFF3B82F6),
  };

  void show_page_dialog(BuildContext context, [CmsPage? page]) {
    showDialog(context: context, builder: (_) => _PageDialog(existing: page));
  }
}

class _PageStatusChip extends StatelessWidget {
  final CmsPageStatus status;
  const _PageStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CmsPageStatus.published => (context.l10n.publishedStatus, const Color(0xFF10B981)),
      CmsPageStatus.draft => (context.l10n.draftStatus, const Color(0xFFF59E0B)),
      CmsPageStatus.scheduled => (context.l10n.scheduledStatus, const Color(0xFF3B82F6)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _PageDialog extends StatefulWidget {
  final CmsPage? existing;
  const _PageDialog({this.existing});

  @override
  State<_PageDialog> createState() => _PageDialogState();
}

class _PageDialogState extends State<_PageDialog> {
  final uuid = const Uuid();
  late TextEditingController titleController;
  late TextEditingController slugController;
  late TextEditingController seoTitleController;
  late TextEditingController seoDescController;
  CmsPageStatus status = CmsPageStatus.draft;
  String template = 'default';

  static const templates = ['default', 'hero', 'landing', 'list', 'form', 'pricing'];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.existing?.title ?? '');
    slugController = TextEditingController(text: widget.existing?.slug ?? '/');
    seoTitleController = TextEditingController(text: widget.existing?.seoTitle ?? '');
    seoDescController = TextEditingController(text: widget.existing?.seoDescription ?? '');
    status = widget.existing?.status ?? CmsPageStatus.draft;
    template = widget.existing?.template ?? 'default';
    if (widget.existing == null) {
      titleController.addListener(auto_slug);
    }
  }

  void auto_slug() {
    if (widget.existing != null) return;
    final raw = titleController.text.trim().toLowerCase();
    final slug = '/' + raw
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug != '/') slugController.text = slug;
  }

  @override
  void dispose() {
    titleController.removeListener(auto_slug);
    titleController.dispose();
    slugController.dispose();
    seoTitleController.dispose();
    seoDescController.dispose();
    super.dispose();
  }

  void save() {
    final title = titleController.text.trim();
    final slug = slugController.text.trim();
    if (title.isEmpty || slug.isEmpty) return;
    final cms = context.read<CmsProvider>();
    if (widget.existing != null) {
      widget.existing!
        ..title = title
        ..slug = slug
        ..seoTitle = seoTitleController.text.trim()
        ..seoDescription = seoDescController.text.trim()
        ..status = status
        ..template = template
        ..updatedAt = DateTime.now();
      cms.updatePage(widget.existing!);
    } else {
      cms.addPage(CmsPage(
        id: uuid.v4(), title: title, slug: slug,
        template: template, status: status,
        seoTitle: seoTitleController.text.trim(),
        seoDescription: seoDescController.text.trim(),
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 580),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Text(widget.existing != null ? context.l10n.editPageTitle : context.l10n.newPageTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  AppInput(label: context.l10n.pageTitleLabel, controller: titleController, hint: context.l10n.pageTitleHint),
                  const SizedBox(height: 12),
                  AppInput(label: context.l10n.slugLabel, controller: slugController, hint: context.l10n.slugHint),
                  const SizedBox(height: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(context.l10n.templateLabel, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: templates.map((t) => FilterChip(label: Text(t), selected: template == t, onSelected: (_) => setState(() => template = t))).toList(),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Status', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(children: CmsPageStatus.values.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(label: Text(s.name), selected: status == s, onSelected: (_) => setState(() => status = s)),
                    )).toList()),
                  ]),
                  const Divider(height: 24),
                  AppInput(label: context.l10n.seoTitleLabel, controller: seoTitleController, hint: context.l10n.seoTitleHint),
                  const SizedBox(height: 12),
                  AppInput(label: context.l10n.seoDescriptionLabel, controller: seoDescController, hint: context.l10n.seoDescriptionHint, maxLines: 2),
                ]),
              ),
            ),
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
