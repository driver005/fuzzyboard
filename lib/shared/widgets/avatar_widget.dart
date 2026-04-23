import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';

/// A 3D-styled animated avatar mascot that reacts to app events.
class AvatarWidget extends StatefulWidget {
  final double size;
  const AvatarWidget({super.key, this.size = 80});

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget>
    with TickerProviderStateMixin {
  String _mood = 'idle';
  String _prevEvent = '';

  static const Map<String, ({String emoji, String label, Color glow})> _moods = {
    'idle': (emoji: '🤖', label: 'Ready', glow: Color(0xFF6C63FF)),
    'happy': (emoji: '🥳', label: 'Awesome!', glow: Color(0xFF10B981)),
    'busy': (emoji: '⚙️', label: 'Working...', glow: Color(0xFF3B82F6)),
    'error': (emoji: '😱', label: 'Uh oh!', glow: Color(0xFFEF4444)),
    'thinking': (emoji: '🤔', label: 'Hmm...', glow: Color(0xFFF59E0B)),
    'dev': (emoji: '👾', label: 'Debug Mode', glow: Color(0xFF8B5CF6)),
    'wave': (emoji: '👋', label: 'Hey there!', glow: Color(0xFFEC4899)),
  };

  void _react(String event) {
    if (event == _prevEvent) return;
    _prevEvent = event;
    setState(() {
      _mood = switch (event) {
        'task_created' => 'happy',
        'task_deleted' => 'thinking',
        'workflow_created' => 'happy',
        'workflow_toggled' => 'busy',
        'workflow_deleted' => 'thinking',
        'plugin_installed' => 'happy',
        'plugin_uninstalled' => 'thinking',
        'dev_mode_on' => 'dev',
        'dev_mode_off' => 'idle',
        _ when event.contains('error') => 'error',
        _ => 'idle',
      };
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _mood = 'idle');
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = context.watch<AppProvider>().lastEvent;
    _react(event);
    final mood = _moods[_mood] ?? _moods['idle']!;

    return Tooltip(
      message: mood.label,
      child: GestureDetector(
        onTap: () {
          setState(() => _mood = 'wave');
          Future.delayed(const Duration(seconds: 2),
              () => mounted ? setState(() => _mood = 'idle') : null);
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: mood.glow.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
            gradient: RadialGradient(
              colors: [
                mood.glow.withOpacity(0.2),
                mood.glow.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: Text(
              mood.emoji,
              style: TextStyle(fontSize: widget.size * 0.5),
            )
                .animate(key: ValueKey(_mood))
                .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.elasticOut)
                .fadeIn(duration: 200.ms),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -6,
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),
      ),
    );
  }
}
