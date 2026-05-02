import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../models/plugin.dart';
import '../../models/task.dart';
import '../../models/workflow.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_input.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final q = query.toLowerCase();

    final tasks = q.isEmpty ? <Task>[] : app.tasks.where((t) => t.name.toLowerCase().contains(q) || t.description.toLowerCase().contains(q)).toList();
    final workflows = q.isEmpty ? <Workflow>[] : app.workflows.where((w) => w.name.toLowerCase().contains(q) || w.description.toLowerCase().contains(q)).toList();
    final plugins = q.isEmpty ? <Plugin>[] : app.plugins.where((p) => p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q)).toList();

    final hasResults = tasks.isNotEmpty || workflows.isNotEmpty || plugins.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppInput(
            controller: controller,
            hint: 'Search tasks, workflows & plugins…',
            prefix: const Icon(Icons.search),
            autofocus: true,
            onChanged: (v) => setState(() => query = v),
          ),
        ),
        Expanded(
          child: q.isEmpty
              ? _emptyState(context)
              : !hasResults
                  ? Center(child: Text('No results for "$q"', style: Theme.of(context).textTheme.bodyMedium))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        if (tasks.isNotEmpty) ...[
                          _sectionHeader(context, Icons.task_alt, 'Tasks'),
                          ...tasks.asMap().entries.map((e) => _resultTile(context, e.value.name, e.value.description, Icons.task_alt, const Color(0xFF6C63FF), e.key)),
                        ],
                        if (workflows.isNotEmpty) ...[
                          _sectionHeader(context, Icons.account_tree, 'Workflows'),
                          ...workflows.asMap().entries.map((e) => _resultTile(context, e.value.name, e.value.description, Icons.account_tree, const Color(0xFF10B981), e.key)),
                        ],
                        if (plugins.isNotEmpty) ...[
                          _sectionHeader(context, Icons.extension, 'Plugins'),
                          ...plugins.asMap().entries.map((e) => _resultTile(context, e.value.name, e.value.description, Icons.extension, const Color(0xFF3B82F6), e.key)),
                        ],
                      ],
                    ),
        ),
      ]),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search, size: 64, color: Colors.grey.withOpacity(0.4)),
        const SizedBox(height: 16),
        Text('Search tasks, workflows & plugins', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      ]),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
      ]),
    );
  }

  Widget _resultTile(BuildContext context, String title, String subtitle, IconData icon, Color color, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        title: title,
        subtitle: subtitle,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opened: $title'))),
      ).animate(delay: Duration(milliseconds: index * 60)).fadeIn().slideX(begin: 0.1),
    );
  }
}
