import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/task.dart';
import '../../models/workflow.dart';
import '../../models/plugin.dart';
import '../../models/chat_message.dart';
import '../../models/page_widget.dart';
import '../../models/workflow_run.dart';
import '../../models/worker.dart';

/// Top-level application state provider.
class AppProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  AppProvider() {
    load_settings();
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

  Future<void> load_settings() async {
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
  final List<Task> _tasks = [
    Task(
      id: 'task-1',
      name: 'Send Welcome Email',
      description: 'Trigger a welcome email when a user signs up.',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      tags: ['email', 'onboarding'],
    ),
    Task(
      id: 'task-2',
      name: 'Process Payment',
      description: 'Validate and process payment via Stripe.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.critical,
      tags: ['payment', 'stripe'],
    ),
    Task(
      id: 'task-3',
      name: 'Generate Report',
      description: 'Compile weekly analytics report from DB.',
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      tags: ['analytics'],
    ),
    Task(
      id: 'task-4',
      name: 'Sync CRM Data',
      description: 'Synchronize customer data to external CRM.',
      status: TaskStatus.todo,
      priority: TaskPriority.low,
      tags: ['crm', 'sync'],
    ),
  ];

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

  String generateId() => _uuid.v4();

  // ── Workflows ─────────────────────────────────────────────────────────────
  final List<Workflow> _workflows = [
    Workflow(
      id: 'wf-1',
      name: 'User Onboarding',
      description: 'Automates the full user onboarding flow.',
      isActive: true,
      runCount: 142,
      nodes: [
        WorkflowNode(
          id: 'n1',
          label: 'New Signup',
          type: NodeType.trigger,
          position: const Offset(80, 160),
        ),
        WorkflowNode(
          id: 'n2',
          label: 'Send Welcome Email',
          type: NodeType.action,
          position: const Offset(300, 160),
        ),
        WorkflowNode(
          id: 'n3',
          label: 'Wait 1 day',
          type: NodeType.delay,
          position: const Offset(520, 160),
        ),
        WorkflowNode(
          id: 'n4',
          label: 'Profile Complete?',
          type: NodeType.condition,
          position: const Offset(740, 160),
        ),
        WorkflowNode(
          id: 'n5',
          label: 'Send Reminder',
          type: NodeType.action,
          position: const Offset(960, 280),
        ),
        WorkflowNode(
          id: 'n6',
          label: 'Done',
          type: NodeType.end,
          position: const Offset(960, 60),
        ),
      ],
      connections: [
        WorkflowConnection(id: 'c1', fromNodeId: 'n1', toNodeId: 'n2'),
        WorkflowConnection(id: 'c2', fromNodeId: 'n2', toNodeId: 'n3'),
        WorkflowConnection(id: 'c3', fromNodeId: 'n3', toNodeId: 'n4'),
        WorkflowConnection(
            id: 'c4',
            fromNodeId: 'n4',
            toNodeId: 'n6',
            type: ConnectionType.success,
            label: 'Yes'),
        WorkflowConnection(
            id: 'c5',
            fromNodeId: 'n4',
            toNodeId: 'n5',
            type: ConnectionType.failure,
            label: 'No'),
      ],
    ),
    Workflow(
      id: 'wf-2',
      name: 'Payment Processing',
      description: 'Handles payment flow and failure recovery.',
      isActive: false,
      runCount: 89,
    ),
  ];

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
        final runId = _uuid.v4();
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
  final List<Plugin> _plugins = [
    Plugin(
      id: 'pg-1',
      name: 'HTTP Request',
      description: 'Make HTTP requests to any endpoint.',
      author: 'FuzzyBoard',
      version: '1.0.0',
      category: PluginCategory.action,
      status: PluginStatus.active,
      isInstalled: true,
      rating: 4.8,
      downloadCount: 12400,
      iconEmoji: '🌐',
    ),
    Plugin(
      id: 'pg-2',
      name: 'Cron Trigger',
      description: 'Schedule workflows with cron expressions.',
      author: 'FuzzyBoard',
      version: '1.2.1',
      category: PluginCategory.trigger,
      status: PluginStatus.active,
      isInstalled: true,
      rating: 4.9,
      downloadCount: 9800,
      iconEmoji: '⏰',
    ),
    Plugin(
      id: 'pg-3',
      name: 'Slack Notifier',
      description: 'Send Slack messages from your workflows.',
      author: 'Community',
      version: '2.0.0',
      category: PluginCategory.integration,
      isInstalled: false,
      rating: 4.5,
      downloadCount: 7200,
      iconEmoji: '💬',
    ),
    Plugin(
      id: 'pg-4',
      name: 'PostgreSQL',
      description: 'Query and write to PostgreSQL databases.',
      author: 'FuzzyBoard',
      version: '1.5.0',
      category: PluginCategory.integration,
      status: PluginStatus.active,
      isInstalled: true,
      rating: 4.7,
      downloadCount: 15300,
      iconEmoji: '🐘',
    ),
    Plugin(
      id: 'pg-5',
      name: 'Email Sender',
      description: 'Send emails via SMTP or API providers.',
      author: 'FuzzyBoard',
      version: '1.1.0',
      category: PluginCategory.action,
      isInstalled: false,
      rating: 4.3,
      downloadCount: 6100,
      iconEmoji: '📧',
    ),
  ];

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

  // ── Chat Messages ─────────────────────────────────────────────────────────
  final List<ChatMessage> chatMessages = [
    ChatMessage(
      id: 'cm-1',
      role: ChatRole.assistant,
      text: 'Hey! I\'m FuzzyAI 🤖 — your AI assistant. Ask me anything about your workflows or tasks!',
      timestamp: DateTime(2024, 1, 1, 0, 0),
    ),
    ChatMessage(
      id: 'cm-2',
      role: ChatRole.user,
      text: 'How many tasks do I have?',
      timestamp: DateTime(2024, 1, 1, 0, 1),
    ),
    ChatMessage(
      id: 'cm-3',
      role: ChatRole.assistant,
      text: 'You currently have 4 tasks. 1 is done, 1 is in progress, and 2 are pending. 💪',
      timestamp: DateTime(2024, 1, 1, 0, 1),
    ),
  ];

  void addChatMessage(ChatMessage message) {
    chatMessages.add(message);
    notifyListeners();
  }

  void clearChat() {
    chatMessages.clear();
    notifyListeners();
  }

  // ── Voice Commands ────────────────────────────────────────────────────────
  final List<String> voiceCommands = [
    'Show me the dashboard',
    'How many workflows are active?',
    'Navigate to tasks',
    'Create a new workflow',
  ];

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
  final List<Worker> _workers = [
    Worker(
      id: 'wk-1',
      name: 'HTTP Processor',
      description: 'Handles incoming HTTP requests and dispatches responses.',
      type: WorkerType.httpWorker,
      status: WorkerStatus.running,
      concurrency: 4,
      maxRetries: 3,
      timeoutSeconds: 30,
      endpoint: 'https://api.example.com/process',
      runCount: 342,
    ),
    Worker(
      id: 'wk-2',
      name: 'Daily Report Cron',
      description: 'Generates daily analytics reports at midnight.',
      type: WorkerType.cronWorker,
      status: WorkerStatus.running,
      concurrency: 1,
      maxRetries: 2,
      timeoutSeconds: 120,
      runCount: 89,
    ),
    Worker(
      id: 'wk-3',
      name: 'DB Sync Worker',
      description: 'Synchronizes data across primary and replica databases.',
      type: WorkerType.dbWorker,
      status: WorkerStatus.stopped,
      concurrency: 2,
      maxRetries: 5,
      timeoutSeconds: 60,
      runCount: 156,
    ),
  ];

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
