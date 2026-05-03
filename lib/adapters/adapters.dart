import '../models/task.dart';
import '../models/workflow.dart';
import '../models/plugin.dart';
import '../models/worker.dart';
import '../models/chat_message.dart';

// ── Task adapter ──────────────────────────────────────────────────────────────

/// Provides CRUD access to [Task] records.
/// Implement this class to plug in any persistence back-end (REST, GraphQL,
/// local DB, in-memory, …) without touching [AppProvider].
abstract class TaskAdapter {
  /// Returns the current list of tasks. Implementations may return a live list
  /// that is mutated in-place or a snapshot; [AppProvider] always copies.
  List<Task> loadTasks();

  /// Persists a newly created [task].
  Future<void> saveTask(Task task);

  /// Persists an updated [task].
  Future<void> updateTask(Task task);

  /// Removes the task identified by [id].
  Future<void> deleteTask(String id);
}

// ── Workflow adapter ──────────────────────────────────────────────────────────

/// Provides CRUD access to [Workflow] records.
abstract class WorkflowAdapter {
  List<Workflow> loadWorkflows();
  Future<void> saveWorkflow(Workflow workflow);
  Future<void> updateWorkflow(Workflow workflow);
  Future<void> deleteWorkflow(String id);
}

// ── Plugin adapter ────────────────────────────────────────────────────────────

/// Provides CRUD access to [Plugin] records and install/uninstall lifecycle.
abstract class PluginAdapter {
  List<Plugin> loadPlugins();
  Future<void> installPlugin(String id);
  Future<void> uninstallPlugin(String id);
}

// ── Worker adapter ────────────────────────────────────────────────────────────

/// Provides CRUD access to [Worker] records.
abstract class WorkerAdapter {
  List<Worker> loadWorkers();
  Future<void> saveWorker(Worker worker);
  Future<void> updateWorker(Worker worker);
  Future<void> deleteWorker(String id);
}

// ── Chat adapter ──────────────────────────────────────────────────────────────

/// Provides access to chat history.
abstract class ChatAdapter {
  List<ChatMessage> loadMessages();
  Future<void> saveMessage(ChatMessage message);
  Future<void> clearMessages();
}
