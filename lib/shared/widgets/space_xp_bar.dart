import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/providers/gamification_provider.dart';

/// Compact space-themed gamification bar shown at the top of the dashboard.
class SpaceXpBar extends StatelessWidget {
  const SpaceXpBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gam = context.watch<GamificationProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B0764), Color(0xFF6D28D9), Color(0xFF0E7490)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF06D6A0).withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Level badge
          _LevelBadge(level: gam.level, title: gam.levelTitle),
          const SizedBox(width: 14),
          // XP progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      gam.levelTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${gam.xp} / ${GamificationProvider.xpPerLevel} XP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: gam.levelProgress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF06D6A0),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatPill(emoji: '✅', value: '${gam.tasksCompleted}', label: 'tasks'),
                    const SizedBox(width: 8),
                    _StatPill(emoji: '🔥', value: gam.streak > 0 ? '${gam.streak}d' : '—', label: 'streak'),
                  ],
                ),
              ],
            ),
          ),
          // Stars decoration
          _Stars(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.15, curve: Curves.elasticOut, duration: 700.ms);
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final String title;
  const _LevelBadge({required this.level, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFEAB308), Color(0xFFFF6B00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEAB308).withOpacity(0.55),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$level',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              )),
          Text('LVL',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              )),
        ],
      ),
    )
        .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.08, duration: 900.ms, curve: Curves.easeInOut);
  }
}

class _StatPill extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _StatPill({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 56,
      child: Stack(
        children: [
          Positioned(top: 4,  right: 0,  child: _Star(size: 5, opacity: 0.9)),
          Positioned(top: 18, right: 14, child: _Star(size: 3, opacity: 0.6)),
          Positioned(top: 32, right: 4,  child: _Star(size: 4, opacity: 0.8)),
          Positioned(top: 8,  right: 22, child: _Star(size: 3, opacity: 0.5)),
          Positioned(top: 44, right: 16, child: _Star(size: 2, opacity: 0.4)),
        ],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final double size;
  final double opacity;
  const _Star({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(opacity * 0.8),
            blurRadius: size * 1.5,
          ),
        ],
      ),
    )
        .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
        .fadeIn(
            begin: (opacity * 0.3).clamp(0.0, 1.0),
            duration: Duration(milliseconds: (800 + size * 200).toInt()),
            curve: Curves.easeInOut);
  }
}
