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
                      onTap: () => onEdit(tasks[i]),
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

// ── Task Edit Modal ────────────────────────────────────────────────────────────

class _TaskFullModal extends StatefulWidget {
  final Task? task;
  final void Function(Task) onSave;
  const _TaskFullModal({this.task, required this.onSave});

  @override
  State<_TaskFullModal> createState() => _TaskFullModalState();
}

class _TaskFullModalState extends State<_TaskFullModal> {
  late TextEditingController name;
  late TextEditingController desc;
  late TextEditingController tags;
  late TextEditingController assigneeController;
  late TaskPriority priority;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.task?.name ?? '');
    desc = TextEditingController(text: widget.task?.description ?? '');
    tags = TextEditingController(text: widget.task?.tags.join(', ') ?? '');
    assigneeController = TextEditingController(
        text: widget.task?.config['assignee'] as String? ?? '');
    priority = widget.task?.priority ?? TaskPriority.medium;
    dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    name.dispose();
    desc.dispose();
    tags.dispose();
    assigneeController.dispose();
    super.dispose();
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
                  const Spacer(),
                  AppButton(
                    label: isNew
                        ? context.l10n.createButton
                        : context.l10n.saveButton,
                    onPressed: () {
                      if (name.text.trim().isEmpty) return;
                      HapticFeedback.mediumImpact();
                      final tagList = tags.text
                          .split(',')
                          .map((t) => t.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();
                      final t = widget.task?.copyWith(
                              name: name.text.trim(),
                              description: desc.text.trim(),
                              priority: priority,
                              tags: tagList,
                              dueDate: dueDate,
                              config: {
                                ...(widget.task?.config ?? {}),
                                'assignee': assigneeController.text.trim()
                              }) ??
                          Task(
                            id: const Uuid().v4(),
                            name: name.text.trim(),
                            description: desc.text.trim(),
                            priority: priority,
                            tags: tagList,
                            dueDate: dueDate,
                            config: {
                              'assignee': assigneeController.text.trim()
                            },
                          );
                      widget.onSave(t);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInput(
                      label: context.l10n.taskNameLabel,
                      hint: context.l10n.taskNameHint,
                      controller: name,
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      label: context.l10n.descriptionLabel,
                      hint: context.l10n.descriptionHint,
                      controller: desc,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    AppSelect<TaskPriority>(
                      label: context.l10n.priorityLabel,
                      value: priority,
                      onChanged: (v) =>
                          setState(() => priority = v ?? priority),
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
                      controller: tags,
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      label: context.l10n.assigneeLabel,
                      hint: context.l10n.assigneeHint,
                      controller: assigneeController,
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                      DateTime.now()
                                          .add(const Duration(days: 1)),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => dueDate = picked);
                                }
                              },
                            ),
                            if (dueDate != null)
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () =>
                                    setState(() => dueDate = null),
                              ),
                          ],
                        ),
                      ],
                    ),
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
