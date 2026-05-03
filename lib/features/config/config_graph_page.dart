import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../models/worker.dart';
import '../../models/plugin.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_input.dart';

/// Standalone widget version of the config graph (no Scaffold).
/// Node selection opens a modal dialog instead of a side panel.
/// Use this to embed the graph in other pages (e.g. PluginsPage).
class ConfigGraphWidget extends StatefulWidget {
  const ConfigGraphWidget({super.key});

  @override
  State<ConfigGraphWidget> createState() => _ConfigGraphWidgetState();
}

class _ConfigGraphWidgetState extends State<ConfigGraphWidget> {
  @override
  Widget build(BuildContext context) {
    return _GraphPanel(
      selectedId: null,
      onNodeSelected: (id) {
        if (id == null) return;
        showDialog(
          context: context,
          builder: (_) => _NodeDetailModal(nodeId: id),
        );
      },
    );
  }
}

/// Modal wrapper around the existing detail panels.
class _NodeDetailModal extends StatelessWidget {
  final String nodeId;
  const _NodeDetailModal({required this.nodeId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 420,
          constraints: const BoxConstraints(maxHeight: 600),
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: cs.outline.withOpacity(0.15))),
                ),
                child: Row(
                  children: [
                    Text('Node Config', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _DetailPanel(selectedId: nodeId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfigGraphPage extends StatefulWidget {
  const ConfigGraphPage({super.key});

  @override
  State<ConfigGraphPage> createState() => _ConfigGraphPageState();
}

class _ConfigGraphPageState extends State<ConfigGraphPage> {
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.configTitle),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF16162A) : Colors.white,
        foregroundColor: cs.onSurface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outline.withOpacity(0.15)),
        ),
      ),
      body: _GraphPanel(
        selectedId: selectedId,
        onNodeSelected: (id) {
          if (id == null) {
            setState(() => selectedId = null);
            return;
          }
          setState(() => selectedId = id);
          showDialog(
            context: context,
            builder: (_) => _NodeDetailModal(nodeId: id),
          ).then((_) => setState(() => selectedId = null));
        },
      ),
    );
  }
}

// ── Graph Panel ────────────────────────────────────────────────────────────────

class _GraphPanel extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onNodeSelected;

  const _GraphPanel({required this.selectedId, required this.onNodeSelected});

  static const double canvasSize = 800;
  static const Offset center = Offset(canvasSize / 2, canvasSize / 2);
  static const double workerRadius = 160;
  static const double pluginRadius = 280;
  static const double nodeW = 88;
  static const double nodeH = 40;
  static const double appNodeR = 38;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final workers = provider.workers;
    final plugins = provider.plugins;
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    final workerPositions = <String, Offset>{};
    for (int i = 0; i < workers.length; i++) {
      final angle = (2 * math.pi * i / workers.length) - math.pi / 2;
      workerPositions[workers[i].id] = Offset(
        center.dx + workerRadius * math.cos(angle),
        center.dy + workerRadius * math.sin(angle),
      );
    }

    final pluginPositions = <String, Offset>{};
    for (int i = 0; i < plugins.length; i++) {
      final angle = (2 * math.pi * i / plugins.length) - math.pi / 2;
      pluginPositions[plugins[i].id] = Offset(
        center.dx + pluginRadius * math.cos(angle),
        center.dy + pluginRadius * math.sin(angle),
      );
    }

    final allPositions = [
      ...workerPositions.values,
      ...pluginPositions.values,
    ];

    return Container(
      color: isDark ? const Color(0xFF13131F) : const Color(0xFFF9FAFB),
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(80),
        minScale: 0.3,
        maxScale: 2.5,
        child: SizedBox(
          width: canvasSize,
          height: canvasSize,
          child: Stack(
            children: [
              // Connection lines
              CustomPaint(
                size: const Size(canvasSize, canvasSize),
                painter: _ConnectionPainter(
                  center: center,
                  positions: allPositions,
                  lineColor: cs.outline.withOpacity(0.25),
                ),
              ),
              // Plugin nodes
              for (final plugin in plugins)
                buildPluginNode(
                  context,
                  plugin,
                  pluginPositions[plugin.id]!,
                  selectedId == plugin.id,
                  () => onNodeSelected(plugin.id),
                ),
              // Worker nodes
              for (final worker in workers)
                buildWorkerNode(
                  context,
                  worker,
                  workerPositions[worker.id]!,
                  selectedId == worker.id,
                  () => onNodeSelected(worker.id),
                ),
              // App node (center)
              buildAppNode(context, center, selectedId == 'app', () => onNodeSelected('app')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppNode(
    BuildContext context,
    Offset pos,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      left: pos.dx - appNodeR,
      top: pos.dy - appNodeR,
      width: appNodeR * 2,
      height: appNodeR * 2,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [cs.primary, cs.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(isSelected ? 0.5 : 0.25),
                blurRadius: isSelected ? 20 : 10,
                spreadRadius: isSelected ? 3 : 0,
              ),
            ],
            border: isSelected
                ? Border.all(color: Colors.white, width: 2.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.blur_on, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(
                context.l10n.configAppNode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWorkerNode(
    BuildContext context,
    Worker worker,
    Offset pos,
    bool isSelected,
    VoidCallback onTap,
  ) {
    const color = Color(0xFF3B82F6);

    return Positioned(
      left: pos.dx - nodeW / 2,
      top: pos.dy - nodeH / 2,
      width: nodeW,
      height: nodeH,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isSelected ? 0.45 : 0.2),
                blurRadius: isSelected ? 16 : 6,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                worker.status == WorkerStatus.running
                    ? Icons.play_circle_outline
                    : Icons.stop_circle_outlined,
                color: Colors.white70,
                size: 12,
              ),
              Text(
                worker.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPluginNode(
    BuildContext context,
    Plugin plugin,
    Offset pos,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final color = plugin.isInstalled
        ? const Color(0xFF10B981)
        : const Color(0xFF6B7280);

    return Positioned(
      left: pos.dx - nodeW / 2,
      top: pos.dy - nodeH / 2,
      width: nodeW,
      height: nodeH,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isSelected ? 0.45 : 0.2),
                blurRadius: isSelected ? 16 : 6,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (plugin.iconEmoji != null)
                Text(plugin.iconEmoji!, style: const TextStyle(fontSize: 10)),
              Text(
                plugin.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Connection Painter ─────────────────────────────────────────────────────────

class _ConnectionPainter extends CustomPainter {
  final Offset center;
  final List<Offset> positions;
  final Color lineColor;

  const _ConnectionPainter({
    required this.center,
    required this.positions,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final pos in positions) {
      canvas.drawLine(center, pos, paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectionPainter old) =>
      old.center != center ||
      old.positions.length != positions.length ||
      old.lineColor != lineColor ||
      !positionsEqual(old.positions, positions);

  bool positionsEqual(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ── Detail Panel ───────────────────────────────────────────────────────────────

class _DetailPanel extends StatelessWidget {
  final String? selectedId;

  const _DetailPanel({super.key, required this.selectedId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    if (selectedId == null) {
      return Container(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, size: 40, color: cs.onSurface.withOpacity(0.25)),
              const SizedBox(height: 12),
              Text(
                context.l10n.configSelectNode,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.4),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.configSelectNodeHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.3),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (selectedId == 'app') {
      return const _AppConfigPanel(key: ValueKey('app-config'));
    }

    final provider = context.read<AppProvider>();

    final workerIdx = provider.workers.indexWhere((w) => w.id == selectedId);
    if (workerIdx != -1) {
      return _WorkerConfigPanel(worker: provider.workers[workerIdx]);
    }

    final pluginIdx = provider.plugins.indexWhere((p) => p.id == selectedId);
    if (pluginIdx != -1) {
      return _PluginInfoPanel(plugin: provider.plugins[pluginIdx]);
    }

    return const SizedBox.shrink();
  }
}

// ── App Config Panel ───────────────────────────────────────────────────────────

class _AppConfigPanel extends StatefulWidget {
  const _AppConfigPanel({super.key});

  @override
  State<_AppConfigPanel> createState() => _AppConfigPanelState();
}

class _AppConfigPanelState extends State<_AppConfigPanel> {
  static const int defaultMaxConcurrency = 10;

  late TextEditingController maxConcurrencyCtrl;
  late TextEditingController apiBaseUrlCtrl;
  late TextEditingController timezoneCtrl;
  String logLevel = 'info';

  @override
  void initState() {
    super.initState();
    final config = context.read<AppProvider>().appConfig;
    maxConcurrencyCtrl = TextEditingController(
        text: config['maxConcurrency']?.toString() ?? '$defaultMaxConcurrency');
    apiBaseUrlCtrl =
        TextEditingController(text: config['apiBaseUrl']?.toString() ?? '');
    timezoneCtrl =
        TextEditingController(text: config['timezone']?.toString() ?? 'UTC');
    logLevel = config['logLevel']?.toString() ?? 'info';
  }

  @override
  void dispose() {
    maxConcurrencyCtrl.dispose();
    apiBaseUrlCtrl.dispose();
    timezoneCtrl.dispose();
    super.dispose();
  }

  void save() {
    final provider = context.read<AppProvider>();
    provider.updateAppConfig(
        'maxConcurrency', int.tryParse(maxConcurrencyCtrl.text) ?? defaultMaxConcurrency);
    provider.updateAppConfig('logLevel', logLevel);
    provider.updateAppConfig('apiBaseUrl', apiBaseUrlCtrl.text);
    provider.updateAppConfig('timezone', timezoneCtrl.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(context.l10n.configAppSaved), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelHeader(
              icon: Icons.blur_on,
              iconColor: cs.primary,
              title: context.l10n.configAppConfiguration,
              subtitle: context.l10n.configGlobalSettings,
            ),
            const SizedBox(height: 20),
            AppInput(
              label: context.l10n.configMaxConcurrency,
              controller: maxConcurrencyCtrl,
              keyboardType: TextInputType.number,
              hint: context.l10n.configMaxConcurrencyHint,
            ),
            const SizedBox(height: 16),
            _LogLevelDropdown(
              value: logLevel,
              onChanged: (v) => setState(() => logLevel = v ?? logLevel),
            ),
            const SizedBox(height: 16),
            AppInput(
              label: context.l10n.configApiBaseUrl,
              controller: apiBaseUrlCtrl,
              hint: 'https://api.example.com',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: context.l10n.configTimezone,
              controller: timezoneCtrl,
              hint: context.l10n.configTimezoneHint,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: context.l10n.configSaveChanges,
              fullWidth: true,
              onPressed: save,
              icon: const Icon(Icons.save_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogLevelDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _LogLevelDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.configLogLevel,
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(10),
              onChanged: onChanged,
              items: ['debug', 'info', 'warn', 'error']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Worker Config Panel ────────────────────────────────────────────────────────

class _WorkerConfigPanel extends StatefulWidget {
  final Worker worker;

  const _WorkerConfigPanel({required this.worker});

  @override
  State<_WorkerConfigPanel> createState() => _WorkerConfigPanelState();
}

class _WorkerConfigPanelState extends State<_WorkerConfigPanel> {
  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController concurrencyCtrl;
  late TextEditingController maxRetriesCtrl;
  late TextEditingController timeoutCtrl;
  late TextEditingController endpointCtrl;
  late WorkerStatus status;

  @override
  void initState() {
    super.initState();
    final w = widget.worker;
    nameCtrl = TextEditingController(text: w.name);
    descCtrl = TextEditingController(text: w.description);
    concurrencyCtrl = TextEditingController(text: w.concurrency.toString());
    maxRetriesCtrl = TextEditingController(text: w.maxRetries.toString());
    timeoutCtrl = TextEditingController(text: w.timeoutSeconds.toString());
    endpointCtrl = TextEditingController(text: w.endpoint ?? '');
    status = w.status;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    concurrencyCtrl.dispose();
    maxRetriesCtrl.dispose();
    timeoutCtrl.dispose();
    endpointCtrl.dispose();
    super.dispose();
  }

  void save() {
    final updated = Worker(
      id: widget.worker.id,
      name: nameCtrl.text,
      description: descCtrl.text,
      type: widget.worker.type,
      status: status,
      concurrency: int.tryParse(concurrencyCtrl.text) ?? 1,
      maxRetries: int.tryParse(maxRetriesCtrl.text) ?? 3,
      timeoutSeconds: int.tryParse(timeoutCtrl.text) ?? 30,
      endpoint: endpointCtrl.text.isEmpty ? null : endpointCtrl.text,
      envVars: Map.from(widget.worker.envVars),
      lastRunAt: widget.worker.lastRunAt,
      runCount: widget.worker.runCount,
    );
    context.read<AppProvider>().updateWorker(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(context.l10n.configWorkerSaved), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final theme = Theme.of(context);

    final statusColor = switch (status) {
      WorkerStatus.running => const Color(0xFF10B981),
      WorkerStatus.stopped => const Color(0xFF6B7280),
      WorkerStatus.error => const Color(0xFFEF4444),
    };

    return Container(
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelHeader(
              icon: Icons.memory_outlined,
              iconColor: const Color(0xFF3B82F6),
              title: widget.worker.name,
              subtitle: widget.worker.type.label,
            ),
            const SizedBox(height: 16),
            // Status toggle row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: status == WorkerStatus.running,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (_) => setState(() {
                      status = status == WorkerStatus.running
                          ? WorkerStatus.stopped
                          : WorkerStatus.running;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppInput(label: context.l10n.configWorkerName, controller: nameCtrl),
            const SizedBox(height: 12),
            AppInput(label: context.l10n.descriptionLabel, controller: descCtrl, maxLines: 2),
            const SizedBox(height: 12),
            AppInput(
              label: context.l10n.configWorkerConcurrency,
              controller: concurrencyCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppInput(
              label: context.l10n.configWorkerMaxRetries,
              controller: maxRetriesCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppInput(
              label: context.l10n.configWorkerTimeout,
              controller: timeoutCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppInput(
              label: context.l10n.configWorkerEndpoint,
              controller: endpointCtrl,
              hint: 'https://...',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: context.l10n.saveButton,
                    onPressed: save,
                    icon: const Icon(Icons.save_outlined),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: status == WorkerStatus.running ? context.l10n.configWorkerStop : context.l10n.configWorkerStart,
                  variant: status == WorkerStatus.running
                      ? AppButtonVariant.danger
                      : AppButtonVariant.secondary,
                  onPressed: () {
                    context.read<AppProvider>().toggleWorker(widget.worker.id);
                    setState(() {
                      status = status == WorkerStatus.running
                          ? WorkerStatus.stopped
                          : WorkerStatus.running;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plugin Info Panel ──────────────────────────────────────────────────────────

class _PluginInfoPanel extends StatelessWidget {
  final Plugin plugin;

  const _PluginInfoPanel({required this.plugin});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final theme = Theme.of(context);

    final statusColor =
        plugin.isInstalled ? const Color(0xFF10B981) : const Color(0xFF6B7280);

    return Container(
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelHeader(
              icon: Icons.extension_outlined,
              iconColor: plugin.category.color,
              title: plugin.name,
              subtitle: plugin.category.label,
            ),
            const SizedBox(height: 16),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: statusColor),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    plugin.isInstalled ? context.l10n.installedBadge : context.l10n.configPluginNotInstalled,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              plugin.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: context.l10n.configPluginAuthor, value: plugin.author),
            const SizedBox(height: 8),
            _InfoRow(label: context.l10n.versionLabel, value: 'v${plugin.version}'),
            if (plugin.rating != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                  label: context.l10n.configPluginRating, value: '⭐ ${plugin.rating!.toStringAsFixed(1)}'),
            ],
            if (plugin.downloadCount != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                  label: context.l10n.configPluginDownloads,
                  value: context.l10n.configPluginDownloadsValue(plugin.downloadCount!.toString())),
            ],
            if (plugin.configSchema.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Configuration',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...plugin.configSchema.map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: cs.outline.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(field.label,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600)),
                                if (field.description != null)
                                  Text(field.description!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                          color: cs.onSurface.withOpacity(0.5))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.outline.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(field.type.name,
                                style: TextStyle(
                                    fontSize: 9,
                                    color: cs.onSurface.withOpacity(0.5),
                                    fontFamily: 'monospace')),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
            if (plugin.readme != null) ...[
              const SizedBox(height: 20),
              Text('README',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.outline.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outline.withOpacity(0.12)),
                ),
                child: Text(plugin.readme!,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.7))),
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: plugin.isInstalled ? context.l10n.configPluginUninstall : context.l10n.installButton,
              variant:
                  plugin.isInstalled ? AppButtonVariant.danger : AppButtonVariant.primary,
              fullWidth: true,
              icon: Icon(
                plugin.isInstalled ? Icons.delete_outline : Icons.download_outlined,
              ),
              onPressed: () {
                final provider = context.read<AppProvider>();
                if (plugin.isInstalled) {
                  provider.uninstallPlugin(plugin.id);
                } else {
                  provider.installPlugin(plugin.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _PanelHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.5)),
          ),
        ),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
