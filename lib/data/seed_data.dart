// All built-in seed / demo data used to bootstrap the application.
// When a real back-end adapter is wired up these records are replaced by
// whatever the adapter returns, so nothing here is part of the production
// data model – it is illustrative only.
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/plugin.dart';
import '../models/task.dart';
import '../models/worker.dart';
import '../models/workflow.dart';

// ── Tasks ─────────────────────────────────────────────────────────────────────

List<Task> buildSeedTasks() => [
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

// ── Workflows ─────────────────────────────────────────────────────────────────

List<Workflow> buildSeedWorkflows() => [
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
            label: 'Yes',
          ),
          WorkflowConnection(
            id: 'c5',
            fromNodeId: 'n4',
            toNodeId: 'n5',
            type: ConnectionType.failure,
            label: 'No',
          ),
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

// ── Plugins ───────────────────────────────────────────────────────────────────

List<Plugin> buildSeedPlugins() => [
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

// ── Workers ───────────────────────────────────────────────────────────────────

List<Worker> buildSeedWorkers() => [
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

// ── Chat messages ─────────────────────────────────────────────────────────────

List<ChatMessage> buildSeedChatMessages() => [
      ChatMessage(
        id: 'cm-1',
        role: ChatRole.assistant,
        text:
            "Hey! I'm FuzzyAI 🤖 — your AI assistant. Ask me anything about your workflows or tasks!",
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
        text:
            'You currently have 4 tasks. 1 is done, 1 is in progress, and 2 are pending. 💪',
        timestamp: DateTime(2024, 1, 1, 0, 1),
      ),
    ];

/// Seed voice commands shown in the voice feature before the user speaks.
const List<String> seedVoiceCommands = [
  'Show me the dashboard',
  'How many workflows are active?',
  'Navigate to tasks',
  'Create a new workflow',
];
