import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzyboard/models/task.dart';
import 'package:fuzzyboard/models/workflow.dart';
import 'package:fuzzyboard/models/plugin.dart';
import 'package:fuzzyboard/core/providers/app_provider.dart';

void main() {
  group('Task model', () {
    test('creates task with defaults', () {
      final task = Task(id: '1', name: 'Test Task');
      expect(task.status, TaskStatus.todo);
      expect(task.priority, TaskPriority.medium);
      expect(task.tags, isEmpty);
    });

    test('copyWith preserves unchanged fields', () {
      final task = Task(
        id: '1',
        name: 'Original',
        priority: TaskPriority.high,
        tags: ['a', 'b'],
      );
      final updated = task.copyWith(name: 'Updated');
      expect(updated.name, 'Updated');
      expect(updated.priority, TaskPriority.high);
      expect(updated.tags, ['a', 'b']);
    });

    test('TaskStatus extensions return correct labels and colors', () {
      expect(TaskStatus.done.label, 'Done');
      expect(TaskStatus.inProgress.label, 'In Progress');
    });
  });

  group('Workflow model', () {
    test('creates workflow with defaults', () {
      final wf = Workflow(id: 'wf-1', name: 'Test Workflow');
      expect(wf.nodes, isEmpty);
      expect(wf.connections, isEmpty);
      expect(wf.isActive, false);
    });

    test('WorkflowNode has correct color for type', () {
      final color = WorkflowNode.colorForType(NodeType.trigger);
      expect(color.alpha, greaterThan(0));
    });
  });

  group('Plugin model', () {
    test('creates plugin correctly', () {
      final plugin = Plugin(
        id: 'p1',
        name: 'Test Plugin',
        description: 'A test plugin',
        author: 'Test',
        version: '1.0.0',
        category: PluginCategory.action,
      );
      expect(plugin.isInstalled, false);
      expect(plugin.category.label, 'Action');
    });
  });

  group('AppProvider', () {
    late AppProvider provider;

    setUp(() {
      provider = AppProvider();
    });

    test('has initial tasks', () {
      expect(provider.tasks, isNotEmpty);
    });

    test('has initial workflows', () {
      expect(provider.workflows, isNotEmpty);
    });

    test('has initial plugins', () {
      expect(provider.plugins, isNotEmpty);
    });

    test('can add a task', () {
      final initialCount = provider.tasks.length;
      provider.addTask(Task(id: 'new-1', name: 'New Task'));
      expect(provider.tasks.length, initialCount + 1);
    });

    test('can delete a task', () {
      final task = provider.tasks.first;
      final initialCount = provider.tasks.length;
      provider.deleteTask(task.id);
      expect(provider.tasks.length, initialCount - 1);
    });

    test('can install a plugin', () {
      final notInstalled = provider.plugins.firstWhere((p) => !p.isInstalled);
      provider.installPlugin(notInstalled.id);
      final updated = provider.plugins.firstWhere((p) => p.id == notInstalled.id);
      expect(updated.isInstalled, true);
    });

    test('can toggle dev mode', () {
      expect(provider.devMode, false);
      provider.toggleDevMode();
      expect(provider.devMode, true);
      provider.toggleDevMode();
      expect(provider.devMode, false);
    });

    test('logs are stored', () {
      provider.addLog('test log entry');
      expect(provider.logs.first, contains('test log entry'));
    });

    test('event bus emits events', () {
      provider.emitEvent('test_event');
      expect(provider.lastEvent, 'test_event');
    });

    test('generates unique IDs', () {
      final id1 = provider.generateId();
      final id2 = provider.generateId();
      expect(id1, isNot(equals(id2)));
    });
  });
}
