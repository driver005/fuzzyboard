import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_typography.dart';
import '../../models/task.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_input.dart';
import '../../shared/widgets/tutorial_banner.dart';

/// Visual SQL Query Builder
class SqlBuilderPage extends StatefulWidget {
  const SqlBuilderPage({super.key});

  @override
  State<SqlBuilderPage> createState() => _SqlBuilderPageState();
}

class _SqlBuilderPageState extends State<SqlBuilderPage> {
  // Builder state
  String _selectedTable = 'users';
  final List<_Column> _selectedColumns = [];
  final List<_WhereClause> _whereClauses = [];
  String? _orderByColumn;
  bool _orderAsc = true;
  int? _limit;

  final _tables = ['users', 'orders', 'products', 'logs', 'tasks'];
  final _tableColumns = {
    'users': ['id', 'name', 'email', 'created_at', 'status', 'role'],
    'orders': ['id', 'user_id', 'total', 'status', 'created_at'],
    'products': ['id', 'name', 'price', 'stock', 'category'],
    'logs': ['id', 'level', 'message', 'timestamp', 'source'],
    'tasks': ['id', 'name', 'status', 'priority', 'due_date'],
  };

  String build_query() {
    final cols = _selectedColumns.isEmpty
        ? '*'
        : _selectedColumns.map((c) => c.name).join(', ');
    var q = 'SELECT $cols\nFROM $_selectedTable';
    if (_whereClauses.isNotEmpty) {
      final conditions = _whereClauses
          .map((w) => '  ${w.column} ${w.op} ${w.quoted ? "'${w.value}'" : w.value}')
          .join('\n  AND ');
      q += '\nWHERE\n$conditions';
    }
    if (_orderByColumn != null) {
      q += '\nORDER BY $_orderByColumn ${_orderAsc ? 'ASC' : 'DESC'}';
    }
    if (_limit != null) {
      q += '\nLIMIT $_limit';
    }
    q += ';';
    return q;
  }

  void toggle_column(String col) {
    setState(() {
      final idx = _selectedColumns.indexWhere((c) => c.name == col);
      if (idx >= 0) {
        _selectedColumns.removeAt(idx);
      } else {
        _selectedColumns.add(_Column(col));
      }
    });
  }

  void add_where_clause() {
    final cols = _tableColumns[_selectedTable] ?? [];
    setState(() {
      _whereClauses.add(_WhereClause(
        column: cols.isNotEmpty ? cols.first : 'id',
        op: '=',
        value: '',
      ));
    });
  }

  void show_save_as_task_dialog(BuildContext context) {
    final nameController = TextEditingController(
        text: 'Query $_selectedTable');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.saveTaskTitle),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctx.l10n.saveTaskMessage,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
              ),
              const SizedBox(height: 16),
              AppInput(
                label: ctx.l10n.taskNameInputLabel,
                hint: ctx.l10n.sqlTaskNamePlaceholder,
                controller: nameController,
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            label: ctx.l10n.cancelButton,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          AppButton(
            label: ctx.l10n.createTaskButton,
            icon: const Icon(Icons.add_task),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final task = Task(
                id: const Uuid().v4(),
                name: name,
                description: build_query(),
                status: TaskStatus.todo,
                priority: TaskPriority.medium,
                tags: ['sql', _selectedTable],
                config: {
                  'source': 'sql_builder',
                  'table': _selectedTable,
                },
              );
              context.read<AppProvider>().addTask(task);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.taskCreatedSnackbar(name)),
                  action: SnackBarAction(
                    label: context.l10n.viewTasksAction,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).then((_) => nameController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final availableCols = _tableColumns[_selectedTable] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.sqlBuilderTitle),
        actions: [
          AppButton(
            label: context.l10n.copySqlButton,
            icon: const Icon(Icons.copy),
            size: AppButtonSize.sm,
            variant: AppButtonVariant.outline,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: build_query()));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.sqlCopiedSnackbar)),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          AppButton(
            label: context.l10n.saveAsTaskButton,
            icon: const Icon(Icons.add_task),
            size: AppButtonSize.sm,
            onPressed: () => show_save_as_task_dialog(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 700;
          return wide
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          const TutorialBanner(
                            title: 'SQL Visual Builder',
                            emoji: '🗄️',
                            steps: [
                              'Pick a table in the FROM section — columns will update automatically.',
                              'Toggle the columns you want in SELECT. No selection means SELECT *.',
                              'Add WHERE conditions to filter rows by column value.',
                              'Optionally set ORDER BY and LIMIT to sort and cap results.',
                              'The generated SQL updates live. Copy it or save it directly as a Task.',
                            ],
                          ),
                          Expanded(child: build_left_panel(availableCols)),
                        ],
                      ),
                    ),
                    VerticalDivider(
                        width: 1,
                        color: cs.outline.withOpacity(0.2)),
                    Expanded(flex: 2, child: build_query_panel()),
                  ],
                )
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TutorialBanner(
                        title: 'SQL Visual Builder',
                        emoji: '🗄️',
                        steps: [
                          'Pick a table in FROM, toggle SELECT columns, add WHERE conditions.',
                          'Set ORDER BY and LIMIT. The Query tab shows the generated SQL.',
                          'Use "Save as Task" to create a task from the current query.',
                        ],
                      ),
                      TabBar(tabs: const [
                        Tab(text: 'Builder'),
                        Tab(text: 'Query'),
                      ]),
                      Expanded(
                        child: TabBarView(children: [
                          build_left_panel(availableCols),
                          build_query_panel(),
                        ]),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget build_left_panel(List<String> cols) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // FROM table
        AppCard(
          title: context.l10n.fromTableSection,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tables
                .map((t) => _ToggleChip(
                      label: t,
                      selected: _selectedTable == t,
                      onTap: () => setState(() {
                        _selectedTable = t;
                        _selectedColumns.clear();
                        _whereClauses.clear();
                        _orderByColumn = null;
                      }),
                    ))
                .toList(),
          ),
        ).animate().fadeIn(delay: 50.ms),
        const SizedBox(height: 12),
        // SELECT columns
        AppCard(
          title: context.l10n.selectColumnsSection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cols
                    .map((c) => _ToggleChip(
                          label: c,
                          selected:
                              _selectedColumns.any((sc) => sc.name == c),
                          onTap: () => toggle_column(c),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              if (_selectedColumns.isEmpty)
                Text(context.l10n.allColumnsSelected,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4))),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 12),
        // WHERE clauses
        AppCard(
          title: context.l10n.whereClausesSection,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: add_where_clause,
              visualDensity: VisualDensity.compact,
            ),
          ],
          child: Column(
            children: [
              ..._whereClauses.asMap().entries.map((e) {
                final w = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _WhereRow(
                    clause: w,
                    columns: cols,
                    onChanged: (_) => setState(() {}),
                    onDelete: () =>
                        setState(() => _whereClauses.removeAt(e.key)),
                  ),
                );
              }),
              if (_whereClauses.isEmpty)
                Text('No conditions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4))),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 12),
        // ORDER BY
        AppCard(
          title: context.l10n.orderBySection,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _orderByColumn,
                    hint: Text(context.l10n.chooseColumnDropdown),
                    items: [
                      DropdownMenuItem<String>(
                          value: null, child: Text(context.l10n.noneOption)),
                      ...cols.map((c) =>
                          DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) =>
                        setState(() => _orderByColumn = v),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ToggleButtons(
                isSelected: [_orderAsc, !_orderAsc],
                onPressed: (i) =>
                    setState(() => _orderAsc = i == 0),
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ASC'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('DESC'),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        // LIMIT
        AppCard(
          title: context.l10n.limitSection,
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: (_limit ?? 0).toDouble(),
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  label: _limit == null || _limit == 0
                      ? context.l10n.noLimitLabel
                      : context.l10n.limitRowsLabel(_limit!),
                  onChanged: (v) => setState(
                      () => _limit = v == 0 ? null : v.toInt()),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  _limit == null ? '∞' : '$_limit',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 250.ms),
      ],
    );
  }

  Widget build_query_panel() {
    final isDark =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(context.l10n.generatedSqlLabel,
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(context.l10n.previewBadge,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF5F5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              build_query(),
              style: AppTypography.mono.copyWith(
                color: const Color(0xFF10B981),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Column {
  final String name;
  _Column(this.name);
}

class _WhereClause {
  String column;
  String op;
  String value;
  bool quoted;

  _WhereClause({
    required this.column,
    required this.op,
    required this.value,
    this.quoted = true,
  });
}

class _WhereRow extends StatelessWidget {
  final _WhereClause clause;
  final List<String> columns;
  final ValueChanged<_WhereClause> onChanged;
  final VoidCallback onDelete;

  const _WhereRow({
    required this.clause,
    required this.columns,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const ops = ['=', '!=', '>', '<', '>=', '<=', 'LIKE', 'IN'];

    return Row(
      children: [
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: clause.column,
              isExpanded: true,
              items: columns
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                clause.column = v ?? clause.column;
                onChanged(clause);
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 70,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: clause.op,
              items: ops
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) {
                clause.op = v ?? clause.op;
                onChanged(clause);
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'value',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
              filled: true,
            ),
            onChanged: (v) {
              clause.value = v;
              onChanged(clause);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 16),
          onPressed: onDelete,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? cs.onPrimary : cs.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
