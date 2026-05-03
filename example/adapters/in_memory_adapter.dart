// Example in-memory adapters for FuzzyBoard.
//
// These implementations satisfy every abstract adapter interface using the
// built-in seed data from [lib/data/seed_data.dart].  They are intentionally
// kept in the `example/` folder because they will be removed and replaced by
// real back-end adapters (REST, database, …) later.
//
// Usage:
//   final adapters = InMemoryAdapters();
//   // then pass each concrete adapter to AppProvider (or a future AdapterRegistry)
//
// NOTE: this file lives outside `lib/` and therefore has NO package import
// path.  Reference it only via a relative path or copy it into your own
// package.  It is not part of the published package surface area.

import 'package:fuzzyboard/adapters/adapters.dart';
import 'package:fuzzyboard/data/seed_data.dart';
import 'package:fuzzyboard/models/chat_message.dart';
import 'package:fuzzyboard/models/plugin.dart';
import 'package:fuzzyboard/models/task.dart';
import 'package:fuzzyboard/models/worker.dart';
import 'package:fuzzyboard/models/workflow.dart';

// ── Task ──────────────────────────────────────────────────────────────────────

class InMemoryTaskAdapter implements TaskAdapter {
  final List<Task> _tasks = buildSeedTasks();

  @override
  List<Task> loadTasks() => List.of(_tasks);

  @override
  Future<void> saveTask(Task task) async => _tasks.add(task);

  @override
  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
  }

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.id == id);
}

// ── Workflow ──────────────────────────────────────────────────────────────────

class InMemoryWorkflowAdapter implements WorkflowAdapter {
  final List<Workflow> _workflows = buildSeedWorkflows();

  @override
  List<Workflow> loadWorkflows() => List.of(_workflows);

  @override
  Future<void> saveWorkflow(Workflow workflow) async =>
      _workflows.add(workflow);

  @override
  Future<void> updateWorkflow(Workflow workflow) async {
    final idx = _workflows.indexWhere((w) => w.id == workflow.id);
    if (idx != -1) _workflows[idx] = workflow;
  }

  @override
  Future<void> deleteWorkflow(String id) async =>
      _workflows.removeWhere((w) => w.id == id);
}

// ── Plugin ────────────────────────────────────────────────────────────────────

class InMemoryPluginAdapter implements PluginAdapter {
  final List<Plugin> _plugins = buildSeedPlugins();

  @override
  List<Plugin> loadPlugins() => List.of(_plugins);

  @override
  Future<void> installPlugin(String id) async {
    final idx = _plugins.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _plugins[idx].isInstalled = true;
      _plugins[idx].status = PluginStatus.active;
    }
  }

  @override
  Future<void> uninstallPlugin(String id) async {
    final idx = _plugins.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _plugins[idx].isInstalled = false;
      _plugins[idx].status = PluginStatus.inactive;
    }
  }
}

// ── Worker ────────────────────────────────────────────────────────────────────

class InMemoryWorkerAdapter implements WorkerAdapter {
  final List<Worker> _workers = buildSeedWorkers();

  @override
  List<Worker> loadWorkers() => List.of(_workers);

  @override
  Future<void> saveWorker(Worker worker) async => _workers.add(worker);

  @override
  Future<void> updateWorker(Worker worker) async {
    final idx = _workers.indexWhere((w) => w.id == worker.id);
    if (idx != -1) _workers[idx] = worker;
  }

  @override
  Future<void> deleteWorker(String id) async =>
      _workers.removeWhere((w) => w.id == id);
}

// ── Chat ──────────────────────────────────────────────────────────────────────

class InMemoryChatAdapter implements ChatAdapter {
  final List<ChatMessage> _messages = buildSeedChatMessages();

  @override
  List<ChatMessage> loadMessages() => List.of(_messages);

  @override
  Future<void> saveMessage(ChatMessage message) async =>
      _messages.add(message);

  @override
  Future<void> clearMessages() async => _messages.clear();
}

// ── Convenience bundle ────────────────────────────────────────────────────────

/// Groups all five in-memory adapters so they can be passed around together.
class InMemoryAdapters {
  final InMemoryTaskAdapter tasks = InMemoryTaskAdapter();
  final InMemoryWorkflowAdapter workflows = InMemoryWorkflowAdapter();
  final InMemoryPluginAdapter plugins = InMemoryPluginAdapter();
  final InMemoryWorkerAdapter workers = InMemoryWorkerAdapter();
  final InMemoryChatAdapter chat = InMemoryChatAdapter();
}
