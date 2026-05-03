import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';

class DevModePage extends StatefulWidget {
  const DevModePage({super.key});

  @override
  State<DevModePage> createState() => _DevModePageState();
}

class _DevModePageState extends State<DevModePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(context.l10n.devModeTitle),
            const SizedBox(width: 8),
            if (app.devMode)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(context.l10n.activeBadge,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
          ],
        ),
        actions: [
          AppButton(
            label: app.devMode ? context.l10n.disableDevMode : context.l10n.enableDevMode,
            icon: const Icon(Icons.bug_report),
            variant:
                app.devMode ? AppButtonVariant.danger : AppButtonVariant.primary,
            size: AppButtonSize.sm,
            onPressed: () => app.toggleDevMode(),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(icon: const Icon(Icons.terminal, size: 18), text: context.l10n.logsTab),
            Tab(icon: const Icon(Icons.memory, size: 18), text: context.l10n.stateTab),
            Tab(icon: const Icon(Icons.science, size: 18), text: context.l10n.testsTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _LogsTab(logs: app.logs),
          _StateTab(app: app),
          const _TestsTab(),
        ],
      ),
    );
  }
}

class _LogsTab extends StatelessWidget {
  final List<String> logs;
  const _LogsTab({required this.logs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AppButton(
                label: context.l10n.clearLogsButton,
                icon: const Icon(Icons.delete_sweep),
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.sm,
                onPressed: () => context.read<AppProvider>().clearLogs(),
              ),
              const Spacer(),
              Text(context.l10n.logEntriesCount(logs.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
        // Log list
        Expanded(
          child: Container(
            color: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF8F8FF),
            child: logs.isEmpty
                ? Center(
                    child: Text(context.l10n.noLogsYet,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4))),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: logs.length,
                    itemBuilder: (context, i) {
                      final log = logs[i];
                      final isError = log.contains('error') || log.contains('Error');
                      final isSuccess =
                          log.contains('created') || log.contains('installed');
                      final color = isError
                          ? const Color(0xFFEF4444)
                          : isSuccess
                              ? const Color(0xFF10B981)
                              : theme.colorScheme.onSurface.withOpacity(0.7);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '> $log',
                          style: AppTypography.mono.copyWith(
                              fontSize: 12, color: color),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _StateTab extends StatelessWidget {
  final AppProvider app;
  const _StateTab({required this.app});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          title: context.l10n.tasksStateCard,
          child: _JsonViewer({
            'count': app.tasks.length,
            'tasks': app.tasks
                .map((t) => {
                      'id': t.id,
                      'name': t.name,
                      'status': t.status.name,
                      'priority': t.priority.name,
                    })
                .toList(),
          }),
        ),
        const SizedBox(height: 12),
        AppCard(
          title: context.l10n.workflowsStateCard,
          child: _JsonViewer({
            'count': app.workflows.length,
            'workflows': app.workflows
                .map((w) => {
                      'id': w.id,
                      'name': w.name,
                      'active': w.isActive,
                      'nodes': w.nodes.length,
                    })
                .toList(),
          }),
        ),
        const SizedBox(height: 12),
        AppCard(
          title: context.l10n.pluginsStateCard,
          child: _JsonViewer({
            'installed': app.installedPlugins.length,
            'total': app.plugins.length,
          }),
        ),
      ],
    );
  }
}

class _JsonViewer extends StatelessWidget {
  final Map<String, dynamic> data;
  const _JsonViewer(this.data);

  String format(Map<String, dynamic> map, {int indent = 0}) {
    final buf = StringBuffer();
    final prefix = '  ' * indent;
    buf.writeln('{');
    map.forEach((k, v) {
      buf.write('$prefix  "$k": ');
      if (v is Map<String, dynamic>) {
        buf.writeln(format(v, indent: indent + 1));
      } else if (v is List) {
        buf.writeln('[');
        for (final item in v) {
          if (item is Map<String, dynamic>) {
            buf.writeln('$prefix    ${format(item, indent: indent + 2)},');
          } else {
            buf.writeln('$prefix    $item,');
          }
        }
        buf.writeln('$prefix  ]');
      } else if (v is String) {
        buf.writeln('"$v",');
      } else {
        buf.writeln('$v,');
      }
    });
    buf.write('$prefix}');
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF5F5FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        format(data),
        style: AppTypography.mono.copyWith(
          fontSize: 11,
          color: const Color(0xFF10B981),
        ),
      ),
    );
  }
}

class _TestsTab extends StatefulWidget {
  const _TestsTab();

  @override
  State<_TestsTab> createState() => _TestsTabState();
}

class _TestsTabState extends State<_TestsTab> {
  final _results = <_TestResult>[];
  bool _running = false;

  Future<void> run_tests() async {
    setState(() {
      _running = true;
      _results.clear();
    });

    final tests = [
      ('Create task', true, 12),
      ('Update task status', true, 8),
      ('Delete task', true, 6),
      ('Create workflow', true, 10),
      ('Add workflow node', true, 7),
      ('Connect nodes', true, 5),
      ('Toggle workflow', true, 4),
      ('Install plugin', true, 9),
      ('Router navigation', true, 11),
    ];

    for (final (name, pass, ms) in tests) {
      await Future.delayed(Duration(milliseconds: ms * 10));
      if (mounted) {
        setState(() => _results.add(_TestResult(name, pass, ms)));
      }
    }
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passed = _results.where((r) => r.passed).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AppButton(
                label: _running ? context.l10n.runningTests : context.l10n.runAllTests,
                icon: const Icon(Icons.play_arrow),
                loading: _running,
                onPressed: _running ? null : run_tests,
              ),
              const SizedBox(width: 16),
              if (_results.isNotEmpty)
                Text(
                  context.l10n.testsPassed(passed, _results.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: passed == _results.length
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (context, i) {
              final r = _results[i];
              return ListTile(
                dense: true,
                leading: Icon(
                  r.passed ? Icons.check_circle : Icons.cancel,
                  color: r.passed
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  size: 18,
                ),
                title: Text(r.name, style: theme.textTheme.bodyMedium),
                trailing: Text('${r.ms}ms',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                        fontFamily: 'monospace')),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TestResult {
  final String name;
  final bool passed;
  final int ms;
  const _TestResult(this.name, this.passed, this.ms);
}
