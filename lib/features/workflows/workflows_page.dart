import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/gamification_provider.dart';
import '../../models/workflow.dart';
import '../../models/workflow_run.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/tutorial_banner.dart';
import 'workflow_canvas.dart';

class WorkflowsPage extends StatelessWidget {
  const WorkflowsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.workflowsTitle),
        actions: [
          AppButton(
            label: context.l10n.newWorkflowButton,
            icon: const Icon(Icons.add),
            size: AppButtonSize.sm,
            onPressed: () => newWorkflow(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: app.workflows.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const TutorialBanner(
                  title: 'Workflows',
                  emoji: '⚙️',
                  steps: [
                    'Click "New Workflow" to create an automation. Each workflow is a chain of nodes.',
                    'Use the toggle switch on each workflow card to activate or deactivate it.',
                    'Click "Edit Canvas" to open the visual workflow builder.',
                    'In the canvas: add nodes from the left palette, drag to move them, click 🔗 to connect them, and tap a node to configure it.',
                    'Click the ❓ help icon in the canvas toolbar for a full guide.',
                  ],
                ),
                const SizedBox(height: 8),
                ...app.workflows
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _WorkflowCard(workflow: e.value)
                              .animate()
                              .fadeIn(delay: (e.key * 80).ms)
                              .slideY(begin: 0.1),
                        )),
              ],
            ),
    );
  }

  void newWorkflow(BuildContext context) {
    final app = context.read<AppProvider>();
    final wf = Workflow(
      id: app.generateId(),
      name: 'New Workflow',
      description: '',
    );
    app.addWorkflow(wf);
    openCanvas(context, wf);
  }

  void openCanvas(BuildContext context, Workflow wf) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WorkflowCanvas(workflowId: wf.id),
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  final Workflow workflow;
  const _WorkflowCard({required this.workflow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final app = context.read<AppProvider>();
    final runs = app.runsForWorkflow(workflow.id);
    final activeRun = runs.isNotEmpty && runs.first.status == WorkflowRunStatus.running
        ? runs.first
        : null;
    final isRunning = activeRun != null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.account_tree, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workflow.name, style: theme.textTheme.titleMedium),
                    if (workflow.description.isNotEmpty)
                      Text(workflow.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.6)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Switch(
                value: workflow.isActive,
                onChanged: (_) {
                  app.toggleWorkflow(workflow.id);
                  if (!workflow.isActive) {
                    context.read<GamificationProvider>().onWorkflowRun();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                  icon: Icons.play_circle_outline,
                  label: context.l10n.runsCount(workflow.runCount)),
              const SizedBox(width: 8),
              _InfoChip(
                  icon: Icons.device_hub,
                  label: context.l10n.nodesCount(workflow.nodes.length)),
              const SizedBox(width: 8),
              _InfoChip(
                  icon: workflow.isActive ? Icons.check_circle : Icons.pause_circle,
                  label: workflow.isActive ? context.l10n.activeStatus : context.l10n.inactiveStatus,
                  color: workflow.isActive
                      ? const Color(0xFF10B981)
                      : cs.onSurface.withOpacity(0.4)),
              if (isRunning) ...[
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.radio_button_checked,
                  label: 'Running',
                  color: const Color(0xFF3B82F6),
                ),
              ],
              const Spacer(),
              // View execution state
              AppButton(
                label: 'View',
                icon: const Icon(Icons.visibility_outlined),
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                onPressed: () => showWorkflowModal(context),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: context.l10n.editCanvasButton,
                icon: const Icon(Icons.edit),
                variant: isRunning ? AppButtonVariant.ghost : AppButtonVariant.outline,
                size: AppButtonSize.sm,
                onPressed: isRunning
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => WorkflowCanvas(workflowId: workflow.id),
                          ),
                        ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                onPressed: isRunning ? null : () => confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showWorkflowModal(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (_) => _WorkflowStateModal(workflow: workflow),
    );
  }

  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteWorkflowConfirm),
        content: Text(context.l10n.deleteWorkflowMessage(workflow.name)),
        actions: [
          AppButton(
            label: context.l10n.cancelButton,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          AppButton(
            label: context.l10n.deleteAction,
            variant: AppButtonVariant.danger,
            onPressed: () {
              context.read<AppProvider>().deleteWorkflow(workflow.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

/// Full-screen modal showing workflow execution state and node statuses.
class _WorkflowStateModal extends StatelessWidget {
  final Workflow workflow;
  const _WorkflowStateModal({required this.workflow});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final runs = app.runsForWorkflow(workflow.id);
    final latestRun = runs.isNotEmpty ? runs.first : null;
    final isRunning = latestRun?.status == WorkflowRunStatus.running;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? const Color(0xFF12121E) : cs.surface,
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16162A) : Colors.white,
                border: Border(bottom: BorderSide(color: cs.outline.withOpacity(0.15))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.account_tree, color: cs.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(workflow.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  _RunStatusBadge(status: latestRun?.status),
                  const Spacer(),
                  if (!isRunning)
                    AppButton(
                      label: context.l10n.editCanvasButton,
                      icon: const Icon(Icons.edit),
                      size: AppButtonSize.sm,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => WorkflowCanvas(workflowId: workflow.id),
                          ),
                        );
                      },
                    )
                  else
                    Tooltip(
                      message: 'Cannot edit while workflow is running',
                      child: AppButton(
                        label: context.l10n.editCanvasButton,
                        icon: const Icon(Icons.edit),
                        size: AppButtonSize.sm,
                        variant: AppButtonVariant.ghost,
                        onPressed: null,
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Body: node list + run history
            Expanded(
              child: Row(
                children: [
                  // Left: nodes with state
                  Expanded(
                    flex: 2,
                    child: _NodeStateView(workflow: workflow, isRunning: isRunning),
                  ),
                  VerticalDivider(width: 1, color: cs.outline.withOpacity(0.15)),
                  // Right: run history
                  SizedBox(
                    width: 280,
                    child: _RunHistoryPanel(runs: runs),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunStatusBadge extends StatelessWidget {
  final WorkflowRunStatus? status;
  const _RunStatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) {
      return const SizedBox.shrink();
    }
    final (color, label, icon) = switch (status!) {
      WorkflowRunStatus.running => (const Color(0xFF3B82F6), 'Running', Icons.radio_button_checked),
      WorkflowRunStatus.success => (const Color(0xFF10B981), 'Success', Icons.check_circle),
      WorkflowRunStatus.failed => (const Color(0xFFEF4444), 'Failed', Icons.cancel),
      WorkflowRunStatus.cancelled => (const Color(0xFF6B7280), 'Cancelled', Icons.stop_circle),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _NodeStateView extends StatelessWidget {
  final Workflow workflow;
  final bool isRunning;
  const _NodeStateView({required this.workflow, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Text('Nodes', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              _InfoBadge('${workflow.nodes.length}', cs.primary),
              const Spacer(),
              if (isRunning) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 6),
                Text('Executing...', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF3B82F6))),
              ],
            ],
          ),
        ),
        Expanded(
          child: workflow.nodes.isEmpty
              ? Center(
                  child: Text('No nodes yet', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4))),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workflow.nodes.length,
                  itemBuilder: (context, i) {
                    final node = workflow.nodes[i];
                    final nodeColor = WorkflowNode.colorForType(node.type);
                    // Simulate first node as "running" if workflow is active
                    final nodeRunning = isRunning && i == 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: nodeRunning
                              ? const Color(0xFF3B82F6).withOpacity(0.08)
                              : cs.surface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: nodeRunning
                                ? const Color(0xFF3B82F6).withOpacity(0.4)
                                : cs.outline.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: nodeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(WorkflowNode.iconForType(node.type), size: 16, color: nodeColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(node.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  Text(node.type.name.toUpperCase(),
                                      style: TextStyle(fontSize: 10, color: nodeColor, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                ],
                              ),
                            ),
                            if (nodeRunning)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF3B82F6)),
                              ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.05),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _RunHistoryPanel extends StatelessWidget {
  final List<WorkflowRun> runs;
  const _RunHistoryPanel({required this.runs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text('Run History', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ),
        Divider(height: 1, color: cs.outline.withOpacity(0.15)),
        Expanded(
          child: runs.isEmpty
              ? Center(
                  child: Text('No runs yet', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4))),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: runs.length,
                  itemBuilder: (context, i) {
                    final run = runs[i];
                    final (color, icon) = switch (run.status) {
                      WorkflowRunStatus.running => (const Color(0xFF3B82F6), Icons.radio_button_checked),
                      WorkflowRunStatus.success => (const Color(0xFF10B981), Icons.check_circle),
                      WorkflowRunStatus.failed => (const Color(0xFFEF4444), Icons.cancel),
                      WorkflowRunStatus.cancelled => (const Color(0xFF6B7280), Icons.stop_circle),
                    };
                    final dur = run.duration;
                    return ListTile(
                      dense: true,
                      leading: Icon(icon, size: 16, color: color),
                      title: Text(
                        run.status.name[0].toUpperCase() + run.status.name.substring(1),
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: color),
                      ),
                      subtitle: Text(
                        _formatTime(run.startedAt),
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4), fontSize: 10),
                      ),
                      trailing: dur != null
                          ? Text('${dur.inSeconds}s', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4)))
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined,
              size: 64,
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(context.l10n.noWorkflowsYet,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5))),
          const SizedBox(height: 8),
          Text(context.l10n.createFirstWorkflow,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4))),
        ],
      ),
    );
  }
}
