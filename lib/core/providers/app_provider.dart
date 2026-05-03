import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/seed_data.dart';
import '../../models/task.dart';
import '../../models/task_run.dart';
import '../../models/workflow.dart';
import '../../models/plugin.dart';
import '../../models/chat_message.dart';
import '../../models/page_widget.dart';
import '../../models/workflow_run.dart';
import '../../models/worker.dart';

/// Top-level application state provider.
class AppProvider extends ChangeNotifier {
  final uuid = const Uuid();

  AppProvider() {
    loadSettings();
  }

  // ── Settings flags ────────────────────────────────────────────────────────
  bool _showAvatar = true;
  bool _reducedMotion = false;
  bool _verboseLogging = false;
  bool _autoSave = true;

  bool get showAvatar => _showAvatar;
  bool get reducedMotion => _reducedMotion;
  bool get verboseLogging => _verboseLogging;
  bool get autoSave => _autoSave;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _showAvatar = prefs.getBool('showAvatar') ?? true;
    _reducedMotion = prefs.getBool('reducedMotion') ?? false;
    _verboseLogging = prefs.getBool('verboseLogging') ?? false;
    _autoSave = prefs.getBool('autoSave') ?? true;
    notifyListeners();
  }

  Future<void> setShowAvatar(bool v) async {
    _showAvatar = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showAvatar', v);
  }

  Future<void> setReducedMotion(bool v) async {
    _reducedMotion = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reducedMotion', v);
  }

  Future<void> setVerboseLogging(bool v) async {
    _verboseLogging = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('verboseLogging', v);
  }

  Future<void> setAutoSave(bool v) async {
    _autoSave = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSave', v);
  }

  // ── Event bus ─────────────────────────────────────────────────────────────
  String _lastEvent = '';
  String get lastEvent => _lastEvent;
  void emitEvent(String event) {
    _lastEvent = event;
    notifyListeners();
  }

  // ── Dev Mode ──────────────────────────────────────────────────────────────
  bool _devMode = false;
  bool get devMode => _devMode;
  void toggleDevMode() {
    _devMode = !_devMode;
    emitEvent('dev_mode_${_devMode ? 'on' : 'off'}');
  }

  final List<String> _logs = [];
  List<String> get logs => List.unmodifiable(_logs);
  void addLog(String msg) {
    _logs.insert(0, '[${DateTime.now().toIso8601String()}] $msg');
    if (_logs.length > 500) _logs.removeLast();
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────
  final List<Task> _tasks = buildSeedTasks();

  List<Task> get tasks => List.unmodifiable(_tasks);

  void addTask(Task task) {
    _tasks.add(task);
    addLog('Task created: ${task.name}');
    emitEvent('task_created');
  }

  void updateTask(Task task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      addLog('Task updated: ${task.name}');
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    addLog('Task deleted: $id');
    emitEvent('task_deleted');
  }

  // ── Task Runs ─────────────────────────────────────────────────────────────
  final List<TaskRun> _taskRuns = buildSeedTaskRuns();

  List<TaskRun> get taskRuns => List.unmodifiable(_taskRuns);

  void addTaskRun(TaskRun run) {
    _taskRuns.insert(0, run);
    addLog('Task run started: ${run.taskName}');
    notifyListeners();
  }

  void updateTaskRun(TaskRun run) {
    final idx = _taskRuns.indexWhere((r) => r.id == run.id);
    if (idx != -1) {
      _taskRuns[idx] = run;
      notifyListeners();
    }
  }

  List<TaskRun> runsForTask(String taskId) =>
      _taskRuns.where((r) => r.taskId == taskId).toList();

  String generateId() => uuid.v4();

  // ── Workflows ─────────────────────────────────────────────────────────────
  final List<Workflow> _workflows = buildSeedWorkflows();

  List<Workflow> get workflows => List.unmodifiable(_workflows);

  void addWorkflow(Workflow wf) {
    _workflows.add(wf);
    addLog('Workflow created: ${wf.name}');
    emitEvent('workflow_created');
  }

  void updateWorkflow(Workflow wf) {
    final idx = _workflows.indexWhere((w) => w.id == wf.id);
    if (idx != -1) {
      _workflows[idx] = wf;
      addLog('Workflow updated: ${wf.name}');
      notifyListeners();
    }
  }

  void deleteWorkflow(String id) {
    _workflows.removeWhere((w) => w.id == id);
    addLog('Workflow deleted: $id');
    emitEvent('workflow_deleted');
  }

  void toggleWorkflow(String id) {
    final idx = _workflows.indexWhere((w) => w.id == id);
    if (idx != -1) {
      _workflows[idx].isActive = !_workflows[idx].isActive;
      addLog(
          'Workflow ${_workflows[idx].name} ${_workflows[idx].isActive ? 'activated' : 'deactivated'}');
      emitEvent('workflow_toggled');
      if (_workflows[idx].isActive) {
        final runId = uuid.v4();
        addWorkflowRun(WorkflowRun(
          id: runId,
          workflowId: id,
          startedAt: DateTime.now(),
          status: WorkflowRunStatus.running,
        ));
        _workflows[idx].runCount++;
        Future.delayed(const Duration(seconds: 2), () {
          completeWorkflowRun(runId, WorkflowRunStatus.success);
        });
      }
    }
  }

  // ── Plugins ───────────────────────────────────────────────────────────────
  final List<Plugin> _plugins = buildSeedPlugins();

  List<Plugin> get plugins => List.unmodifiable(_plugins);
  List<Plugin> get installedPlugins => _plugins.where((p) => p.isInstalled).toList();

  void installPlugin(String id) {
    final idx = _plugins.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _plugins[idx].isInstalled = true;
      _plugins[idx].status = PluginStatus.active;
      addLog('Plugin installed: ${_plugins[idx].name}');
      emitEvent('plugin_installed');
    }
  }

  void uninstallPlugin(String id) {
    final idx = _plugins.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _plugins[idx].isInstalled = false;
      _plugins[idx].status = PluginStatus.inactive;
      addLog('Plugin uninstalled: ${_plugins[idx].name}');
      emitEvent('plugin_uninstalled');
    }
  }

  void updatePlugin(Plugin plugin) {
    final idx = _plugins.indexWhere((p) => p.id == plugin.id);
    if (idx != -1) {
      _plugins[idx] = plugin;
      addLog('Plugin config updated: ${plugin.name}');
      notifyListeners();
    }
  }

  // ── Chat Messages ─────────────────────────────────────────────────────────
  final List<ChatMessage> chatMessages = buildSeedChatMessages();

  void addChatMessage(ChatMessage message) {
    chatMessages.add(message);
    notifyListeners();
  }

  void clearChat() {
    chatMessages.clear();
    notifyListeners();
  }

  // ── Voice Commands ────────────────────────────────────────────────────────
  final List<String> voiceCommands = List.of(seedVoiceCommands);

  void addVoiceCommand(String command) {
    voiceCommands.insert(0, command);
    if (voiceCommands.length > 50) voiceCommands.removeLast();
    notifyListeners();
  }

  // ── Page Widgets ──────────────────────────────────────────────────────────
  final List<PageWidget> pageWidgets = [];

  void addPageWidget(PageWidget widget) {
    pageWidgets.add(widget);
    notifyListeners();
  }

  void removePageWidget(String id) {
    pageWidgets.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  void reorderPageWidget(int oldIndex, int newIndex) {
    final widget = pageWidgets.removeAt(oldIndex);
    pageWidgets.insert(newIndex, widget);
    notifyListeners();
  }

  // ── Workers ───────────────────────────────────────────────────────────────
  final List<Worker> _workers = buildSeedWorkers();

  List<Worker> get workers => List.unmodifiable(_workers);

  void addWorker(Worker w) {
    _workers.add(w);
    addLog('Worker added: ${w.name}');
    notifyListeners();
  }

  void updateWorker(Worker w) {
    final idx = _workers.indexWhere((worker) => worker.id == w.id);
    if (idx != -1) {
      _workers[idx] = w;
      notifyListeners();
    }
  }

  void deleteWorker(String id) {
    _workers.removeWhere((w) => w.id == id);
    addLog('Worker deleted: $id');
    notifyListeners();
  }

  void toggleWorker(String id) {
    final idx = _workers.indexWhere((w) => w.id == id);
    if (idx != -1) {
      final w = _workers[idx];
      w.status = w.status == WorkerStatus.running
          ? WorkerStatus.stopped
          : WorkerStatus.running;
      addLog('Worker ${w.name} ${w.status.label}');
      notifyListeners();
    }
  }

  // ── App Config ────────────────────────────────────────────────────────────
  Map<String, dynamic> appConfig = {
    'maxConcurrency': 10,
    'logLevel': 'info',
    'apiBaseUrl': 'https://api.fuzzyboard.io',
    'timezone': 'UTC',
  };

  void updateAppConfig(String key, dynamic value) {
    appConfig[key] = value;
    notifyListeners();
  }

  // ── Workflow Runs ─────────────────────────────────────────────────────────
  final List<WorkflowRun> workflowRuns = [];

  List<WorkflowRun> runsForWorkflow(String workflowId) =>
      workflowRuns.where((r) => r.workflowId == workflowId).toList();

  void addWorkflowRun(WorkflowRun run) {
    workflowRuns.insert(0, run);
    notifyListeners();
  }

  void completeWorkflowRun(String runId, WorkflowRunStatus status) {
    final idx = workflowRuns.indexWhere((r) => r.id == runId);
    if (idx == -1) return;
    workflowRuns[idx].status = status;
    notifyListeners();
  }
}
