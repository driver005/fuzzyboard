import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/app_provider.dart';
import '../../models/workflow.dart';
import '../../app.dart';
import '../../shared/widgets/app_button.dart';

/// Full-screen workflow visual canvas builder.
class WorkflowCanvas extends StatefulWidget {
  final String workflowId;
  const WorkflowCanvas({super.key, required this.workflowId});

  @override
  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends State<WorkflowCanvas> {
  late Workflow _workflow;
  String? _selectedNodeId;
  bool _connecting = false;
  String? _connectFromId;
  final TransformationController _transform = TransformationController();
  final FocusNode _keyboardFocus = FocusNode();
  final _uuid = const Uuid();
  final List<Map<String, dynamic>> _undoStack = [];
  final List<Map<String, dynamic>> _redoStack = [];

  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    _workflow = app.workflows.firstWhere((w) => w.id == widget.workflowId);
  }

  @override
  void dispose() {
    _transform.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  void save() {
    context.read<AppProvider>().updateWorkflow(_workflow);
    Navigator.of(context).pop();
  }

  void add_node(NodeType type) {
    final node = WorkflowNode(
      id: _uuid.v4(),
      label: label_for_type(type),
      type: type,
      position: const Offset(300, 300),
    );
    push_undo();
    setState(() => _workflow.nodes.add(node));
  }

  String label_for_type(NodeType type) => switch (type) {
        NodeType.trigger => 'New Trigger',
        NodeType.action => 'New Action',
        NodeType.condition => 'Condition',
        NodeType.delay => 'Delay',
        NodeType.script => 'Script',
        NodeType.end => 'End',
      };

  void delete_node(String id) {
    push_undo();
    setState(() {
      _workflow.nodes.removeWhere((n) => n.id == id);
      _workflow.connections
          .removeWhere((c) => c.fromNodeId == id || c.toNodeId == id);
      if (_selectedNodeId == id) _selectedNodeId = null;
    });
  }

  void on_node_tap(String id) {
    if (_connecting && _connectFromId != null && _connectFromId != id) {
      final conn = WorkflowConnection(
        id: _uuid.v4(),
        fromNodeId: _connectFromId!,
        toNodeId: id,
      );
      push_undo();
      setState(() {
        _workflow.connections.add(conn);
        _connecting = false;
        _connectFromId = null;
      });
    } else {
      setState(() => _selectedNodeId = _selectedNodeId == id ? null : id);
    }
  }

  void start_connect(String id) {
    setState(() {
      _connecting = true;
      _connectFromId = id;
    });
  }

  Map<String, dynamic> capture_snapshot() {
    return {
      'nodes': _workflow.nodes.map((n) => {
        'id': n.id, 'label': n.label, 'type': n.type.name,
        'x': n.position.dx, 'y': n.position.dy, 'config': Map.from(n.config),
      }).toList(),
      'connections': _workflow.connections.map((c) => {
        'id': c.id, 'from': c.fromNodeId, 'to': c.toNodeId,
        'type': c.type.name, 'label': c.label,
      }).toList(),
    };
  }

  void push_undo() {
    _undoStack.add(capture_snapshot());
    if (_undoStack.length > 30) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  void apply_snapshot(Map<String, dynamic> snapshot) {
    final nodes = (snapshot['nodes'] as List).map((n) => WorkflowNode(
      id: n['id'] as String, label: n['label'] as String,
      type: NodeType.values.firstWhere((t) => t.name == n['type'], orElse: () => NodeType.action),
      position: Offset((n['x'] as num).toDouble(), (n['y'] as num).toDouble()),
      config: Map<String, dynamic>.from(n['config'] as Map? ?? {}),
    )).toList();
    final connections = (snapshot['connections'] as List).map((c) => WorkflowConnection(
      id: c['id'] as String, fromNodeId: c['from'] as String, toNodeId: c['to'] as String,
      type: ConnectionType.values.firstWhere((t) => t.name == c['type'], orElse: () => ConnectionType.always),
      label: c['label'] as String?,
    )).toList();
    setState(() {
      _workflow.nodes..clear()..addAll(nodes);
      _workflow.connections..clear()..addAll(connections);
    });
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(capture_snapshot());
    apply_snapshot(_undoStack.removeLast());
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(capture_snapshot());
    apply_snapshot(_redoStack.removeLast());
  }

  void delete_connection(String id) {
    push_undo();
    setState(() => _workflow.connections.removeWhere((c) => c.id == id));
  }

  void cancel_connect() {
    setState(() {
      _connecting = false;
      _connectFromId = null;
    });
  }

  void show_tutorial() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Text('🗺️ ', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 6),
            Text(ctx.l10n.canvasWorkflowGuideTitle),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _TutorialSection(
                  icon: Icons.add_box_outlined,
                  title: ctx.l10n.addingNodesSection,
                  body:
                      'Click any node type in the left palette to place it on the canvas.',
                ),
                _TutorialSection(
                  icon: Icons.drag_indicator,
                  title: ctx.l10n.movingNodesSection,
                  body:
                      'Drag a node to reposition it anywhere on the canvas.',
                ),
                _TutorialSection(
                  icon: Icons.link,
                  title: ctx.l10n.connectingNodesSection,
                  body:
                      'Click the 🔗 icon on a node to enter connect mode, then click the target node to draw an arrow. Press ESC or tap the × chip in the toolbar to cancel.',
                ),
                _TutorialSection(
                  icon: Icons.settings_outlined,
                  title: ctx.l10n.configuringNodesSection,
                  body:
                      'Tap a node to open its config panel on the right. You can rename it, and delete any of its connections there.',
                ),
                _TutorialSection(
                  icon: Icons.delete_outline,
                  title: ctx.l10n.deletingSection,
                  body:
                      'Use the 🗑 icon on a node to remove it and all its connections. To remove a single connection, open the source node config panel.',
                ),
                _TutorialSection(
                  icon: Icons.undo,
                  title: ctx.l10n.undoRedoSection,
                  body:
                      'Up to 30 undo steps are stored. Use the toolbar arrows to step back and forward.',
                ),
                _TutorialSection(
                  icon: Icons.upload_outlined,
                  title: ctx.l10n.exportImportSection,
                  body:
                      'Export copies the workflow as JSON to your clipboard. Import lets you paste JSON to restore a workflow.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.gotItButton),
          ),
        ],
      ),
    );
  }
  Future<void> export_json() async {
    final data = {
      'id': _workflow.id,
      'name': _workflow.name,
      'description': _workflow.description,
      'nodes': _workflow.nodes.map((n) => {
        'id': n.id,
        'label': n.label,
        'type': n.type.name,
        'x': n.position.dx,
        'y': n.position.dy,
        'config': n.config,
      }).toList(),
      'connections': _workflow.connections.map((c) => {
        'id': c.id,
        'from': c.fromNodeId,
        'to': c.toNodeId,
        'type': c.type.name,
        'label': c.label,
      }).toList(),
    };
    final json = const JsonEncoder.withIndent('  ').convert(data);
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.canvasWorkflowJsonCopied)),
      );
    }
  }

  /// Show import dialog and parse JSON.
  void show_import_dialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.canvasImportJsonTitle),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 12,
            decoration: InputDecoration(
              hintText: ctx.l10n.canvasImportJsonHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.l10n.cancelButton)),
          TextButton(
            child: Text(ctx.l10n.importButton),
            onPressed: () {
              try {
                final data = jsonDecode(controller.text) as Map<String, dynamic>;
                final nodes = (data['nodes'] as List).map((n) => WorkflowNode(
                  id: n['id'] as String,
                  label: n['label'] as String,
                  type: NodeType.values.firstWhere((t) => t.name == n['type'], orElse: () => NodeType.action),
                  position: Offset((n['x'] as num).toDouble(), (n['y'] as num).toDouble()),
                  config: Map<String, dynamic>.from(n['config'] as Map? ?? {}),
                )).toList();
                final connections = (data['connections'] as List).map((c) => WorkflowConnection(
                  id: c['id'] as String,
                  fromNodeId: c['from'] as String,
                  toNodeId: c['to'] as String,
                  type: ConnectionType.values.firstWhere((t) => t.name == c['type'], orElse: () => ConnectionType.always),
                  label: c['label'] as String?,
                )).toList();
                setState(() {
                  _workflow.nodes
                    ..clear()
                    ..addAll(nodes);
                  _workflow.connections
                    ..clear()
                    ..addAll(connections);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.canvasWorkflowImported)));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.canvasImportError(e.toString()))));
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return KeyboardListener(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            _connecting) {
          cancel_connect();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_workflow.name),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (_connecting)
              Chip(
                avatar: const Icon(Icons.link, size: 16),
                label: const Text('Click target node — ESC to cancel'),
                backgroundColor: cs.primary.withOpacity(0.15),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: cancel_connect,
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: _undoStack.isEmpty ? null : undo,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: 'Redo',
              onPressed: _redoStack.isEmpty ? null : redo,
            ),
            const SizedBox(width: 8),
            AppButton(
              label: context.l10n.canvasExportButton,
              icon: const Icon(Icons.upload_outlined),
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              onPressed: export_json,
            ),
            const SizedBox(width: 8),
            AppButton(
              label: context.l10n.importButton,
              icon: const Icon(Icons.download_outlined),
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              onPressed: show_import_dialog,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'How to use',
              onPressed: show_tutorial,
            ),
            const SizedBox(width: 8),
            AppButton(
              label: 'Save',
              icon: const Icon(Icons.save),
              size: AppButtonSize.sm,
              onPressed: save,
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Row(
          children: [
            _NodePalette(onAdd: add_node),
            Expanded(
              child: Stack(
                children: [
                  // Grid background
                  Container(
                    color: isDark
                        ? const Color(0xFF0F0F1A)
                        : const Color(0xFFF8F9FF),
                    child: CustomPaint(
                      painter: _GridPainter(
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.black.withOpacity(0.04)),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  // Interactive view
                  InteractiveViewer(
                    transformationController: _transform,
                    boundaryMargin: const EdgeInsets.all(800),
                    minScale: 0.3,
                    maxScale: 2.5,
                    child: SizedBox(
                      width: 2000,
                      height: 1500,
                      child: Stack(
                        children: [
                          // Connections drawn inside InteractiveViewer so they pan/zoom with nodes
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ConnectionsPainter(
                                nodes: _workflow.nodes,
                                connections: _workflow.connections,
                                primaryColor: cs.primary,
                              ),
                            ),
                          ),
                          ..._workflow.nodes.map((node) {
                            return Positioned(
                              left: node.position.dx,
                              top: node.position.dy,
                              child: _NodeWidget(
                                node: node,
                                isSelected: _selectedNodeId == node.id,
                                isConnectSource: _connectFromId == node.id,
                                isConnecting: _connecting,
                                onTap: () => on_node_tap(node.id),
                                onDrag: (delta) {
                                  setState(() {
                                    node.position = Offset(
                                      node.position.dx + delta.dx,
                                      node.position.dy + delta.dy,
                                    );
                                  });
                                },
                                onConnect: () => start_connect(node.id),
                                onDelete: () => delete_node(node.id),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  // Connect-mode overlay hint
                  if (_connecting)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Material(
                          borderRadius: BorderRadius.circular(24),
                          color: cs.primary,
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.touch_app,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  'Click any node to connect — ESC to cancel',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Selected node config panel
                  if (_selectedNodeId != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 280,
                    child: _NodeConfigPanel(
                      node: _workflow.nodes
                          .firstWhere((n) => n.id == _selectedNodeId),
                      connections: _workflow.connections,
                      nodes: _workflow.nodes,
                      onClose: () =>
                          setState(() => _selectedNodeId = null),
                      onUpdate: (n) => setState(() {}),
                      onDeleteConnection: delete_connection,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),  // Scaffold
  );  // KeyboardListener
  }  // build
}  // _WorkflowCanvasState

// ── Node Palette ─────────────────────────────────────────────────────────────

class _NodePalette extends StatelessWidget {
  final void Function(NodeType) onAdd;
  const _NodePalette({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Container(
      width: 80,
      color: isDark ? const Color(0xFF16162A) : Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Nodes',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: cs.onSurface.withOpacity(0.4))),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: NodeType.values.map((type) {
                return _PaletteItem(type: type, onAdd: onAdd);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteItem extends StatelessWidget {
  final NodeType type;
  final void Function(NodeType) onAdd;
  const _PaletteItem({required this.type, required this.onAdd});

  static String _descriptionForType(NodeType t) => switch (t) {
        NodeType.trigger => 'Starts the workflow (e.g. on event)',
        NodeType.action => 'Runs an action (e.g. send email)',
        NodeType.condition => 'Branch on true/false',
        NodeType.delay => 'Wait a specified time',
        NodeType.script => 'Run a Lua/SQL script',
        NodeType.end => 'Marks the workflow end',
      };

  @override
  Widget build(BuildContext context) {
    final color = WorkflowNode.colorForType(type);
    return Tooltip(
      message: _descriptionForType(type),
      preferBelow: false,
      child: InkWell(
        onTap: () => onAdd(type),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(WorkflowNode.iconForType(type), color: color, size: 20),
              const SizedBox(height: 4),
              Text(type.name,
                  style: TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Node Widget ───────────────────────────────────────────────────────────────

class _NodeWidget extends StatelessWidget {
  final WorkflowNode node;
  final bool isSelected;
  final bool isConnectSource;
  final bool isConnecting;
  final VoidCallback onTap;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onConnect;
  final VoidCallback onDelete;

  const _NodeWidget({
    required this.node,
    required this.isSelected,
    required this.isConnectSource,
    required this.isConnecting,
    required this.onTap,
    required this.onDrag,
    required this.onConnect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = WorkflowNode.colorForType(node.type);
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    // When in connect mode and this is NOT the source, show it as a target candidate
    final isTarget = isConnecting && !isConnectSource;

    return GestureDetector(
      onTap: onTap,
      onPanUpdate: (details) => onDrag(details.delta),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 160,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnectSource
                ? Colors.orange
                : isTarget
                    ? color
                    : isSelected
                        ? color
                        : color.withOpacity(0.3),
            width: isConnectSource || isSelected ? 2.5 : isTarget ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isTarget ? 0.35 : 0.2),
              blurRadius: 12,
              spreadRadius: isSelected || isTarget ? 3 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  Icon(WorkflowNode.iconForType(node.type),
                      color: color, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      node.type.name.toUpperCase(),
                      style: TextStyle(
                          fontSize: 9,
                          color: color,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5),
                    ),
                  ),
                  if (isConnectSource)
                    const Icon(Icons.radio_button_checked,
                        size: 10, color: Colors.orange),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                node.label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isConnecting)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NodeAction(
                        icon: Icons.link,
                        color: color,
                        tooltip: 'Connect to another node',
                        onTap: onConnect),
                    _NodeAction(
                        icon: Icons.delete_outline,
                        color: Colors.red.shade400,
                        tooltip: 'Delete node',
                        onTap: onDelete),
                  ],
                ),
              ),
            if (isTarget)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_downward, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text('Tap to connect',
                        style: TextStyle(
                            fontSize: 9,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NodeAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _NodeAction(
      {required this.icon,
      required this.color,
      required this.tooltip,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

// ── Node Config Panel ─────────────────────────────────────────────────────────

class _NodeConfigPanel extends StatefulWidget {
  final WorkflowNode node;
  final List<WorkflowConnection> connections;
  final List<WorkflowNode> nodes;
  final VoidCallback onClose;
  final ValueChanged<WorkflowNode> onUpdate;
  final ValueChanged<String> onDeleteConnection;

  const _NodeConfigPanel({
    required this.node,
    required this.connections,
    required this.nodes,
    required this.onClose,
    required this.onUpdate,
    required this.onDeleteConnection,
  });

  @override
  State<_NodeConfigPanel> createState() => _NodeConfigPanelState();
}

class _NodeConfigPanelState extends State<_NodeConfigPanel> {
  late TextEditingController labelController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.node.label);
  }

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final color = WorkflowNode.colorForType(widget.node.type);

    final outgoing = widget.connections
        .where((c) => c.fromNodeId == widget.node.id)
        .toList();
    final incoming = widget.connections
        .where((c) => c.toNodeId == widget.node.id)
        .toList();

    // FIX 1: SizedBox.expand() gives the Material full height so the inner
    //         Expanded child has a finite constraint to work against.
    // FIX 2: shadowColor must be fully opaque — semi-transparent Colors.black26
    //         triggers the material.dart:209 assertion on Flutter web.
    return SizedBox.expand(
      child: Material(
        elevation: 8,
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border(
                    bottom:
                        BorderSide(color: cs.outline.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  Icon(WorkflowNode.iconForType(widget.node.type),
                      color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Configure Node',
                        style: theme.textTheme.titleSmall),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: widget.onClose,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Label',
                        style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(
                        hintText: 'Node label',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
                      onChanged: (v) {
                        widget.node.label = v;
                        widget.onUpdate(widget.node);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Type',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(WorkflowNode.iconForType(widget.node.type),
                              color: color, size: 16),
                          const SizedBox(width: 8),
                          Text(widget.node.type.name,
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('ID',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(widget.node.id,
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: cs.onSurface.withOpacity(0.5))),
                    // ── Connections section ───────────────────────────────
                    if (outgoing.isNotEmpty || incoming.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Divider(color: cs.outline.withOpacity(0.2)),
                      const SizedBox(height: 8),
                      Text('Connections',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      if (outgoing.isNotEmpty) ...[
                        Text('Outgoing',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.5),
                                fontSize: 10)),
                        const SizedBox(height: 4),
                        ...outgoing.map((c) => _ConnectionRow(
                              connection: c,
                              nodes: widget.nodes,
                              isOutgoing: true,
                              onDelete: () =>
                                  widget.onDeleteConnection(c.id),
                            )),
                      ],
                      if (incoming.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Incoming',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.5),
                                fontSize: 10)),
                        const SizedBox(height: 4),
                        ...incoming.map((c) => _ConnectionRow(
                              connection: c,
                              nodes: widget.nodes,
                              isOutgoing: false,
                              onDelete: () =>
                                  widget.onDeleteConnection(c.id),
                            )),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Connection Row ─────────────────────────────────────────────────────────────

class _ConnectionRow extends StatelessWidget {
  final WorkflowConnection connection;
  final List<WorkflowNode> nodes;
  final bool isOutgoing;
  final VoidCallback onDelete;

  const _ConnectionRow({
    required this.connection,
    required this.nodes,
    required this.isOutgoing,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final otherId =
        isOutgoing ? connection.toNodeId : connection.fromNodeId;
    final other = nodes.cast<WorkflowNode?>().firstWhere(
        (n) => n?.id == otherId,
        orElse: () => null);
    final otherLabel = other?.label ?? otherId;

    final connColor = switch (connection.type) {
      ConnectionType.success => const Color(0xFF10B981),
      ConnectionType.failure => const Color(0xFFEF4444),
      ConnectionType.always => cs.primary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isOutgoing ? Icons.arrow_forward : Icons.arrow_back,
            size: 12,
            color: connColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              otherLabel,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (connection.label != null) ...[
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: connColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(connection.label!,
                  style: TextStyle(
                      fontSize: 9,
                      color: connColor,
                      fontWeight: FontWeight.w600)),
            ),
          ],
          const SizedBox(width: 4),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(Icons.close,
                  size: 13, color: cs.onSurface.withOpacity(0.4)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tutorial Section (used in help dialog) ────────────────────────────────────

class _TutorialSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _TutorialSection(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(body,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

class _ConnectionsPainter extends CustomPainter {
  final List<WorkflowNode> nodes;
  final List<WorkflowConnection> connections;
  final Color primaryColor;

  const _ConnectionsPainter({
    required this.nodes,
    required this.connections,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final conn in connections) {
      final from = nodes.cast<WorkflowNode?>().firstWhere(
          (n) => n?.id == conn.fromNodeId,
          orElse: () => null);
      final to = nodes.cast<WorkflowNode?>().firstWhere(
          (n) => n?.id == conn.toNodeId,
          orElse: () => null);
      if (from == null || to == null) continue;

      final color = switch (conn.type) {
        ConnectionType.success => const Color(0xFF10B981),
        ConnectionType.failure => const Color(0xFFEF4444),
        ConnectionType.always => primaryColor,
      };

      final paint = Paint()
        ..color = color.withOpacity(0.7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final start = Offset(from.position.dx + 160, from.position.dy + 40);
      final end = Offset(to.position.dx, to.position.dy + 40);
      final cp1 = Offset(start.dx + 60, start.dy);
      final cp2 = Offset(end.dx - 60, end.dy);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

      canvas.drawPath(path, paint);

      final arrowPaint = Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      const arrowSize = 8.0;
      final dx = end.dx - cp2.dx;
      final dy = end.dy - cp2.dy;
      final angle = math.atan2(dy, dx);
      final p1 = end +
          Offset(arrowSize * math.cos(angle + 2.5),
              arrowSize * math.sin(angle + 2.5));
      final p2 = end +
          Offset(arrowSize * math.cos(angle - 2.5),
              arrowSize * math.sin(angle - 2.5));
      canvas.drawPath(
          Path()
            ..moveTo(end.dx, end.dy)
            ..lineTo(p1.dx, p1.dy)
            ..lineTo(p2.dx, p2.dy)
            ..close(),
          arrowPaint);
    }
  }

  @override
  bool shouldRepaint(_ConnectionsPainter old) =>
      old.nodes != nodes || old.connections != connections;
}