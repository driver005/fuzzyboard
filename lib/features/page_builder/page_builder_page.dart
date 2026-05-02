import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/app_provider.dart';
import '../../models/page_widget.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_input.dart';

class PageBuilderPage extends StatefulWidget {
  const PageBuilderPage({super.key});
  @override
  State<PageBuilderPage> createState() => _PageBuilderPageState();
}

class _PageBuilderPageState extends State<PageBuilderPage> {
  final uuid = const Uuid();
  String? selectedId;

  static const paletteItems = [
    (type: 'Text', icon: Icons.text_fields, label: 'Text'),
    (type: 'Button', icon: Icons.smart_button, label: 'Button'),
    (type: 'Image', icon: Icons.image_outlined, label: 'Image'),
    (type: 'Card', icon: Icons.dashboard_outlined, label: 'Card'),
    (type: 'Row', icon: Icons.table_rows_outlined, label: 'Row'),
    (type: 'Column', icon: Icons.view_column_outlined, label: 'Column'),
    (type: 'Divider', icon: Icons.horizontal_rule, label: 'Divider'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final widgets = app.pageWidgets;
    final selected = selectedId != null ? widgets.cast<PageWidget?>().firstWhere((w) => w!.id == selectedId, orElse: () => null) : null;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Builder'),
        actions: [
          if (app.pageWidgets.isNotEmpty)
            AppButton(
              label: 'Clear',
              icon: const Icon(Icons.delete_outline),
              variant: AppButtonVariant.danger,
              size: AppButtonSize.sm,
              onPressed: () {
                for (final w in List.from(app.pageWidgets)) app.removePageWidget(w.id);
                setState(() => selectedId = null);
              },
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(children: [
        // Left palette
        Container(
          width: 80,
          color: isDark ? const Color(0xFF16162A) : Colors.white,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Palette', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurface.withOpacity(0.4))),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: paletteItems.map((item) => Draggable<String>(
                  data: item.type,
                  feedback: Material(
                    elevation: 4, borderRadius: BorderRadius.circular(8),
                    child: Container(padding: const EdgeInsets.all(8), child: Icon(item.icon, color: cs.primary)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: cs.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                    child: Column(children: [
                      Icon(item.icon, size: 20, color: cs.primary),
                      const SizedBox(height: 2),
                      Text(item.label, style: TextStyle(fontSize: 9, color: cs.primary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                )).toList(),
              ),
            ),
          ]),
        ),
        const VerticalDivider(width: 1),
        // Center canvas
        Expanded(
          flex: 3,
          child: DragTarget<String>(
            onAcceptWithDetails: (details) {
              final newWidget = PageWidget(id: uuid.v4(), type: details.data, label: details.data);
              context.read<AppProvider>().addPageWidget(newWidget);
              setState(() => selectedId = newWidget.id);
            },
            builder: (context, candidateData, rejectedData) {
              final isDragging = candidateData.isNotEmpty;
              return Container(
                color: isDragging ? cs.primary.withOpacity(0.05) : null,
                child: widgets.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.dashboard_customize_outlined, size: 64, color: cs.onSurface.withOpacity(0.2)),
                        const SizedBox(height: 12),
                        Text('Drag widgets here', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.4))),
                      ]))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: widgets.map((w) => GestureDetector(
                          onTap: () => setState(() => selectedId = selectedId == w.id ? null : w.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: selectedId == w.id ? cs.primary : cs.outline.withOpacity(0.3), width: selectedId == w.id ? 2 : 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _CanvasWidgetPreview(widget: w),
                          ),
                        )).toList(),
                      ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // Right properties panel
        Container(
          width: 220,
          color: isDark ? const Color(0xFF16162A) : Colors.white,
          padding: const EdgeInsets.all(12),
          child: selected == null
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.tune, size: 36, color: cs.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 8),
                  Text('Select a widget\nto edit its properties', textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4))),
                ])
              : _PropertiesPanel(
                  widget: selected,
                  onUpdate: () => setState(() {}),
                  onDelete: () {
                    context.read<AppProvider>().removePageWidget(selected.id);
                    setState(() => selectedId = null);
                  },
                ),
        ),
      ]),
    );
  }
}

class _CanvasWidgetPreview extends StatelessWidget {
  final PageWidget widget;
  const _CanvasWidgetPreview({required this.widget});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Icon(_iconForType(widget.type), size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Text('${widget.type}: ${widget.label}', style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }

  IconData _iconForType(String type) => switch (type) {
    'Text' => Icons.text_fields,
    'Button' => Icons.smart_button,
    'Image' => Icons.image_outlined,
    'Card' => Icons.dashboard_outlined,
    'Row' => Icons.table_rows_outlined,
    'Column' => Icons.view_column_outlined,
    'Divider' => Icons.horizontal_rule,
    _ => Icons.widgets,
  };
}

class _PropertiesPanel extends StatefulWidget {
  final PageWidget widget;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  const _PropertiesPanel({required this.widget, required this.onUpdate, required this.onDelete});

  @override
  State<_PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<_PropertiesPanel> {
  late TextEditingController labelController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.widget.label);
  }

  @override
  void didUpdateWidget(_PropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.widget.id != widget.widget.id) {
      labelController.text = widget.widget.label;
    }
  }

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Properties', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 12),
      Text('Type: ${widget.widget.type}', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 12),
      AppInput(
        label: 'Label',
        controller: labelController,
        onChanged: (v) {
          widget.widget.label = v;
          widget.onUpdate();
        },
      ),
      const SizedBox(height: 16),
      AppButton(label: 'Remove', icon: const Icon(Icons.delete_outline), variant: AppButtonVariant.danger, size: AppButtonSize.sm, fullWidth: true, onPressed: widget.onDelete),
    ]);
  }
}
