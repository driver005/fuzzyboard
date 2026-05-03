import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/cms_provider.dart';
import '../../models/cms_content_type.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_input.dart';
import '../../app.dart';

class ContentTypesPage extends StatelessWidget {
  const ContentTypesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cms = context.watch<CmsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.contentTypesTitle),
        actions: [
          AppButton(
            label: context.l10n.newTypeButton,
            icon: const Icon(Icons.add),
            size: AppButtonSize.sm,
            onPressed: () => show_type_dialog(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: cms.contentTypes.isEmpty
          ? Center(child: Text(context.l10n.noContentTypes))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cms.contentTypes.length,
              itemBuilder: (context, i) {
                final ct = cms.contentTypes[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: ct.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(ct.icon, color: ct.color, size: 20),
                    ),
                    title: ct.name,
                    subtitle: '${ct.fields.length} fields • ${ct.entryCount} entries • API: ${ct.apiId}',
                    actions: [
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => show_type_dialog(context, ct)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                        onPressed: () => confirm_delete(context, ct),
                      ),
                    ],
                    child: ct.fields.isEmpty
                        ? null
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: ct.fields.map((f) => _FieldChip(field: f)).toList(),
                          ),
                  ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.1),
                );
              },
            ),
    );
  }

  void show_type_dialog(BuildContext context, [CmsContentType? existing]) {
    showDialog(
      context: context,
      builder: (ctx) => _ContentTypeDialog(existing: existing),
    );
  }

  void confirm_delete(BuildContext context, CmsContentType ct) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.deleteContentTypeTitle),
        content: Text(ctx.l10n.deleteContentTypeConfirm(ct.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.l10n.cancelButton)),
          TextButton(
            onPressed: () {
              context.read<CmsProvider>().deleteContentType(ct.id);
              Navigator.pop(ctx);
            },
            child: Text(ctx.l10n.deleteAction, style: const TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  final CmsField field;
  const _FieldChip({required this.field});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = '${field.name} (${field.type.name})${field.required ? ' *' : ''}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.primary.withOpacity(0.15)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: cs.primary)),
    );
  }
}

class _ContentTypeDialog extends StatefulWidget {
  final CmsContentType? existing;
  const _ContentTypeDialog({this.existing});

  @override
  State<_ContentTypeDialog> createState() => _ContentTypeDialogState();
}

class _ContentTypeDialogState extends State<_ContentTypeDialog> {
  final uuid = const Uuid();
  late TextEditingController nameController;
  late TextEditingController apiIdController;
  late TextEditingController descController;
  late List<CmsField> fields;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existing?.name ?? '');
    apiIdController = TextEditingController(text: widget.existing?.apiId ?? '');
    descController = TextEditingController(text: widget.existing?.description ?? '');
    fields = List<CmsField>.from(widget.existing?.fields ?? []);
  }

  @override
  void dispose() {
    nameController.dispose();
    apiIdController.dispose();
    descController.dispose();
    super.dispose();
  }

  void addField() {
    setState(() => fields.add(CmsField(
      id: uuid.v4(),
      name: 'New Field',
      apiId: 'new_field_${fields.length}',
      type: CmsFieldType.text,
    )));
  }

  void save() {
    final name = nameController.text.trim();
    final apiId = apiIdController.text.trim();
    if (name.isEmpty || apiId.isEmpty) return;

    final cms = context.read<CmsProvider>();
    if (widget.existing != null) {
      widget.existing!
        ..name = name
        ..apiId = apiId
        ..description = descController.text.trim()
        ..fields = fields;
      cms.updateContentType(widget.existing!);
    } else {
      cms.addContentType(CmsContentType(
        id: uuid.v4(), name: name, apiId: apiId,
        description: descController.text.trim(),
        fields: fields, createdAt: DateTime.now(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Text(widget.existing != null ? context.l10n.editContentTypeTitle : context.l10n.newContentTypeTitle,
              style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppInput(label: context.l10n.displayNameLabel, controller: nameController, hint: context.l10n.displayNameHint),
            const SizedBox(height: 12),
            AppInput(label: context.l10n.apiIdLabel, controller: apiIdController, hint: context.l10n.apiIdHint),
            const SizedBox(height: 12),
            AppInput(label: 'Description', controller: descController, maxLines: 2),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(context.l10n.fieldsLabel, style: Theme.of(context).textTheme.titleSmall),
              TextButton.icon(onPressed: addField, icon: const Icon(Icons.add, size: 16), label: Text(context.l10n.addFieldButton)),
            ]),
            Expanded(
              child: ListView.builder(
                itemCount: fields.length,
                itemBuilder: (context, i) {
                  final f = fields[i];
                  return ListTile(
                    dense: true,
                    title: Text(f.name),
                    subtitle: Text(f.type.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() => fields.removeAt(i)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancelButton)),
              const SizedBox(width: 8),
              AppButton(label: context.l10n.saveButton, onPressed: save),
            ]),
          ]),
        ),
      ),
    );
  }
}
