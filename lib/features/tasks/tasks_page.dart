import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/app_provider.dart';
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
  String _search = '';
  TaskStatus? _filterStatus;
  TaskPriority? filterPriority;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final tasks = app.tasks.where((t) {
      if (_search.isNotEmpty &&
          !t.name.toLowerCase().contains(_search.toLowerCase()) &&
          !t.description.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      if (_filterStatus != null && t.status != _filterStatus) return false;
      if (filterPriority != null && t.priority != filterPriority) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          AppButton(
            label: 'New Task',
            icon: const Icon(Icons.add),
            size: AppButtonSize.sm,
            onPressed: () => _showTaskDialog(context),
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
                    hint: 'Search tasks...',
                    prefix: const Icon(Icons.search, size: 18),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusFilter(
                  value: _filterStatus,
                  onChanged: (s) => setState(() => _filterStatus = s),
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
                    label: const Text('All'),
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

  void _showTaskDialog(BuildContext context, [Task? task]) {
    showDialog(
      context: context,
      builder: (ctx) => _TaskDialog(
        task: task,
        onSave: (t) {
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
            color: isDragOver ? widget.status.color.withValues(alpha: 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isDragOver ? Border.all(color: widget.status.color.withValues(alpha: 0.3), width: 1.5) : null,
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
                      decoration: BoxDecoration(color: widget.status.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: Text('${widget.tasks.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.status.color)),
                    ),
                  ],
                ),
              ),
              if (widget.tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 18),
                  child: Text('No tasks', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
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

  bool _isOverdue(Task t) => t.dueDate != null && t.dueDate!.isBefore(DateTime.now()) && t.status != TaskStatus.done;

  String _formatDue(DateTime d) {
    final now = DateTime.now();
    final diff = d.difference(now);
    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    if (diff.inDays == -1) return 'Overdue 1d';
    if (diff.inDays < 0) return 'Overdue ${(-diff.inDays)}d';
    return 'Due in ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.read<AppProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => _showTaskDialog(context, task),
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
                          label: _formatDue(task.dueDate!),
                          color: _isOverdue(task) ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
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
                  _showTaskDialog(context, task);
                } else if (v == 'delete') {
                  app.deleteTask(task.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => _TaskDialog(
        task: task,
        onSave: (t) => context.read<AppProvider>().updateTask(t),
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
          Text(value?.label ?? 'All',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      onSelected: onChanged,
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All')),
        ...TaskStatus.values
            .map((s) => PopupMenuItem(value: s, child: Text(s.label))),
      ],
    );
  }
}

class _TaskDialog extends StatefulWidget {
  final Task? task;
  final void Function(Task) onSave;

  const _TaskDialog({this.task, required this.onSave});

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late TextEditingController _name;
  late TextEditingController _desc;
  late TextEditingController _tags;
  late TextEditingController assigneeController;
  late TaskStatus _status;
  late TaskPriority _priority;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.task?.name ?? '');
    _desc = TextEditingController(text: widget.task?.description ?? '');
    _tags = TextEditingController(
        text: widget.task?.tags.join(', ') ?? '');
    assigneeController = TextEditingController(text: widget.task?.config['assignee'] as String? ?? '');
    _status = widget.task?.status ?? TaskStatus.todo;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _tags.dispose();
    assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.task == null;
    return AlertDialog(
      title: Text(isNew ? 'New Task' : 'Edit Task'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInput(
                  label: 'Name',
                  hint: 'Task name',
                  controller: _name),
              const SizedBox(height: 12),
              AppInput(
                  label: 'Description',
                  hint: 'What does this task do?',
                  controller: _desc,
                  maxLines: 3),
              const SizedBox(height: 12),
              AppSelect<TaskStatus>(
                label: 'Status',
                value: _status,
                onChanged: (v) => setState(() => _status = v ?? _status),
                items: TaskStatus.values
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text(s.label)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              AppSelect<TaskPriority>(
                label: 'Priority',
                value: _priority,
                onChanged: (v) =>
                    setState(() => _priority = v ?? _priority),
                items: TaskPriority.values
                    .map((p) => DropdownMenuItem(
                        value: p, child: Text(p.label)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              AppInput(
                  label: 'Tags',
                  hint: 'email, crm, api',
                  controller: _tags),
              const SizedBox(height: 12),
              AppInput(label: 'Assignee', hint: 'username or email', controller: assigneeController),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Due Date', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                      child: Text(
                        dueDate != null
                            ? '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}'
                            : 'No due date',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(dueDate == null ? 'Set date' : 'Change'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => dueDate = picked);
                      },
                    ),
                    if (dueDate != null)
                      IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => dueDate = null)),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: isNew ? 'Create' : 'Save',
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            final tags = _tags.text
                .split(',')
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList();
            final t = widget.task?.copyWith(
                  name: _name.text.trim(),
                  description: _desc.text.trim(),
                  status: _status,
                  priority: _priority,
                  tags: tags,
                  dueDate: dueDate,
                  config: {...(widget.task?.config ?? {}), 'assignee': assigneeController.text.trim()},
                ) ??
                Task(
                  id: const Uuid().v4(),
                  name: _name.text.trim(),
                  description: _desc.text.trim(),
                  status: _status,
                  priority: _priority,
                  tags: tags,
                  dueDate: dueDate,
                  config: {'assignee': assigneeController.text.trim()},
                );
            widget.onSave(t);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
