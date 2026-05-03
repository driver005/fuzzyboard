import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../models/task.dart';
import '../../models/workflow.dart';
import '../../shared/layout/responsive_layout.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/avatar_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final userProvider = context.watch<UserProvider>();
    final mobile = isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.dashboardTitle),
        actions: [
          AppButton(
            label: userProvider.isAdmin ? context.l10n.adminViewButton : context.l10n.userViewButton,
            icon: const Icon(Icons.switch_account),
            size: AppButtonSize.sm,
            variant: AppButtonVariant.outline,
            onPressed: () => userProvider.switchRole(
              userProvider.isAdmin ? UserRole.user : UserRole.admin,
            ),
          ),
          const SizedBox(width: 8),
          if (mobile) const Padding(
            padding: EdgeInsets.only(right: 12),
            child: AvatarWidget(size: 40),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _WelcomeBanner(isAdmin: userProvider.isAdmin),
          const SizedBox(height: 20),
          // Stat cards
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 2,
            desktopColumns: 4,
            spacing: 12,
            runSpacing: 12,
            children: [
              StatCard(
                title: context.l10n.totalTasksCard,
                value: '${app.tasks.length}',
                change: context.l10n.todayChange,
                icon: Icons.task_alt,
                iconColor: const Color(0xFF6C63FF),
                onTap: () => context.go('/tasks'),
              ),
              StatCard(
                title: context.l10n.activeWorkflowsCard,
                value: '${app.workflows.where((w) => w.isActive).length}',
                change: 'of ${app.workflows.length} total',
                icon: Icons.account_tree,
                iconColor: const Color(0xFF10B981),
                onTap: () => context.go('/workflows'),
              ),
              StatCard(
                title: context.l10n.pluginsCard,
                value: '${app.installedPlugins.length}',
                change: context.l10n.installedLabel,
                icon: Icons.extension,
                iconColor: const Color(0xFF3B82F6),
                onTap: () => context.go('/plugins'),
              ),
              StatCard(
                title: context.l10n.runsTodayCard,
                value: '${app.workflows.fold(0, (s, w) => s + w.runCount)}',
                change: context.l10n.upChangePercent,
                icon: Icons.play_circle,
                iconColor: const Color(0xFFF59E0B),
                onTap: () => context.go('/workflows'),
              ),
            ].map((c) => c.animate().fadeIn(delay: 100.ms).slideY(begin: 0.2)).toList(),
          ),
          const SizedBox(height: 24),
          // Charts row
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 1,
            desktopColumns: 2,
            spacing: 16,
            runSpacing: 16,
            children: [
              _TaskStatusChart(tasks: app.tasks),
              _WorkflowRunsChart(workflows: app.workflows),
            ],
          ),
          const SizedBox(height: 24),
          // Recent activity
          _RecentActivity(logs: app.logs),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final bool isAdmin;
  const _WelcomeBanner({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.welcomeBanner,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.workflowRunningSmooth,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white.withOpacity(0.85)),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.admin_panel_settings, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(context.l10n.adminDashboard, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const AvatarWidget(size: 64),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1);
  }
}

class _TaskStatusChart extends StatelessWidget {
  final List<Task> tasks;
  const _TaskStatusChart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Map<TaskStatus, int> counts = {
      for (final s in TaskStatus.values)
        s: tasks.where((t) => t.status == s).length,
    };
    final total = tasks.length;

    return AppCard(
      title: context.l10n.taskStatusChart,
      child: total == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.l10n.noTasksEmpty),
              ),
            )
          : SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: TaskStatus.values.map((s) {
                          final val = counts[s] ?? 0;
                          return PieChartSectionData(
                            value: val.toDouble(),
                            color: s.color,
                            radius: 50,
                            title: val > 0 ? '$val' : '',
                            titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: TaskStatus.values.map((s) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                    color: s.color,
                                    borderRadius: BorderRadius.circular(3))),
                            const SizedBox(width: 8),
                            Text(s.label,
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _WorkflowRunsChart extends StatelessWidget {
  final List<Workflow> workflows;
  const _WorkflowRunsChart({required this.workflows});

  @override
  Widget build(BuildContext context) {
    final totalRuns = workflows.fold(0, (s, w) => s + w.runCount);
    final base = totalRuns > 0 ? totalRuns / 7 : 5;
    final spots = List.generate(7, (i) {
      final variance = (i % 3 == 0 ? 1.3 : i % 2 == 0 ? 0.8 : 1.0);
      return FlSpot(i.toDouble(), (base * variance).clamp(0.0, base * 2.0));
    });
    return AppCard(
      title: context.l10n.runsLastSevenDays,
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    return Text(days[v.toInt() % 7],
                        style: Theme.of(context).textTheme.bodySmall);
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.15),
                ),
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _RecentActivity extends StatelessWidget {
  final List<String> logs;
  const _RecentActivity({required this.logs});

  String relativeTime(String logEntry) {
    try {
      final match = RegExp(r'\[(\d{4}-\d{2}-\d{2}T[\d:.]+)\]').firstMatch(logEntry);
      if (match != null) {
        final dt = DateTime.parse(match.group(1)!);
        final diff = DateTime.now().difference(dt);
        if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        if (diff.inHours < 24) return '${diff.inHours}h ago';
        return '${diff.inDays}d ago';
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final recent = logs.take(5).toList();

    return AppCard(
      title: context.l10n.recentActivityTitle,
      child: recent.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(context.l10n.noActivityYet),
              ),
            )
          : Column(
              children: recent.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(e.value,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(relativeTime(e.value), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4))),
                    ],
                  ),
                );
              }).toList(),
            ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
