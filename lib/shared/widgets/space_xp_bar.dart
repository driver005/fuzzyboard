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
    final isDark = cs.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D0D2A), const Color(0xFF1A1A3E)]
              : [const Color(0xFF0F0C29), const Color(0xFF302B63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${gam.xp} / ${GamificationProvider.xpPerLevel} XP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: gam.levelProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF6C63FF),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
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
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final String title;
  const _LevelBadge({required this.level, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 10,
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
                fontSize: 18,
              )),
          Text('LVL',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              )),
        ],
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 10,
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
      width: 32,
      height: 48,
      child: Stack(
        children: [
          Positioned(top: 4, right: 0, child: _Star(size: 5, opacity: 0.9)),
          Positioned(top: 18, right: 12, child: _Star(size: 3, opacity: 0.6)),
          Positioned(top: 30, right: 4, child: _Star(size: 4, opacity: 0.75)),
          Positioned(top: 8, right: 20, child: _Star(size: 3, opacity: 0.5)),
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
      ),
    );
  }
}
