import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../models/workflow.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import 'workflow_canvas.dart';

class WorkflowsPage extends StatelessWidget {
  const WorkflowsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflows'),
        actions: [
          AppButton(
            label: 'New Workflow',
            icon: const Icon(Icons.add),
            size: AppButtonSize.sm,
            onPressed: () => _newWorkflow(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: app.workflows.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: app.workflows
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _WorkflowCard(workflow: e.value)
                            .animate()
                            .fadeIn(delay: (e.key * 80).ms)
                            .slideY(begin: 0.1),
                      ))
                  .toList(),
            ),
    );
  }

  void _newWorkflow(BuildContext context) {
    final app = context.read<AppProvider>();
    final wf = Workflow(
      id: app.generateId(),
      name: 'New Workflow',
      description: '',
    );
    app.addWorkflow(wf);
    _openCanvas(context, wf);
  }

  void _openCanvas(BuildContext context, Workflow wf) {
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
                onChanged: (_) => app.toggleWorkflow(workflow.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                  icon: Icons.play_circle_outline,
                  label: '${workflow.runCount} runs'),
              const SizedBox(width: 8),
              _InfoChip(
                  icon: Icons.device_hub,
                  label: '${workflow.nodes.length} nodes'),
              const SizedBox(width: 8),
              _InfoChip(
                  icon: workflow.isActive
                      ? Icons.check_circle
                      : Icons.pause_circle,
                  label: workflow.isActive ? 'Active' : 'Inactive',
                  color: workflow.isActive
                      ? const Color(0xFF10B981)
                      : cs.onSurface.withOpacity(0.4)),
              const Spacer(),
              AppButton(
                label: 'Edit Canvas',
                icon: const Icon(Icons.edit),
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) =>
                        WorkflowCanvas(workflowId: workflow.id),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workflow?'),
        content: Text('Are you sure you want to delete "${workflow.name}"?'),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          AppButton(
            label: 'Delete',
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
          Text('No workflows yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5))),
          const SizedBox(height: 8),
          Text('Create your first workflow to get started.',
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
