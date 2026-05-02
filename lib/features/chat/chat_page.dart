import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/app_provider.dart';
import '../../models/chat_message.dart';
import '../../shared/widgets/app_input.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final uuid = const Uuid();
  bool isTyping = false;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final app = context.read<AppProvider>();

    app.addChatMessage(ChatMessage(
      id: uuid.v4(),
      role: ChatRole.user,
      text: text,
      timestamp: DateTime.now(),
    ));
    controller.clear();
    setState(() => isTyping = true);
    scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      app.addChatMessage(ChatMessage(
        id: uuid.v4(),
        role: ChatRole.assistant,
        text: generateReply(text, app),
        timestamp: DateTime.now(),
      ));
      setState(() => isTyping = false);
      scrollToBottom();
    });
  }

  String generateReply(String msg, AppProvider app) {
    final lower = msg.toLowerCase();
    if (lower.contains('task')) return 'You have ${app.tasks.length} tasks. ${app.tasks.where((t) => t.status.name == 'done').length} are done. 📋';
    if (lower.contains('workflow')) return 'You have ${app.workflows.length} workflows, ${app.workflows.where((w) => w.isActive).length} are currently active. ⚡';
    if (lower.contains('plugin')) return 'You have ${app.installedPlugins.length} plugins installed. 🔌';
    if (lower.contains('hello') || lower.contains('hi')) return 'Hello! 👋 I\'m FuzzyAI. How can I help you today?';
    if (lower.contains('help')) return 'I can help you with tasks, workflows, and plugins. Try asking "how many tasks do I have?".';
    return 'I\'m FuzzyAI — still learning! 🤖 Try asking about your tasks, workflows, or plugins.';
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final messages = app.chatMessages;

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Text('🤖', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('FuzzyAI'),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length + (isTyping ? 1 : 0),
            itemBuilder: (context, i) {
              if (isTyping && i == messages.length) return _TypingIndicator();
              final msg = messages[i];
              return _MessageBubble(message: msg);
            },
          ),
        ),
        _InputBar(controller: controller, onSend: send),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUser = message.role == ChatRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: cs.primary.withOpacity(0.12), shape: BoxShape.circle),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? cs.primary : cs.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Text(message.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isUser ? cs.onPrimary : cs.onSurface)),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    ).animate(delay: 30.ms).fadeIn().slideY(begin: 0.2);
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: cs.primary.withOpacity(0.12), shape: BoxShape.circle), child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14)))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
          child: Text('FuzzyAI is typing…', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.5), fontStyle: FontStyle.italic)),
        ),
      ]),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 600.ms);
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: cs.outline.withOpacity(0.2))),
      ),
      child: Row(children: [
        Expanded(child: AppInput(controller: controller, hint: 'Message FuzzyAI…', onSubmitted: (_) => onSend())),
        const SizedBox(width: 8),
        IconButton.filled(onPressed: onSend, icon: const Icon(Icons.send)),
      ]),
    );
  }
}
