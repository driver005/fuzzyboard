import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/cms_provider.dart';
import '../../models/cms_category.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_input.dart';
import '../../app.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cms = context.watch<CmsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.categoriesTitle),
        actions: [
          AppButton(label: context.l10n.newCategoryButton, icon: const Icon(Icons.add), size: AppButtonSize.sm, onPressed: () => show_dialog(context)),
          const SizedBox(width: 12),
        ],
      ),
      body: cms.categories.isEmpty
          ? Center(child: Text(context.l10n.noCategoriesEmpty))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cms.categories.length,
              itemBuilder: (context, i) {
                final cat = cms.categories[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle),
                      child: const Icon(Icons.label, color: Colors.white, size: 18),
                    ),
                    title: cat.name,
                    subtitle: '/${cat.slug}${cat.description.isNotEmpty ? ' • ${cat.description}' : ''}',
                    actions: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                        child: Text(context.l10n.categoryEntriesCount(cat.entryCount), style: TextStyle(fontSize: 11, color: cat.color, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 4),
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => show_dialog(context, cat)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                        onPressed: () => cms.deleteCategory(cat.id),
                      ),
                    ],
                  ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.1),
                );
              },
            ),
    );
  }

  void show_dialog(BuildContext context, [CmsCategory? cat]) {
    showDialog(context: context, builder: (_) => _CategoryDialog(existing: cat));
  }
}

class _CategoryDialog extends StatefulWidget {
  final CmsCategory? existing;
  const _CategoryDialog({this.existing});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final uuid = const Uuid();
  late TextEditingController nameController;
  late TextEditingController slugController;
  late TextEditingController descController;
  late Color color;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existing?.name ?? '');
    slugController = TextEditingController(text: widget.existing?.slug ?? '');
    descController = TextEditingController(text: widget.existing?.description ?? '');
    color = widget.existing?.color ?? const Color(0xFF6C63FF);
    if (widget.existing == null) {
      nameController.addListener(_autoSlug);
    }
  }

  void _autoSlug() {
    if (widget.existing != null) return;
    final raw = nameController.text.trim().toLowerCase();
    slugController.text = raw
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  void dispose() {
    nameController.removeListener(_autoSlug);
    nameController.dispose();
    slugController.dispose();
    descController.dispose();
    super.dispose();
  }

  void pickColor() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick a color'),
        content: ColorPicker(pickerColor: color, onColorChanged: (c) => setState(() => color = c)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done'))],
      ),
    );
  }

  void save() {
    final name = nameController.text.trim();
    final slug = slugController.text.trim();
    if (name.isEmpty || slug.isEmpty) return;
    final cms = context.read<CmsProvider>();
    if (widget.existing != null) {
      widget.existing!
        ..name = name
        ..slug = slug
        ..description = descController.text.trim()
        ..color = color;
      cms.updateCategory(widget.existing!);
    } else {
      cms.addCategory(CmsCategory(
        id: uuid.v4(), name: name, slug: slug,
        description: descController.text.trim(),
        color: color, createdAt: DateTime.now(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.existing != null ? context.l10n.editCategoryTitle : context.l10n.newCategoryTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppInput(label: context.l10n.categoryNameLabel, controller: nameController, hint: context.l10n.categoryNameHint),
            const SizedBox(height: 12),
            AppInput(label: context.l10n.categorySlugLabel, controller: slugController, hint: context.l10n.categorySlugHint),
            const SizedBox(height: 12),
            AppInput(label: 'Description', controller: descController, maxLines: 2),
            const SizedBox(height: 12),
            Row(children: [
              Text(context.l10n.categoryColorLabel, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: pickColor,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.1))),
                ),
              ),
              const SizedBox(width: 8),
              Text(color.value.toRadixString(16).toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
            ]),
            const SizedBox(height: 20),
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
