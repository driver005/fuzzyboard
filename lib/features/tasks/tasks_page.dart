import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../models/task.dart';
import '../../models/task_run.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_input.dart';
import '../../shared/widgets/tutorial_banner.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String search = '';
  bool searchVisible = false;
  TaskPriority? filterPriority;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final tasks = app.tasks.where((t) {
      if (search.isNotEmpty &&
          !t.name.toLowerCase().contains(search.toLowerCase()) &&
          !t.description.toLowerCase().contains(search.toLowerCase())) {
        return false;
      }
      if (filterPriority != null && t.priority != filterPriority) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tasksTitle),
        actions: [
          IconButton(
            icon: Icon(searchVisible ? Icons.search_off : Icons.search),
            tooltip: 'Search',
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                searchVisible = !searchVisible;
                if (!searchVisible) search = '';
              });
            },
          ),
          AppButton(
            label: context.l10n.newTaskButton,
            icon: const Icon(Icons.add),
            size: AppButtonSize.sm,
            onPressed: () {
              HapticFeedback.lightImpact();
              showTaskDialog(context);
            },
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(icon: Icon(Icons.checklist, size: 18), text: 'Tasks'),
            Tab(icon: Icon(Icons.history, size: 18), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _TaskListTab(
            tasks: tasks,
            search: search,
            searchVisible: searchVisible,
            filterPriority: filterPriority,
            onSearchChanged: (v) => setState(() => search = v),
            onPriorityChanged: (p) => setState(() => filterPriority = p),
            onEdit: (t) => showTaskDialog(context, t),
          ),
          _HistoryTab(runs: app.taskRuns),
        ],
      ),
    );
  }

  void showTaskDialog(BuildContext context, [Task? task]) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) => _TaskFullModal(
        task: task,
        onSave: (t) {
          HapticFeedback.mediumImpact();
          if (task == null) {
            context.read<AppProvider>().addTask(t);
          } else {
            context.read<AppProvider>().updateTask(t);
          }
        },
      ),
    );
  }
}

// ── Task List Tab ──────────────────────────────────────────────────────────────

class _TaskListTab extends StatelessWidget {
  final List<Task> tasks;
  final String search;
  final bool searchVisible;
  final TaskPriority? filterPriority;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TaskPriority?> onPriorityChanged;
  final void Function(Task) onEdit;

  const _TaskListTab({
    required this.tasks,
    required this.search,
    required this.searchVisible,
    required this.filterPriority,
    required this.onSearchChanged,
    required this.onPriorityChanged,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TutorialBanner(
          title: 'Tasks',
          emoji: '✅',
          steps: [
            'Click "New Task" to create a task definition.',
            'Tap a task card to edit it.',
            'Use the History tab to see past runs with their status.',
            'Filter by priority using the chips below.',
          ],
        ),
        if (searchVisible)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AppInput(
              hint: context.l10n.searchTasksHint,
              prefix: const Icon(Icons.search, size: 18),
              onChanged: onSearchChanged,
            ),
          ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(context.l10n.allChip),
                  selected: filterPriority == null,
                  onSelected: (_) => onPriorityChanged(null),
                ),
              ),
              ...TaskPriority.values.map((p) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(p.label),
                      selected: filterPriority == p,
                      avatar: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: p.color, shape: BoxShape.circle),
                      ),
                      onSelected: (_) => onPriorityChanged(p),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    return _TaskCard(
                      task: tasks[i],
                      onTap: () => showDialog(
                        context: context,
                        useSafeArea: false,
                        builder: (ctx) => _TaskViewModal(
                          task: tasks[i],
                          onEdit: () => onEdit(tasks[i]),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (i * 50).ms)
                        .slideX(begin: 0.05);
                  },
                ),
        ),
      ],
    );
  }
}

// ── History Tab ────────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final List<TaskRun> runs;
  const _HistoryTab({required this.runs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (runs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history,
                size: 56, color: cs.onSurface.withOpacity(0.25)),
            const SizedBox(height: 12),
            Text('No run history yet',
                style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.4))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: runs.length,
      itemBuilder: (context, i) {
        final run = runs[i];
        return _TaskRunCard(run: run)
            .animate()
            .fadeIn(delay: (i * 40).ms)
            .slideX(begin: 0.05);
      },
    );
  }
}

class _TaskRunCard extends StatelessWidget {
  final TaskRun run;
  const _TaskRunCard({required this.run});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = run.status.color;
    final dur = run.duration;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(run.taskName,
                          style: theme.textTheme.titleSmall),
                      const SizedBox(width: 8),
                      _RunStatusBadge(status: run.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(run.startedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            if (run.status == TaskRunStatus.running)
              SizedBox(
                width: 16,
                height: 16,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else if (dur != null)
              Text('${dur.inSeconds}s',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.4))),
          ],
        ),
      ),
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

class _RunStatusBadge extends StatelessWidget {
  final TaskRunStatus status;
  const _RunStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Task Card ─────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  const _TaskCard({required this.task, required this.onTap});

  bool isOverdue(Task t) =>
      t.dueDate != null && t.dueDate!.isBefore(DateTime.now());

  String formatDue(DateTime d, BuildContext context) {
    final now = DateTime.now();
    final diff = d.difference(now);
    if (diff.inDays == 0) return context.l10n.dueToday;
    if (diff.inDays == 1) return context.l10n.dueTomorrow;
    if (diff.inDays == -1) return context.l10n.overdueFormat(1);
    if (diff.inDays < 0) return context.l10n.overdueFormat(-diff.inDays);
    return context.l10n.dueInFormat(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.read<AppProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: task.priority.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.name, style: theme.textTheme.titleSmall),
                  if (task.description.isNotEmpty)
                    Text(task.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: [
                      _Chip(
                          label: task.priority.label,
                          color: task.priority.color),
                      ...task.tags.take(2).map((t) => _Chip(
                            label: t,
                            color: theme.colorScheme.primary,
                          )),
                      if (task.dueDate != null)
                        _Chip(
                          label: formatDue(task.dueDate!, context),
                          color: isOverdue(task)
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF6B7280),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.red.shade400,
              onPressed: () {
                HapticFeedback.heavyImpact();
                app.deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Task View Modal (read-only) ────────────────────────────────────────────────

class _TaskViewModal extends StatefulWidget {
  final Task task;
  final VoidCallback onEdit;
  const _TaskViewModal({required this.task, required this.onEdit});

  @override
  State<_TaskViewModal> createState() => _TaskViewModalState();
}

class _TaskViewModalState extends State<_TaskViewModal> {
  bool starting = false;

  bool get isRunning {
    final app = context.read<AppProvider>();
    return app.runsForTask(widget.task.id).any((r) => r.status == TaskRunStatus.running);
  }

  bool get lastRunFailed {
    final app = context.read<AppProvider>();
    final runs = app.runsForTask(widget.task.id);
    if (runs.isEmpty) return false;
    return runs.first.status == TaskRunStatus.failed;
  }

  Future<void> startRun() async {
    final app = context.read<AppProvider>();
    final run = TaskRun(
      id: const Uuid().v4(),
      taskId: widget.task.id,
      taskName: widget.task.name,
      status: TaskRunStatus.running,
    );
    app.addTaskRun(run);
    setState(() => starting = false);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      app.updateTaskRun(TaskRun(
        id: run.id,
        taskId: run.taskId,
        taskName: run.taskName,
        status: TaskRunStatus.done,
        startedAt: run.startedAt,
        finishedAt: DateTime.now(),
      ));
      setState(() {});
    }
  }

  void stopRun() {
    final app = context.read<AppProvider>();
    final runs = app.runsForTask(widget.task.id);
    final active = runs.cast<TaskRun?>().firstWhere(
      (r) => r?.status == TaskRunStatus.running,
      orElse: () => null,
    );
    if (active != null) {
      app.updateTaskRun(TaskRun(
        id: active.id,
        taskId: active.taskId,
        taskName: active.taskName,
        status: TaskRunStatus.failed,
        startedAt: active.startedAt,
        finishedAt: DateTime.now(),
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final task = widget.task;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final running = app.runsForTask(task.id).any((r) => r.status == TaskRunStatus.running);
    final failed = !running && app.runsForTask(task.id).isNotEmpty &&
        app.runsForTask(task.id).first.status == TaskRunStatus.failed;

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
                border: Border(
                    bottom: BorderSide(color: cs.outline.withOpacity(0.15))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      task.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusBadgeTask(status: task.status),
                  const Spacer(),
                  // Action buttons
                  if (running)
                    AppButton(
                      label: 'Stop',
                      icon: const Icon(Icons.stop_circle_outlined),
                      variant: AppButtonVariant.danger,
                      size: AppButtonSize.sm,
                      onPressed: stopRun,
                    )
                  else ...[
                    AppButton(
                      label: 'Start',
                      icon: const Icon(Icons.play_arrow),
                      size: AppButtonSize.sm,
                      onPressed: startRun,
                    ),
                    if (failed) ...[
                      const SizedBox(width: 8),
                      AppButton(
                        label: 'Retry',
                        icon: const Icon(Icons.replay),
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.sm,
                        onPressed: startRun,
                      ),
                    ],
                  ],
                  const SizedBox(width: 8),
                  AppButton(
                    label: 'Change',
                    icon: const Icon(Icons.edit_outlined),
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.sm,
                    onPressed: running
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            widget.onEdit();
                          },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (running)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
                            ),
                            const SizedBox(width: 10),
                            const Text('Running…',
                                style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    _ViewSection(label: 'Details', icon: Icons.info_outline, children: [
                      _ViewRow(label: 'Name', value: task.name),
                      if (task.description.isNotEmpty)
                        _ViewRow(label: 'Description', value: task.description),
                      _ViewRow(label: 'Priority', value: task.priority.label),
                      if (task.tags.isNotEmpty)
                        _ViewRow(label: 'Tags', value: task.tags.join(', ')),
                      if (task.dueDate != null)
                        _ViewRow(
                          label: 'Due',
                          value:
                              '${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}',
                        ),
                    ]),
                    const SizedBox(height: 16),
                    _ViewSection(label: 'Execution', icon: Icons.timer_outlined, children: [
                      _ViewRow(label: 'Timeout', value: '${task.timeoutSeconds}s'),
                      _ViewRow(label: 'Response Timeout', value: '${task.responseTimeoutSeconds}s'),
                      _ViewRow(label: 'Retry Count', value: '${task.retryCount}'),
                      _ViewRow(label: 'Retry Policy', value: task.retryPolicy.label),
                      _ViewRow(label: 'Retry Delay', value: '${task.retryDelaySeconds}s'),
                      _ViewRow(
                        label: 'Concurrency',
                        value: task.concurrentExecLimit == 0
                            ? 'Unlimited'
                            : '${task.concurrentExecLimit}',
                      ),
                    ]),
                    if (task.inputKeys.isNotEmpty || task.outputKeys.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _ViewSection(label: 'I/O Keys', icon: Icons.swap_horiz, children: [
                        if (task.inputKeys.isNotEmpty)
                          _ViewRow(
                            label: 'Inputs',
                            value: task.inputKeys.keys.join(', '),
                          ),
                        if (task.outputKeys.isNotEmpty)
                          _ViewRow(
                            label: 'Outputs',
                            value: task.outputKeys.keys.join(', '),
                          ),
                      ]),
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

class _ViewSection extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Widget> children;
  const _ViewSection({required this.label, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(label,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: cs.outline.withOpacity(0.2))),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outline.withOpacity(0.12)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ViewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ViewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface.withOpacity(0.6))),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

// ── Task Edit Modal ────────────────────────────────────────────────────────────

class _TaskFullModal extends StatefulWidget {
  final Task? task;
  final void Function(Task) onSave;
  const _TaskFullModal({this.task, required this.onSave});

  @override
  State<_TaskFullModal> createState() => _TaskFullModalState();
}

class _TaskFullModalState extends State<_TaskFullModal>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  // ── Definition tab ──
  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController tagsCtrl;
  late TextEditingController assigneeCtrl;
  late TaskPriority priority;
  DateTime? dueDate;

  // ── Advanced tab (Conductor-inspired) ──
  late TextEditingController timeoutCtrl;
  late TextEditingController retryCountCtrl;
  late TextEditingController retryDelayCtrl;
  late TextEditingController responseTimeoutCtrl;
  late TextEditingController ownerEmailCtrl;
  late TextEditingController concurrencyCtrl;
  late TaskRetryPolicy retryPolicy;
  String? selectedPluginId;

  // ── I/O tab ──
  late Map<String, String> inputKeys;
  late Map<String, String> outputKeys;
  final TextEditingController newInputKeyCtrl = TextEditingController();
  final TextEditingController newInputDescCtrl = TextEditingController();
  final TextEditingController newOutputKeyCtrl = TextEditingController();
  final TextEditingController newOutputDescCtrl = TextEditingController();

  // ── JSON/YAML tab ──
  bool useYaml = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() => setState(() {}));

    final t = widget.task;
    nameCtrl = TextEditingController(text: t?.name ?? '');
    descCtrl = TextEditingController(text: t?.description ?? '');
    tagsCtrl = TextEditingController(text: t?.tags.join(', ') ?? '');
    assigneeCtrl = TextEditingController(
        text: t?.config['assignee'] as String? ?? '');
    priority = t?.priority ?? TaskPriority.medium;
    dueDate = t?.dueDate;

    timeoutCtrl = TextEditingController(
        text: (t?.timeoutSeconds ?? 3600).toString());
    retryCountCtrl = TextEditingController(
        text: (t?.retryCount ?? 3).toString());
    retryDelayCtrl = TextEditingController(
        text: (t?.retryDelaySeconds ?? 60).toString());
    responseTimeoutCtrl = TextEditingController(
        text: (t?.responseTimeoutSeconds ?? 600).toString());
    ownerEmailCtrl = TextEditingController(text: t?.ownerEmail ?? '');
    concurrencyCtrl = TextEditingController(
        text: (t?.concurrentExecLimit ?? 0).toString());
    retryPolicy = t?.retryPolicy ?? TaskRetryPolicy.fixed;
    selectedPluginId = t?.pluginId;

    inputKeys = Map.of(t?.inputKeys ?? {});
    outputKeys = Map.of(t?.outputKeys ?? {});
  }

  @override
  void dispose() {
    tabController.dispose();
    nameCtrl.dispose();
    descCtrl.dispose();
    tagsCtrl.dispose();
    assigneeCtrl.dispose();
    timeoutCtrl.dispose();
    retryCountCtrl.dispose();
    retryDelayCtrl.dispose();
    responseTimeoutCtrl.dispose();
    ownerEmailCtrl.dispose();
    concurrencyCtrl.dispose();
    newInputKeyCtrl.dispose();
    newInputDescCtrl.dispose();
    newOutputKeyCtrl.dispose();
    newOutputDescCtrl.dispose();
    super.dispose();
  }

  Task buildTask() {
    final tagList = tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final base = widget.task;
    return Task(
      id: base?.id ?? const Uuid().v4(),
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      priority: priority,
      status: base?.status ?? TaskStatus.todo,
      tags: tagList,
      createdAt: base?.createdAt ?? DateTime.now(),
      dueDate: dueDate,
      config: {
        ...(base?.config ?? {}),
        'assignee': assigneeCtrl.text.trim(),
      },
      timeoutSeconds: int.tryParse(timeoutCtrl.text) ?? 3600,
      retryCount: int.tryParse(retryCountCtrl.text) ?? 3,
      retryPolicy: retryPolicy,
      retryDelaySeconds: int.tryParse(retryDelayCtrl.text) ?? 60,
      responseTimeoutSeconds:
          int.tryParse(responseTimeoutCtrl.text) ?? 600,
      ownerEmail: ownerEmailCtrl.text.trim(),
      pluginId: selectedPluginId,
      inputKeys: Map.of(inputKeys),
      outputKeys: Map.of(outputKeys),
      concurrentExecLimit:
          int.tryParse(concurrencyCtrl.text) ?? 0,
    );
  }

  // ── JSON/YAML helpers ──────────────────────────────────────────────────────

  Map<String, dynamic> get previewJson => buildTask().toJson();

  String get jsonPreview {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(previewJson);
  }

  String get yamlPreview => _toYaml(previewJson, 0);

  String _toYaml(dynamic value, int indent) {
    final pad = '  ' * indent;
    if (value is Map) {
      if (value.isEmpty) return '{}';
      final buf = StringBuffer();
      for (final entry in value.entries) {
        final v = entry.value;
        if (v is Map || v is List) {
          buf.writeln('$pad${entry.key}:');
          buf.write(_toYaml(v, indent + 1));
        } else {
          buf.writeln('$pad${entry.key}: ${_scalar(v)}');
        }
      }
      return buf.toString();
    } else if (value is List) {
      if (value.isEmpty) return '$pad[]\n';
      final buf = StringBuffer();
      for (final item in value) {
        buf.writeln('$pad- ${_scalar(item)}');
      }
      return buf.toString();
    }
    return '$pad${_scalar(value)}\n';
  }

  String _scalar(dynamic v) {
    if (v == null) return 'null';
    if (v is bool) return v ? 'true' : 'false';
    if (v is num) return '$v';
    final s = '$v';
    if (s.contains(':') || s.isEmpty) return '"$s"';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.task == null;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? const Color(0xFF12121E) : cs.surface,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16162A) : Colors.white,
                border: Border(
                    bottom: BorderSide(color: cs.outline.withOpacity(0.15))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isNew
                        ? context.l10n.newTaskDialog
                        : context.l10n.editTaskDialog,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (!isNew && widget.task?.status != null) ...[
                    const SizedBox(width: 10),
                    _StatusBadgeTask(status: widget.task!.status),
                  ],
                  const Spacer(),
                  AppButton(
                    label: isNew
                        ? context.l10n.createButton
                        : context.l10n.saveButton,
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      HapticFeedback.mediumImpact();
                      widget.onSave(buildTask());
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // ── Tab bar ──────────────────────────────────────────────────────
            Container(
              color: isDark ? const Color(0xFF16162A) : Colors.white,
              child: TabBar(
                controller: tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline, size: 16), text: 'Definition'),
                  Tab(icon: Icon(Icons.tune, size: 16), text: 'Advanced'),
                  Tab(icon: Icon(Icons.swap_horiz, size: 16), text: 'I/O'),
                  Tab(icon: Icon(Icons.data_object, size: 16), text: 'JSON/YAML'),
                ],
              ),
            ),
            // ── Tab body ─────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  _DefinitionTab(
                    nameCtrl: nameCtrl,
                    descCtrl: descCtrl,
                    tagsCtrl: tagsCtrl,
                    assigneeCtrl: assigneeCtrl,
                    priority: priority,
                    dueDate: dueDate,
                    onPriorityChanged: (v) =>
                        setState(() => priority = v ?? priority),
                    onDueDateChanged: (d) => setState(() => dueDate = d),
                  ),
                  _AdvancedTab(
                    timeoutCtrl: timeoutCtrl,
                    retryCountCtrl: retryCountCtrl,
                    retryDelayCtrl: retryDelayCtrl,
                    responseTimeoutCtrl: responseTimeoutCtrl,
                    ownerEmailCtrl: ownerEmailCtrl,
                    concurrencyCtrl: concurrencyCtrl,
                    retryPolicy: retryPolicy,
                    selectedPluginId: selectedPluginId,
                    onRetryPolicyChanged: (v) =>
                        setState(() => retryPolicy = v ?? retryPolicy),
                    onPluginChanged: (id) =>
                        setState(() => selectedPluginId = id),
                    onChanged: () => setState(() {}),
                  ),
                  _IOTab(
                    inputKeys: inputKeys,
                    outputKeys: outputKeys,
                    newInputKeyCtrl: newInputKeyCtrl,
                    newInputDescCtrl: newInputDescCtrl,
                    newOutputKeyCtrl: newOutputKeyCtrl,
                    newOutputDescCtrl: newOutputDescCtrl,
                    onChanged: () => setState(() {}),
                  ),
                  _JsonYamlTab(
                    content: useYaml ? yamlPreview : jsonPreview,
                    useYaml: useYaml,
                    onToggle: (v) => setState(() => useYaml = v),
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

// ── Status badge for tasks ─────────────────────────────────────────────────────

class _StatusBadgeTask extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadgeTask({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      TaskStatus.todo => (const Color(0xFF6B7280), 'To Do'),
      TaskStatus.inProgress => (const Color(0xFF3B82F6), 'In Progress'),
      TaskStatus.done => (const Color(0xFF10B981), 'Done'),
      TaskStatus.blocked => (const Color(0xFFEF4444), 'Blocked'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Definition Tab ─────────────────────────────────────────────────────────────

class _DefinitionTab extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController tagsCtrl;
  final TextEditingController assigneeCtrl;
  final TaskPriority priority;
  final DateTime? dueDate;
  final ValueChanged<TaskPriority?> onPriorityChanged;
  final ValueChanged<DateTime?> onDueDateChanged;

  const _DefinitionTab({
    required this.nameCtrl,
    required this.descCtrl,
    required this.tagsCtrl,
    required this.assigneeCtrl,
    required this.priority,
    required this.dueDate,
    required this.onPriorityChanged,
    required this.onDueDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInput(
            label: context.l10n.taskNameLabel,
            hint: context.l10n.taskNameHint,
            controller: nameCtrl,
          ),
          const SizedBox(height: 12),
          AppInput(
            label: context.l10n.descriptionLabel,
            hint: context.l10n.descriptionHint,
            controller: descCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          AppSelect<TaskPriority>(
            label: context.l10n.priorityLabel,
            value: priority,
            onChanged: onPriorityChanged,
            items: TaskPriority.values
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.label),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          AppInput(
            label: context.l10n.tagsLabel,
            hint: context.l10n.tagsHint,
            controller: tagsCtrl,
          ),
          const SizedBox(height: 12),
          AppInput(
            label: context.l10n.assigneeLabel,
            hint: context.l10n.assigneeHint,
            controller: assigneeCtrl,
          ),
          const SizedBox(height: 12),
          Text(context.l10n.dueDateLabel,
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  dueDate != null
                      ? '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}'
                      : context.l10n.noDueDate,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(dueDate == null
                    ? context.l10n.setDateButton
                    : context.l10n.changeButton),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate ??
                        DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) onDueDateChanged(picked);
                },
              ),
              if (dueDate != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => onDueDateChanged(null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Advanced Tab (Conductor-inspired) ─────────────────────────────────────────

class _AdvancedTab extends StatelessWidget {
  final TextEditingController timeoutCtrl;
  final TextEditingController retryCountCtrl;
  final TextEditingController retryDelayCtrl;
  final TextEditingController responseTimeoutCtrl;
  final TextEditingController ownerEmailCtrl;
  final TextEditingController concurrencyCtrl;
  final TaskRetryPolicy retryPolicy;
  final String? selectedPluginId;
  final ValueChanged<TaskRetryPolicy?> onRetryPolicyChanged;
  final ValueChanged<String?> onPluginChanged;
  final VoidCallback onChanged;

  const _AdvancedTab({
    required this.timeoutCtrl,
    required this.retryCountCtrl,
    required this.retryDelayCtrl,
    required this.responseTimeoutCtrl,
    required this.ownerEmailCtrl,
    required this.concurrencyCtrl,
    required this.retryPolicy,
    required this.selectedPluginId,
    required this.onRetryPolicyChanged,
    required this.onPluginChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final plugins = context.watch<AppProvider>().plugins;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Owner ──
          _SectionLabel(label: 'Ownership', icon: Icons.person_outline),
          const SizedBox(height: 12),
          AppInput(
            label: 'Owner Email',
            hint: 'owner@example.com',
            controller: ownerEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 20),

          // ── Timeout ──
          _SectionLabel(label: 'Timeouts', icon: Icons.timer_outlined),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: AppInput(
                label: 'Timeout (seconds)',
                hint: '3600',
                controller: timeoutCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppInput(
                label: 'Response Timeout (seconds)',
                hint: '600',
                controller: responseTimeoutCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => onChanged(),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Retry ──
          _SectionLabel(label: 'Retry Policy', icon: Icons.replay_outlined),
          const SizedBox(height: 12),
          AppSelect<TaskRetryPolicy>(
            label: 'Retry Logic',
            value: retryPolicy,
            onChanged: onRetryPolicyChanged,
            items: TaskRetryPolicy.values
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.label),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: AppInput(
                label: 'Retry Count',
                hint: '3',
                controller: retryCountCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppInput(
                label: 'Retry Delay (seconds)',
                hint: '60',
                controller: retryDelayCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => onChanged(),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Concurrency ──
          _SectionLabel(
              label: 'Rate / Concurrency', icon: Icons.speed_outlined),
          const SizedBox(height: 12),
          AppInput(
            label: 'Concurrent Execution Limit (0 = unlimited)',
            hint: '0',
            controller: concurrencyCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 20),

          // ── Plugin association ──
          _SectionLabel(label: 'Plugin', icon: Icons.extension_outlined),
          const SizedBox(height: 12),
          AppSelect<String?>(
            label: 'Associated Plugin',
            value: selectedPluginId,
            hint: 'None',
            onChanged: onPluginChanged,
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('None')),
              ...plugins.map((p) => DropdownMenuItem<String?>(
                    value: p.id,
                    child: Row(
                      children: [
                        Text(p.iconEmoji ?? '🔌'),
                        const SizedBox(width: 6),
                        Text(p.name),
                      ],
                    ),
                  )),
            ],
          ),
          if (selectedPluginId != null && plugins.isNotEmpty) ...[
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final plugin = plugins.cast<dynamic>().firstWhere(
                  (p) => (p as dynamic).id == selectedPluginId,
                  orElse: () => null);
              if (plugin == null) return const SizedBox.shrink();
              return _PluginConfigPreview(plugin: plugin);
            }),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(label,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: cs.outline.withOpacity(0.2))),
      ],
    );
  }
}

class _PluginConfigPreview extends StatelessWidget {
  final dynamic plugin;
  const _PluginConfigPreview({required this.plugin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    if (plugin.configSchema.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plugin Config',
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
          const SizedBox(height: 8),
          ...plugin.configSchema.map<Widget>((field) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text('${field.label}: ',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Text(
                        field.type.toString().split('.').last == 'secret'
                            ? '••••••'
                            : '${plugin.configValues[field.key] ?? field.defaultValue ?? '—'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.6)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── I/O Tab ────────────────────────────────────────────────────────────────────

class _IOTab extends StatelessWidget {
  final Map<String, String> inputKeys;
  final Map<String, String> outputKeys;
  final TextEditingController newInputKeyCtrl;
  final TextEditingController newInputDescCtrl;
  final TextEditingController newOutputKeyCtrl;
  final TextEditingController newOutputDescCtrl;
  final VoidCallback onChanged;

  const _IOTab({
    required this.inputKeys,
    required this.outputKeys,
    required this.newInputKeyCtrl,
    required this.newInputDescCtrl,
    required this.newOutputKeyCtrl,
    required this.newOutputDescCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'Input Keys', icon: Icons.input),
          const SizedBox(height: 4),
          Text(
            'Define the input parameters this task expects from the workflow.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 12),
          _KeyValueTable(
            entries: inputKeys,
            onRemove: (key) {
              inputKeys.remove(key);
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _AddKeyValueRow(
            keyCtrl: newInputKeyCtrl,
            descCtrl: newInputDescCtrl,
            onAdd: () {
              final k = newInputKeyCtrl.text.trim();
              if (k.isNotEmpty) {
                inputKeys[k] = newInputDescCtrl.text.trim();
                newInputKeyCtrl.clear();
                newInputDescCtrl.clear();
                onChanged();
              }
            },
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Output Keys', icon: Icons.output),
          const SizedBox(height: 4),
          Text(
            'Define the output parameters this task produces for downstream tasks.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 12),
          _KeyValueTable(
            entries: outputKeys,
            onRemove: (key) {
              outputKeys.remove(key);
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _AddKeyValueRow(
            keyCtrl: newOutputKeyCtrl,
            descCtrl: newOutputDescCtrl,
            onAdd: () {
              final k = newOutputKeyCtrl.text.trim();
              if (k.isNotEmpty) {
                outputKeys[k] = newOutputDescCtrl.text.trim();
                newOutputKeyCtrl.clear();
                newOutputDescCtrl.clear();
                onChanged();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _KeyValueTable extends StatelessWidget {
  final Map<String, String> entries;
  final ValueChanged<String> onRemove;
  const _KeyValueTable({required this.entries, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('No keys defined yet.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.35))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(8),
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF9FAFB),
      ),
      child: Column(
        children: entries.entries.toList().asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: idx < entries.length - 1
                  ? Border(
                      bottom: BorderSide(
                          color: cs.outline.withOpacity(0.1)))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(entry.key,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: cs.primary,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.isEmpty ? '—' : entry.value,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  color: Colors.red.shade400,
                  onPressed: () => onRemove(entry.key),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AddKeyValueRow extends StatelessWidget {
  final TextEditingController keyCtrl;
  final TextEditingController descCtrl;
  final VoidCallback onAdd;
  const _AddKeyValueRow(
      {required this.keyCtrl, required this.descCtrl, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppInput(
            hint: 'key name',
            controller: keyCtrl,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: AppInput(
            hint: 'description / type',
            controller: descCtrl,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          icon: const Icon(Icons.add, size: 18),
          onPressed: onAdd,
          tooltip: 'Add key',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

// ── JSON/YAML Tab ──────────────────────────────────────────────────────────────

class _JsonYamlTab extends StatelessWidget {
  final String content;
  final bool useYaml;
  final ValueChanged<bool> onToggle;
  const _JsonYamlTab(
      {required this.content,
      required this.useYaml,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF5F5FF),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(Icons.data_object, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  useYaml ? 'YAML Preview' : 'JSON Preview',
                  style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700, color: cs.primary),
                ),
                const Spacer(),
                _PreviewToggle(useYaml: useYaml, onToggle: onToggle),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  tooltip: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outline.withOpacity(0.1)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                content,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.6,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewToggle extends StatelessWidget {
  final bool useYaml;
  final ValueChanged<bool> onToggle;
  const _PreviewToggle(
      {required this.useYaml, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleChip(
            label: 'JSON',
            selected: !useYaml,
            onTap: () => onToggle(false),
            cs: cs),
        const SizedBox(width: 4),
        _ToggleChip(
            label: 'YAML',
            selected: useYaml,
            onTap: () => onToggle(true),
            cs: cs),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _ToggleChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:
              selected ? cs.primary : cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : cs.primary,
          ),
        ),
      ),
    );
  }
}
