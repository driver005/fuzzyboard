import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/app_provider.dart';
import '../../models/workflow.dart';
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
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    _workflow = app.workflows.firstWhere((w) => w.id == widget.workflowId);
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _save() {
    context.read<AppProvider>().updateWorkflow(_workflow);
    Navigator.of(context).pop();
  }

  void _addNode(NodeType type) {
    final node = WorkflowNode(
      id: _uuid.v4(),
      label: _labelForType(type),
      type: type,
      position: const Offset(300, 300),
    );
    setState(() => _workflow.nodes.add(node));
  }

  String _labelForType(NodeType type) => switch (type) {
        NodeType.trigger => 'New Trigger',
        NodeType.action => 'New Action',
        NodeType.condition => 'Condition',
        NodeType.delay => 'Delay',
        NodeType.script => 'Script',
        NodeType.end => 'End',
      };

  void _deleteNode(String id) {
    setState(() {
      _workflow.nodes.removeWhere((n) => n.id == id);
      _workflow.connections
          .removeWhere((c) => c.fromNodeId == id || c.toNodeId == id);
      if (_selectedNodeId == id) _selectedNodeId = null;
    });
  }

  void _onNodeTap(String id) {
    if (_connecting && _connectFromId != null && _connectFromId != id) {
      final conn = WorkflowConnection(
        id: _uuid.v4(),
        fromNodeId: _connectFromId!,
        toNodeId: id,
      );
      setState(() {
        _workflow.connections.add(conn);
        _connecting = false;
        _connectFromId = null;
      });
    } else {
      setState(() => _selectedNodeId = _selectedNodeId == id ? null : id);
    }
  }

  void _startConnect(String id) {
    setState(() {
      _connecting = true;
      _connectFromId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_workflow.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_connecting)
            Chip(
              label: const Text('Select target node'),
              backgroundColor: cs.primary.withOpacity(0.15),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() {
                _connecting = false;
                _connectFromId = null;
              }),
            ),
          const SizedBox(width: 8),
          AppButton(
            label: 'Save',
            icon: const Icon(Icons.save),
            size: AppButtonSize.sm,
            onPressed: _save,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          _NodePalette(onAdd: _addNode),
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
                // Connections
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConnectionsPainter(
                      nodes: _workflow.nodes,
                      connections: _workflow.connections,
                      primaryColor: cs.primary,
                    ),
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
                      children: _workflow.nodes.map((node) {
                        return Positioned(
                          left: node.position.dx,
                          top: node.position.dy,
                          child: _NodeWidget(
                            node: node,
                            isSelected: _selectedNodeId == node.id,
                            isConnectSource: _connectFromId == node.id,
                            onTap: () => _onNodeTap(node.id),
                            onDrag: (delta) {
                              setState(() {
                                node.position = Offset(
                                  node.position.dx + delta.dx,
                                  node.position.dy + delta.dy,
                                );
                              });
                            },
                            onConnect: () => _startConnect(node.id),
                            onDelete: () => _deleteNode(node.id),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Selected node config panel
                if (_selectedNodeId != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 260,
                    child: _NodeConfigPanel(
                      node: _workflow.nodes
                          .firstWhere((n) => n.id == _selectedNodeId),
                      onClose: () =>
                          setState(() => _selectedNodeId = null),
                      onUpdate: (n) => setState(() {}),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final color = WorkflowNode.colorForType(type);
    return Tooltip(
      message: type.name,
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
  final VoidCallback onTap;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onConnect;
  final VoidCallback onDelete;

  const _NodeWidget({
    required this.node,
    required this.isSelected,
    required this.isConnectSource,
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

    return GestureDetector(
      onTap: onTap,
      onPanUpdate: (details) => onDrag(details.delta),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected || isConnectSource
                ? color
                : color.withOpacity(0.3),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: isSelected ? 3 : 0,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NodeAction(
                      icon: Icons.link,
                      color: color,
                      tooltip: 'Connect',
                      onTap: onConnect),
                  _NodeAction(
                      icon: Icons.delete_outline,
                      color: Colors.red.shade400,
                      tooltip: 'Delete',
                      onTap: onDelete),
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
  final VoidCallback onClose;
  final ValueChanged<WorkflowNode> onUpdate;

  const _NodeConfigPanel({
    required this.node,
    required this.onClose,
    required this.onUpdate,
  });

  @override
  State<_NodeConfigPanel> createState() => _NodeConfigPanelState();
}

class _NodeConfigPanelState extends State<_NodeConfigPanel> {
  late TextEditingController _label;

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(text: widget.node.label);
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final color = WorkflowNode.colorForType(widget.node.type);

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
                      controller: _label,
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