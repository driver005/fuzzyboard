import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  HapticFeedback.lightImpact();
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
              // Info chips — Wrap so they break across lines instead of overflowing
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _InfoChip(
                        icon: Icons.play_circle_outline,
                        label: context.l10n.runsCount(workflow.runCount)),
                    _InfoChip(
                        icon: Icons.device_hub,
                        label: context.l10n.nodesCount(workflow.nodes.length)),
                    _InfoChip(
                        icon: workflow.isActive ? Icons.check_circle : Icons.pause_circle,
                        label: workflow.isActive ? context.l10n.activeStatus : context.l10n.inactiveStatus,
                        color: workflow.isActive
                            ? const Color(0xFF10B981)
                            : cs.onSurface.withOpacity(0.4)),
                    if (isRunning)
                      _InfoChip(
                        icon: Icons.radio_button_checked,
                        label: context.l10n.runningStatus,
                        color: const Color(0xFF3B82F6),
                      ),
                  ],
                ),
              ),
              // Action buttons — icon-only keeps the row compact on any screen width
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: context.l10n.viewWorkflowButton,
                onPressed: () => showWorkflowModal(context),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: context.l10n.editCanvasButton,
                onPressed: isRunning
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => WorkflowCanvas(workflowId: workflow.id),
                          ),
                        ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                tooltip: context.l10n.deleteAction,
                onPressed: isRunning ? null : () => confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showWorkflowModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WorkflowCanvas(workflowId: workflow.id, readOnly: true),
      ),
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
              HapticFeedback.mediumImpact();
              context.read<AppProvider>().deleteWorkflow(workflow.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
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
