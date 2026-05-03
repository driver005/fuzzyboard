import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/gamification_provider.dart';
import '../../models/task.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_input.dart';
import '../../shared/widgets/tutorial_banner.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String search = '';
  TaskStatus? filterStatus;
  TaskPriority? filterPriority;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final tasks = app.tasks.where((t) {
      if (search.isNotEmpty &&
          !t.name.toLowerCase().contains(search.toLowerCase()) &&
          !t.description.toLowerCase().contains(search.toLowerCase())) {
        return false;
      }
      if (filterStatus != null && t.status != filterStatus) return false;
      if (filterPriority != null && t.priority != filterPriority) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tasksTitle),
        actions: [
          AppButton(
            label: context.l10n.newTaskButton,
            icon: const Icon(Icons.add),
            size: AppButtonSize.sm,
            onPressed: () => showTaskDialog(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          const TutorialBanner(
            title: 'Tasks',
            emoji: '✅',
            steps: [
              'Click "New Task" to create a task, or convert an SQL/Lua query directly from those builders.',
              'Drag any task card between the To Do, In Progress, Done, and Failed columns.',
              'Filter tasks by status or priority using the search bar and chips above.',
              'Tap a task card or use ⋮ → Edit to update its name, description, tags, and due date.',
              'Tasks created from the SQL/Lua builders carry a "sql" or "lua" tag for easy filtering.',
            ],
          ),
          // Filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: AppInput(
                    hint: context.l10n.searchTasksHint,
                    prefix: const Icon(Icons.search, size: 18),
                    onChanged: (v) => setState(() => search = v),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusFilter(
                  value: filterStatus,
                  onChanged: (s) => setState(() => filterStatus = s),
                ),
              ],
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
                    onSelected: (_) => setState(() => filterPriority = null),
                  ),
                ),
                ...TaskPriority.values.map((p) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(p.label),
                    selected: filterPriority == p,
                    avatar: Container(width: 8, height: 8, decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
                    onSelected: (_) => setState(() => filterPriority = p),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Status lanes
          Expanded(
            child: _TaskBoard(tasks: tasks),
          ),
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
          if (task == null) {
            context.read<AppProvider>().addTask(t);
            // Award XP when a task is marked done on creation
            if (t.status == TaskStatus.done) {
              context.read<GamificationProvider>().onTaskCompleted();
            }
          } else {
            final wasDone = task.status == TaskStatus.done;
            final isDone = t.status == TaskStatus.done;
            context.read<AppProvider>().updateTask(t);
            if (!wasDone && isDone) {
              context.read<GamificationProvider>().onTaskCompleted();
            }
          }
        },
      ),
    );
  }
}

class _TaskBoard extends StatelessWidget {
  final List<Task> tasks;
  const _TaskBoard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: TaskStatus.values.map((status) {
        final statusTasks = tasks.where((t) => t.status == status).toList();
        return _StatusLane(status: status, tasks: statusTasks);
      }).toList(),
    );
  }
}

class _StatusLane extends StatefulWidget {
  final TaskStatus status;
  final List<Task> tasks;
  const _StatusLane({required this.status, required this.tasks});
  @override
  State<_StatusLane> createState() => _StatusLaneState();
}

class _StatusLaneState extends State<_StatusLane> {
  bool isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != widget.status,
      onAcceptWithDetails: (details) {
        final task = details.data;
        context.read<AppProvider>().updateTask(task.copyWith(status: widget.status));
        setState(() => isDragOver = false);
      },
      onLeave: (_) => setState(() => isDragOver = false),
      onMove: (_) => setState(() => isDragOver = true),
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isDragOver ? widget.status.color.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isDragOver ? Border.all(color: widget.status.color.withOpacity(0.3), width: 1.5) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: widget.status.color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(widget.status.label, style: theme.textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: widget.status.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Text('${widget.tasks.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.status.color)),
                    ),
                  ],
                ),
              ),
              if (widget.tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 18),
                  child: Text(context.l10n.noTasksEmpty, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4))),
                )
              else
                ...widget.tasks.asMap().entries.map((e) {
                  return Draggable<Task>(
                    data: e.value,
                    feedback: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 280,
                        child: _TaskCard(task: e.value),
                      ),
                    ),
                    childWhenDragging: Opacity(opacity: 0.4, child: _TaskCard(task: e.value)),
                    child: _TaskCard(task: e.value).animate().fadeIn(delay: (e.key * 50).ms).slideX(begin: 0.1),
                  );
                }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  bool isOverdue(Task t) => t.dueDate != null && t.dueDate!.isBefore(DateTime.now()) && t.status != TaskStatus.done;

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
        onTap: () => showTaskDialog(context, task),
        child: Row(
          children: [
            // Priority indicator
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
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6)),
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
                      if (task.dueDate != null) ...[
                        _Chip(
                          label: formatDue(task.dueDate!, context),
                          color: isOverdue(task) ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (v) {
                if (v == 'edit') {
                  showTaskDialog(context, task);
                } else if (v == 'delete') {
                  app.deleteTask(task.id);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(context.l10n.editAction)),
                PopupMenuItem(value: 'delete', child: Text(context.l10n.deleteAction)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) => _TaskFullModal(
        task: task,
        onSave: (t) {
          final wasDone = task.status == TaskStatus.done;
          final isDone = t.status == TaskStatus.done;
          context.read<AppProvider>().updateTask(t);
          if (!wasDone && isDone) {
            context.read<GamificationProvider>().onTaskCompleted();
          }
        },
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
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final TaskStatus? value;
  final ValueChanged<TaskStatus?> onChanged;

  const _StatusFilter({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<TaskStatus?>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, size: 18, color: cs.onSurface.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(value?.label ?? context.l10n.allChip,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text(context.l10n.allChip)),
        ...TaskStatus.values
            .map((s) => PopupMenuItem(value: s, child: Text(s.label))),
      ],
    );
  }
}

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
  late TaskStatus status;
  late TaskPriority priority;
  DateTime? dueDate;
  bool useYaml = false;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.task?.name ?? '');
    desc = TextEditingController(text: widget.task?.description ?? '');
    tags = TextEditingController(text: widget.task?.tags.join(', ') ?? '');
    assigneeController = TextEditingController(text: widget.task?.config['assignee'] as String? ?? '');
    status = widget.task?.status ?? TaskStatus.todo;
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

  Map<String, dynamic> get configPreview {
    final trimmedName = name.text.trim();
    return {
      'name': trimmedName.isEmpty ? '(untitled)' : trimmedName,
      'description': desc.text.trim(),
      'status': status.name,
      'priority': priority.name,
      'tags': tags.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      'assignee': assigneeController.text.trim(),
      if (dueDate != null)
        'dueDate': '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}',
      'config': {
        'assignee': assigneeController.text.trim(),
      },
    };
  }

  String get jsonPreview {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(configPreview);
  }

  String get yamlPreview {
    return _toYaml(configPreview, 0);
  }

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
          buf.writeln('$pad${entry.key}: ${_yamlScalar(v)}');
        }
      }
      return buf.toString();
    } else if (value is List) {
      if (value.isEmpty) return '$pad[]\n';
      final buf = StringBuffer();
      for (final item in value) {
        if (item is Map || item is List) {
          buf.write('$pad-\n');
          buf.write(_toYaml(item, indent + 1));
        } else {
          buf.writeln('$pad- ${_yamlScalar(item)}');
        }
      }
      return buf.toString();
    }
    return '$pad${_yamlScalar(value)}\n';
  }

  String _yamlScalar(dynamic v) {
    if (v == null) return 'null';
    if (v is bool) return v ? 'true' : 'false';
    if (v is num) return '$v';
    final s = '$v';
    if (s.contains(':') || s.contains('#') || s.startsWith('{') || s.isEmpty) {
      return '"$s"';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.task == null;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? const Color(0xFF12121E) : cs.surface,
        child: Column(
          children: [
            // Header bar
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
                    tooltip: 'Close',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isNew ? context.l10n.newTaskDialog : context.l10n.editTaskDialog,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  // Preview toggle
                  _PreviewToggle(useYaml: useYaml, onToggle: (v) => setState(() => useYaml = v)),
                  const SizedBox(width: 12),
                  AppButton(
                    label: isNew ? context.l10n.createButton : context.l10n.saveButton,
                    onPressed: () {
                      if (name.text.trim().isEmpty) return;
                      final tagList = tags.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                      final t = widget.task?.copyWith(
                            name: name.text.trim(),
                            description: desc.text.trim(),
                            status: status,
                            priority: priority,
                            tags: tagList,
                            dueDate: dueDate,
                            config: {...(widget.task?.config ?? {}), 'assignee': assigneeController.text.trim()},
                          ) ??
                          Task(
                            id: const Uuid().v4(),
                            name: name.text.trim(),
                            description: desc.text.trim(),
                            status: status,
                            priority: priority,
                            tags: tagList,
                            dueDate: dueDate,
                            config: {'assignee': assigneeController.text.trim()},
                          );
                      widget.onSave(t);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Body: split or single column
            Expanded(
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: config preview
                        Expanded(
                          flex: 1,
                          child: _ConfigPreviewPane(
                            content: useYaml ? yamlPreview : jsonPreview,
                            useYaml: useYaml,
                            onToggle: (v) => setState(() => useYaml = v),
                          ),
                        ),
                        VerticalDivider(width: 1, color: cs.outline.withOpacity(0.15)),
                        // Right: fields
                        Expanded(
                          flex: 1,
                          child: _TaskFormPane(
                            name: name,
                            desc: desc,
                            tags: tags,
                            assigneeController: assigneeController,
                            status: status,
                            priority: priority,
                            dueDate: dueDate,
                            onStatusChanged: (v) => setState(() => status = v ?? status),
                            onPriorityChanged: (v) => setState(() => priority = v ?? priority),
                            onDueDateChanged: (v) => setState(() => dueDate = v),
                            onFieldChanged: () => setState(() {}),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _ConfigPreviewPane(
                            content: useYaml ? yamlPreview : jsonPreview,
                            useYaml: useYaml,
                            onToggle: (v) => setState(() => useYaml = v),
                          ),
                          const SizedBox(height: 16),
                          _TaskFormPane(
                            name: name,
                            desc: desc,
                            tags: tags,
                            assigneeController: assigneeController,
                            status: status,
                            priority: priority,
                            dueDate: dueDate,
                            onStatusChanged: (v) => setState(() => status = v ?? status),
                            onPriorityChanged: (v) => setState(() => priority = v ?? priority),
                            onDueDateChanged: (v) => setState(() => dueDate = v),
                            onFieldChanged: () => setState(() {}),
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

class _PreviewToggle extends StatelessWidget {
  final bool useYaml;
  final ValueChanged<bool> onToggle;
  const _PreviewToggle({required this.useYaml, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleChip(label: 'JSON', selected: !useYaml, onTap: () => onToggle(false), cs: cs),
        const SizedBox(width: 4),
        _ToggleChip(label: 'YAML', selected: useYaml, onTap: () => onToggle(true), cs: cs),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _ToggleChip({required this.label, required this.selected, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.primary.withOpacity(0.08),
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

class _ConfigPreviewPane extends StatelessWidget {
  final String content;
  final bool useYaml;
  final ValueChanged<bool> onToggle;
  const _ConfigPreviewPane({required this.content, required this.useYaml, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    return Container(
      color: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF5F5FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(Icons.data_object, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  useYaml ? 'YAML Preview' : 'JSON Preview',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                ),
                const Spacer(),
                _PreviewToggle(useYaml: useYaml, onToggle: onToggle),
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

class _TaskFormPane extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController desc;
  final TextEditingController tags;
  final TextEditingController assigneeController;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final ValueChanged<TaskStatus?> onStatusChanged;
  final ValueChanged<TaskPriority?> onPriorityChanged;
  final ValueChanged<DateTime?> onDueDateChanged;
  final VoidCallback onFieldChanged;

  const _TaskFormPane({
    required this.name,
    required this.desc,
    required this.tags,
    required this.assigneeController,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onDueDateChanged,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          AppInput(
            label: context.l10n.taskNameLabel,
            hint: context.l10n.taskNameHint,
            controller: name,
            onChanged: (_) => onFieldChanged(),
          ),
          const SizedBox(height: 12),
          AppInput(
            label: context.l10n.descriptionLabel,
            hint: context.l10n.descriptionHint,
            controller: desc,
            maxLines: 3,
            onChanged: (_) => onFieldChanged(),
          ),
          const SizedBox(height: 12),
          AppSelect<TaskStatus>(
            label: context.l10n.statusLabel,
            value: status,
            onChanged: onStatusChanged,
            items: TaskStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
          ),
          const SizedBox(height: 12),
          AppSelect<TaskPriority>(
            label: context.l10n.priorityLabel,
            value: priority,
            onChanged: onPriorityChanged,
            items: TaskPriority.values
                .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                .toList(),
          ),
          const SizedBox(height: 12),
          AppInput(
            label: context.l10n.tagsLabel,
            hint: context.l10n.tagsHint,
            controller: tags,
            onChanged: (_) => onFieldChanged(),
          ),
          const SizedBox(height: 12),
          AppInput(
            label: context.l10n.assigneeLabel,
            hint: context.l10n.assigneeHint,
            controller: assigneeController,
            onChanged: (_) => onFieldChanged(),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.dueDateLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dueDate != null
                          ? '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}'
                          : context.l10n.noDueDate,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(dueDate == null ? context.l10n.setDateButton : context.l10n.changeButton),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
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
        ],
      ),
    );
  }
}
