import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../shared/widgets/app_card.dart';

class VoiceModePage extends StatefulWidget {
  const VoiceModePage({super.key});
  @override
  State<VoiceModePage> createState() => _VoiceModePageState();
}

class _VoiceModePageState extends State<VoiceModePage> with SingleTickerProviderStateMixin {
  bool isListening = false;
  late AnimationController pulseController;

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulseController.dispose();
    super.dispose();
  }

  void toggleListening() {
    setState(() => isListening = !isListening);
    if (isListening) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted || !isListening) return;
        final replies = ['Showing dashboard…', 'Found 4 tasks in your board.', 'Navigating to workflows…', 'All systems running smoothly!'];
        final reply = replies[DateTime.now().millisecond % replies.length];
        context.read<AppProvider>().addVoiceCommand('Voice command recorded');
        setState(() => isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('FuzzyAI: $reply')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.voiceModeTitle)),
      body: Column(children: [
        Expanded(
          flex: 2,
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  final scale = isListening ? 1.0 + pulseController.value * 0.15 : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: toggleListening,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isListening ? cs.primary : cs.surface,
                          boxShadow: [BoxShadow(color: cs.primary.withOpacity(isListening ? 0.4 : 0.15), blurRadius: isListening ? 32 : 16, spreadRadius: isListening ? 8 : 2)],
                          border: Border.all(color: cs.primary, width: 2),
                        ),
                        child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 48, color: isListening ? cs.onPrimary : cs.primary),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(isListening ? context.l10n.listeningStatus : context.l10n.tapToSpeakPrompt,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: isListening ? cs.primary : cs.onSurface.withOpacity(0.6)),
              ).animate(key: ValueKey(isListening)).fadeIn(),
              const SizedBox(height: 8),
              Text(isListening ? context.l10n.fuzzyAIListening : context.l10n.startListeningPrompt,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4))),
            ]),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(context.l10n.recentCommandsTitle, style: Theme.of(context).textTheme.titleSmall),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: app.voiceCommands.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    leading: Icon(Icons.mic, size: 18, color: cs.primary),
                    title: app.voiceCommands[i],
                  ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().slideX(begin: 0.1),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
