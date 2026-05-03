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
  late Workflow workflow;
  String? selectedNodeId;
  bool connecting = false;
  String? connectFromId;
  final TransformationController transform = TransformationController();
  final FocusNode keyboardFocus = FocusNode();
  final uuid = const Uuid();
  final List<Map<String, dynamic>> undoStack = [];
  final List<Map<String, dynamic>> redoStack = [];

  // Position where the next node will be placed (canvas coordinates).
  Offset pendingNodePosition = const Offset(400, 300);
  // Tracks pointer-down position so we can distinguish a tap from a pan.
  Offset pointerDownPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    workflow = app.workflows.firstWhere((w) => w.id == widget.workflowId);
  }

  @override
  void dispose() {
    transform.dispose();
    keyboardFocus.dispose();
    super.dispose();
  }

  void save() {
    context.read<AppProvider>().updateWorkflow(workflow);
    Navigator.of(context).pop();
  }

  void addNode(NodeType type) {
    final node = WorkflowNode(
      id: uuid.v4(),
      label: labelForType(type),
      type: type,
      position: pendingNodePosition,
    );
    pushUndo();
    setState(() => workflow.nodes.add(node));
  }

  /// Adds a node at [pendingNodePosition] and, if currently in connect mode,
  /// immediately creates a connection from the source node to the new node.
  void addNodeAndMaybeConnect(NodeType type) {
    final node = WorkflowNode(
      id: uuid.v4(),
      label: labelForType(type),
      type: type,
      position: pendingNodePosition,
    );
    pushUndo();
    setState(() {
      workflow.nodes.add(node);
      if (connecting && connectFromId != null) {
        workflow.connections.add(WorkflowConnection(
          id: uuid.v4(),
          fromNodeId: connectFromId!,
          toNodeId: node.id,
        ));
        connecting = false;
        connectFromId = null;
      }
    });
  }

  /// Shows the Quick Menu overlay, optionally anchored to a screen position.
  /// When [canvasPosition] is provided it is stored as [pendingNodePosition]
  /// so newly added nodes land at the tapped spot on the canvas.
  void showQuickMenu({Offset? screenPosition, Offset? canvasPosition}) {
    final size = MediaQuery.of(context).size;
    if (canvasPosition != null) {
      pendingNodePosition = canvasPosition;
    } else {
      // Default: place node near the current viewport centre.
      pendingNodePosition = transform.toScene(Offset(size.width / 2, size.height / 2));
    }
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'quick-menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (ctx, _, __) => _QuickMenuOverlay(
        screenPosition: screenPosition,
        screenSize: size,
        onSelect: (type) {
          Navigator.of(ctx).pop();
          addNodeAndMaybeConnect(type);
        },
      ),
      transitionBuilder: (ctx, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  String labelForType(NodeType type) => switch (type) {
        NodeType.trigger => 'New Trigger',
        NodeType.action => 'New Action',
        NodeType.condition => 'Condition',
        NodeType.delay => 'Delay',
        NodeType.script => 'Script',
        NodeType.end => 'End',
      };

  void deleteNode(String id) {
    pushUndo();
    setState(() {
      workflow.nodes.removeWhere((n) => n.id == id);
      workflow.connections
          .removeWhere((c) => c.fromNodeId == id || c.toNodeId == id);
      if (selectedNodeId == id) selectedNodeId = null;
    });
  }

  void onNodeTap(String id) {
    if (connecting && connectFromId != null && connectFromId != id) {
      final conn = WorkflowConnection(
        id: uuid.v4(),
        fromNodeId: connectFromId!,
        toNodeId: id,
      );
      pushUndo();
      setState(() {
        workflow.connections.add(conn);
        connecting = false;
        connectFromId = null;
      });
    } else {
      setState(() => selectedNodeId = selectedNodeId == id ? null : id);
    }
  }

  void startConnect(String id) {
    setState(() {
      connecting = true;
      connectFromId = id;
    });
  }

  Map<String, dynamic> captureSnapshot() {
    return {
      'nodes': workflow.nodes.map((n) => {
        'id': n.id, 'label': n.label, 'type': n.type.name,
        'x': n.position.dx, 'y': n.position.dy, 'config': Map.from(n.config),
      }).toList(),
      'connections': workflow.connections.map((c) => {
        'id': c.id, 'from': c.fromNodeId, 'to': c.toNodeId,
        'type': c.type.name, 'label': c.label,
      }).toList(),
    };
  }

  void pushUndo() {
    undoStack.add(captureSnapshot());
    if (undoStack.length > 30) undoStack.removeAt(0);
    redoStack.clear();
  }

  void applySnapshot(Map<String, dynamic> snapshot) {
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
      workflow.nodes..clear()..addAll(nodes);
      workflow.connections..clear()..addAll(connections);
    });
  }

  void undo() {
    if (undoStack.isEmpty) return;
    redoStack.add(captureSnapshot());
    applySnapshot(undoStack.removeLast());
  }

  void redo() {
    if (redoStack.isEmpty) return;
    undoStack.add(captureSnapshot());
    applySnapshot(redoStack.removeLast());
  }

  void deleteConnection(String id) {
    pushUndo();
    setState(() => workflow.connections.removeWhere((c) => c.id == id));
  }

  void cancelConnect() {
    setState(() {
      connecting = false;
      connectFromId = null;
    });
  }

  void showTutorial() {
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
                      'Press Ctrl+Space (or ⌘+Space on Mac) to open the Quick Menu. Search for a node type and click to place it. You can also use the "Add Node" button in the toolbar.',
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
                      'Click the 🔗 icon on a node to enter connect mode, then click a target node to draw an arrow. If you click empty canvas space, the Quick Menu opens so you can add a new node and auto-connect it in one step. Press ESC or tap the × chip to cancel.',
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
  Future<void> exportJson() async {
    final data = {
      'id': workflow.id,
      'name': workflow.name,
      'description': workflow.description,
      'nodes': workflow.nodes.map((n) => {
        'id': n.id,
        'label': n.label,
        'type': n.type.name,
        'x': n.position.dx,
        'y': n.position.dy,
        'config': n.config,
      }).toList(),
      'connections': workflow.connections.map((c) => {
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
  void showImportDialog() {
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
                  workflow.nodes
                    ..clear()
                    ..addAll(nodes);
                  workflow.connections
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
      focusNode: keyboardFocus,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape && connecting) {
            cancelConnect();
          } else if (event.logicalKey == LogicalKeyboardKey.space &&
              (HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isMetaPressed)) {
            showQuickMenu();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(workflow.name),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (connecting)
              Chip(
                avatar: const Icon(Icons.link, size: 16),
                label: const Text('Click target node — ESC to cancel'),
                backgroundColor: cs.primary.withOpacity(0.15),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: cancelConnect,
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: undoStack.isEmpty ? null : undo,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: 'Redo',
              onPressed: redoStack.isEmpty ? null : redo,
            ),
            const SizedBox(width: 8),
            AppButton(
              label: context.l10n.canvasExportButton,
              icon: const Icon(Icons.upload_outlined),
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              onPressed: exportJson,
            ),
            const SizedBox(width: 8),
            AppButton(
              label: context.l10n.importButton,
              icon: const Icon(Icons.download_outlined),
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              onPressed: showImportDialog,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'How to use',
              onPressed: showTutorial,
            ),
            const SizedBox(width: 8),
            AppButton(
              label: 'Add Node',
              icon: const Icon(Icons.add_circle_outline),
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              onPressed: showQuickMenu,
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
        body: Stack(
          children: [
            // ── Infinite grid (screen-space) ───────────────────────────────
            // The grid is rendered OUTSIDE the InteractiveViewer so its painter
            // is always sized to the full viewport.  An AnimatedBuilder on the
            // TransformationController keeps the grid lines aligned with the
            // current pan/zoom, giving the visual illusion of an infinite grid.
            AnimatedBuilder(
              animation: transform,
              builder: (ctx, _) => CustomPaint(
                painter: _InfiniteGridPainter(
                  transform: transform.value,
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.04),
                ),
                child: Container(
                  color: isDark
                      ? const Color(0xFF0F0F1A)
                      : const Color(0xFFF8F9FF),
                ),
              ),
            ),
            // ── Interactive canvas ─────────────────────────────────────────
            // Wrapped in a Listener so we can detect taps on empty canvas
            // space while still letting InteractiveViewer handle pan / zoom.
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (e) => pointerDownPos = e.localPosition,
              onPointerUp: (e) {
                final moved = (e.localPosition - pointerDownPos).distance > 10;
                if (!moved && connecting) {
                  // Convert viewport coordinates to canvas (scene) coordinates.
                  final canvasPos = transform.toScene(e.localPosition);
                  final hitNode = workflow.nodes.any((n) =>
                      Rect.fromLTWH(n.position.dx, n.position.dy, 160, 100)
                          .contains(canvasPos));
                  if (!hitNode) {
                    showQuickMenu(
                      screenPosition: e.position,
                      canvasPosition: canvasPos,
                    );
                  }
                }
              },
              child: InteractiveViewer(
                transformationController: transform,
                // Unlimited panning in all directions.
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.1,
                maxScale: 4.0,
                // clipBehavior:none lets nodes render outside the SizedBox
                // boundary when the user pans to the edge.
                clipBehavior: Clip.none,
                child: SizedBox(
                  // Large but finite so InteractiveViewer has a reference
                  // size for its internal coordinate maths.  The infinite
                  // boundaryMargin means users can pan past these edges.
                  width: 100000,
                  height: 100000,
                  child: Stack(
                    children: [
                      // Connections painted inside the viewer so they
                      // pan/zoom together with the nodes.
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ConnectionsPainter(
                            nodes: workflow.nodes,
                            connections: workflow.connections,
                            primaryColor: cs.primary,
                          ),
                        ),
                      ),
                      ...workflow.nodes.map((node) {
                        return Positioned(
                          left: node.position.dx,
                          top: node.position.dy,
                          child: _NodeWidget(
                            node: node,
                            isSelected: selectedNodeId == node.id,
                            isConnectSource: connectFromId == node.id,
                            isConnecting: connecting,
                            onTap: () => onNodeTap(node.id),
                            onDrag: (delta) {
                              setState(() {
                                node.position = Offset(
                                  node.position.dx + delta.dx,
                                  node.position.dy + delta.dy,
                                );
                              });
                            },
                            onConnect: () => startConnect(node.id),
                            onDelete: () => deleteNode(node.id),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            // Connect-mode overlay hint
            if (connecting)
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
                            'Click a node to connect — or click empty space to add & connect — ESC to cancel',
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
            if (selectedNodeId != null)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 280,
                child: _NodeConfigPanel(
                  node: workflow.nodes
                      .firstWhere((n) => n.id == selectedNodeId),
                  connections: workflow.connections,
                  nodes: workflow.nodes,
                  onClose: () =>
                      setState(() => selectedNodeId = null),
                  onUpdate: (n) => setState(() {}),
                  onDeleteConnection: deleteConnection,
                ),
              ),
          ],
        ),
      ),  // Scaffold
    );  // KeyboardListener
  }  // build
}  // _WorkflowCanvasState

// ── Quick Menu Overlay ────────────────────────────────────────────────────────

/// Searchable floating menu for adding nodes to the canvas.
/// Displayed via [showGeneralDialog] so it floats over the canvas.
class _QuickMenuOverlay extends StatefulWidget {
  final Offset? screenPosition;
  final Size screenSize;
  final void Function(NodeType) onSelect;

  const _QuickMenuOverlay({
    required this.screenPosition,
    required this.screenSize,
    required this.onSelect,
  });

  @override
  State<_QuickMenuOverlay> createState() => _QuickMenuOverlayState();
}

class _QuickMenuOverlayState extends State<_QuickMenuOverlay> {
  final searchController = TextEditingController();
  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  static String _descriptionForType(NodeType t) => switch (t) {
        NodeType.trigger => 'Starts the workflow (e.g. on event)',
        NodeType.action => 'Runs an action (e.g. send email)',
        NodeType.condition => 'Branch on true/false',
        NodeType.delay => 'Wait a specified time',
        NodeType.script => 'Run a Lua/SQL script',
        NodeType.end => 'Marks the workflow end',
      };

  List<NodeType> get filtered {
    if (query.isEmpty) return NodeType.values;
    final q = query.toLowerCase();
    return NodeType.values
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            _descriptionForType(t).toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const menuWidth = 260.0;
    const menuMaxHeight = 360.0;

    // Anchor the menu near the tap point, clamped to remain on screen.
    final sp = widget.screenPosition;
    double left = (sp != null ? sp.dx : widget.screenSize.width / 2) - menuWidth / 2;
    double top = (sp != null ? sp.dy : widget.screenSize.height / 2) - 20;
    left = left.clamp(8.0, widget.screenSize.width - menuWidth - 8);
    top = top.clamp(8.0, widget.screenSize.height - menuMaxHeight - 8);

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: menuWidth,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(12),
            color: cs.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline,
                          size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('Add Node',
                          style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('Ctrl+Space',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.4),
                              fontFamily: 'monospace')),
                    ],
                  ),
                ),
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search nodes…',
                      prefixIcon:
                          const Icon(Icons.search, size: 16),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(height: 1),
                // Node list
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: menuMaxHeight - 110),
                  child: filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('No nodes match',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      cs.onSurface.withOpacity(0.5))),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          children: filtered.map((type) {
                            final color =
                                WorkflowNode.colorForType(type);
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                  WorkflowNode.iconForType(type),
                                  color: color,
                                  size: 18),
                              title: Text(type.name,
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              subtitle: Text(
                                  _descriptionForType(type),
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 10)),
                              onTap: () => widget.onSelect(type),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
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

/// Screen-space infinite grid painter.
///
/// Rendered OUTSIDE the [InteractiveViewer] so it always fills the viewport.
/// The [transform] matrix from [TransformationController.value] is used to
/// align grid lines with the canvas coordinate system, so the grid visually
/// scrolls and scales together with the canvas content — creating the
/// appearance of a truly infinite grid.
class _InfiniteGridPainter extends CustomPainter {
  final Matrix4 transform;
  final Color color;

  const _InfiniteGridPainter({required this.transform, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const step = 30.0;

    // Extract scale and translation from the 4×4 matrix.
    // Column-major order: entry(0,0) = scaleX, entry(1,1) = scaleY,
    // entry(0,3) = tx, entry(1,3) = ty.
    final scaleX = transform.entry(0, 0);
    final tx = transform.entry(0, 3);
    final ty = transform.entry(1, 3);

    final scaledStep = step * scaleX;
    // Wrap the offsets so lines tile across the whole viewport.
    final startX = tx % scaledStep;
    final startY = ty % scaledStep;

    // Vertical lines
    for (double x = startX - scaledStep;
        x < size.width + scaledStep;
        x += scaledStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (double y = startY - scaledStep;
        y < size.height + scaledStep;
        y += scaledStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_InfiniteGridPainter old) {
    if (old.color != color) return true;
    // Only repaint when scale (0,0) or translation (0,3)/(1,3) changes.
    return old.transform.entry(0, 0) != transform.entry(0, 0) ||
        old.transform.entry(0, 3) != transform.entry(0, 3) ||
        old.transform.entry(1, 3) != transform.entry(1, 3);
  }
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