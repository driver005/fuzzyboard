import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/gamification_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../extensions/extension_zone.dart';
import '../../models/task_run.dart';
import '../../models/workflow.dart';
import '../../shared/layout/responsive_layout.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/avatar_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final userProvider = context.watch<UserProvider>();
    final mobile = isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.dashboardTitle),
        actions: [
          AppButton(
            label: userProvider.isAdmin ? context.l10n.adminViewButton : context.l10n.userViewButton,
            icon: const Icon(Icons.switch_account),
            size: AppButtonSize.sm,
            variant: AppButtonVariant.outline,
            onPressed: () => userProvider.switchRole(
              userProvider.isAdmin ? UserRole.user : UserRole.admin,
            ),
          ),
          const SizedBox(width: 8),
          if (mobile)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: AvatarWidget(size: 40),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // [extension zone] banner area — plugins can add header banners here
          const ExtensionZone(id: 'dashboard.header_end'),
          _SmartHeroBanner(isAdmin: userProvider.isAdmin),
          const SizedBox(height: 20),
          // Control tiles (stat cards with 3D depth style)
          ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 2,
            desktopColumns: 4,
            spacing: 12,
            runSpacing: 12,
            children: [
              _ControlTile(
                title: context.l10n.totalTasksCard,
                value: '${app.tasks.length}',
                subtitle: context.l10n.todayChange,
                icon: Icons.task_alt_outlined,
                color: const Color(0xFF3B82F6),
                onTap: () => context.go('/tasks'),
              ),
              _ControlTile(
                title: context.l10n.activeWorkflowsCard,
                value: '${app.workflows.where((w) => w.isActive).length}',
                subtitle: 'of ${app.workflows.length} total',
                icon: Icons.account_tree_outlined,
                color: const Color(0xFF22C55E),
                onTap: () => context.go('/workflows'),
              ),
              _ControlTile(
                title: context.l10n.pluginsCard,
                value: '${app.installedPlugins.length}',
                subtitle: context.l10n.installedLabel,
                icon: Icons.extension_outlined,
                color: const Color(0xFF8B5CF6),
                onTap: () => context.go('/plugins'),
              ),
              _ControlTile(
                title: context.l10n.runsTodayCard,
                value: '${app.workflows.fold(0, (s, w) => s + w.runCount)}',
                subtitle: context.l10n.upChangePercent,
                icon: Icons.play_circle_outline,
                color: const Color(0xFFF59E0B),
                onTap: () => context.go('/workflows'),
              ),
            ].map((c) => c.animate().fadeIn(delay: 100.ms).slideY(begin: 0.2)).toList(),
          ),
          // [extension zone] extra stat cards from plugins
          const ExtensionZone(id: 'dashboard.stats_section'),
          const SizedBox(height: 24),
          // Control Zones — workflows shown as smart-home room cards
          _ControlZonesSection(workflows: app.workflows),
          const SizedBox(height: 24),
          // Charts + activity feed row
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 1,
            desktopColumns: 2,
            spacing: 16,
            runSpacing: 16,
            children: [
              _TaskStatusChart(runs: app.taskRuns),
              _SystemActivityFeed(logs: app.logs),
            ],
          ),
          // [extension zone] footer — plugins can add summary widgets here
          const ExtensionZone(id: 'dashboard.footer'),
        ],
      ),
    );
  }
}

// ── Smart Hero Banner ─────────────────────────────────────────────────────────

class _SmartHeroBanner extends StatelessWidget {
  final bool isAdmin;
  const _SmartHeroBanner({required this.isAdmin});

  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final gam = context.watch<GamificationProvider>();
    final app = context.watch<AppProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final mobile = isMobile(context);

    final activeCount = app.workflows.where((w) => w.isActive).length;
    final totalCount = app.workflows.length;
    final healthPct = totalCount == 0 ? 0.0 : activeCount / totalCount;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0A1628), cs.primary.withOpacity(0.18), const Color(0xFF0C1A30)]
              : [cs.primary.withOpacity(0.07), cs.secondary.withOpacity(0.04), cs.primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withOpacity(isDark ? 0.22 : 0.14),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(color: cs.primary.withOpacity(0.10), blurRadius: 40, offset: const Offset(0, 8)),
          BoxShadow(color: cs.secondary.withOpacity(0.05), blurRadius: 60, offset: const Offset(0, 16)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative glow orbs for depth
            Positioned(top: -40, right: 100, child: _GlowOrb(color: cs.primary, size: 140)),
            Positioned(bottom: -30, right: 30, child: _GlowOrb(color: cs.secondary, size: 90)),
            if (!mobile)
              Positioned(top: 15, left: 220, child: _GlowOrb(color: cs.secondary.withOpacity(0.4), size: 55)),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: mobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroLeftContent(
                          isAdmin: isAdmin,
                          gam: gam,
                          greeting: _timeGreeting(),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: _SystemStatusDial(
                            healthPct: healthPct,
                            active: activeCount,
                            total: totalCount,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _HeroLeftContent(
                            isAdmin: isAdmin,
                            gam: gam,
                            greeting: _timeGreeting(),
                          ),
                        ),
                        const SizedBox(width: 28),
                        _SystemStatusDial(
                          healthPct: healthPct,
                          active: activeCount,
                          total: totalCount,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05);
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.20),
            blurRadius: size,
            spreadRadius: size * 0.28,
          ),
        ],
      ),
    );
  }
}

class _HeroLeftContent extends StatelessWidget {
  final bool isAdmin;
  final GamificationProvider gam;
  final String greeting;
  const _HeroLeftContent({
    required this.isAdmin,
    required this.gam,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = cs.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.welcomeBanner,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isDark ? Colors.white : cs.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.workflowRunningSmooth,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.60),
          ),
        ),
        const SizedBox(height: 16),
        if (isAdmin) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary.withOpacity(0.18), cs.secondary.withOpacity(0.10)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.primary.withOpacity(0.35), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings, color: cs.primary, size: 14),
                const SizedBox(width: 5),
                Text(
                  context.l10n.adminDashboard,
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        // XP progress row
        _HeroXpRow(gam: gam),
      ],
    );
  }
}

class _HeroXpRow extends StatelessWidget {
  final GamificationProvider gam;
  const _HeroXpRow({required this.gam});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = cs.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.58),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.08 : 0.5), width: 1),
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFEAB308), Color(0xFFFF6B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEAB308).withOpacity(0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${gam.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'LVL',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.08, duration: 900.ms, curve: Curves.easeInOut),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      gam.levelTitle,
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      '${gam.xp} / ${GamificationProvider.xpPerLevel} XP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: gam.levelProgress,
                    minHeight: 6,
                    backgroundColor: cs.onSurface.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _XpPill(emoji: '✅', value: '${gam.tasksCompleted}', label: 'tasks'),
                    const SizedBox(width: 8),
                    _XpPill(
                      emoji: '🔥',
                      value: gam.streak > 0 ? '${gam.streak}d' : '—',
                      label: 'streak',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _XpPill extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _XpPill({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withOpacity(0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── System Status Dial ────────────────────────────────────────────────────────

class _SystemStatusDial extends StatelessWidget {
  final double healthPct;
  final int active;
  final int total;
  const _SystemStatusDial({
    required this.healthPct,
    required this.active,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = cs.brightness == Brightness.dark;

    final dialColor = healthPct > 0.7
        ? const Color(0xFF22C55E)
        : healthPct > 0.4
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.65),
        border: Border.all(color: cs.primary.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(color: dialColor.withOpacity(0.18), blurRadius: 30, spreadRadius: 2),
          BoxShadow(color: cs.primary.withOpacity(0.08), blurRadius: 50),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(148, 148),
            painter: _DialArcPainter(
              progress: healthPct,
              trackColor: cs.onSurface.withOpacity(0.08),
              progressColor: dialColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(healthPct * 100).round()}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: isDark ? Colors.white : cs.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
              Text(
                context.l10n.activeBadge,
                style: TextStyle(
                  color: dialColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$active / $total zones',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 3000.ms, color: dialColor.withOpacity(0.08));
  }
}

class _DialArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _DialArcPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = trackColor,
    );

    if (progress > 0) {
      final sweep = sweepAngle * progress;

      // Glow layer
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = progressColor.withOpacity(0.28),
      );

      // Main progress arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = progressColor,
      );

      // End dot
      final endAngle = startAngle + sweep;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);
      canvas.drawCircle(
        Offset(dotX, dotY),
        5.5,
        Paint()..color = progressColor,
      );
    }
  }

  @override
  bool shouldRepaint(_DialArcPainter old) => old.progress != progress;
}

// ── Control Tile ─────────────────────────────────────────────────────────────

/// Dashboard stat tile with a 3D-depth card style inspired by smart home UIs.
class _ControlTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ControlTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = cs.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1628) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.20), width: 1),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.13), blurRadius: 22, offset: const Offset(0, 6)),
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 45, offset: const Offset(0, 14)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.38),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 21),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_outward, color: color, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: isDark ? Colors.white : cs.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.55),
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Control Zones Section ─────────────────────────────────────────────────────

class _ControlZonesSection extends StatelessWidget {
  final List<Workflow> workflows;
  const _ControlZonesSection({required this.workflows});

  static const _zoneColors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    if (workflows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.grid_view_rounded, color: cs.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              context.l10n.controlZonesTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => context.go('/workflows'),
              icon: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: cs.primary),
              label: Text(
                context.l10n.viewAllButton,
                style: TextStyle(color: cs.primary, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          spacing: 12,
          runSpacing: 12,
          children: workflows.take(6).toList().asMap().entries.map((e) {
            final color = _zoneColors[e.key % _zoneColors.length];
            return _ZoneCard(workflow: e.value, accentColor: color)
                .animate()
                .fadeIn(delay: (e.key * 55).ms)
                .slideY(begin: 0.15);
          }).toList(),
        ),
      ],
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final Workflow workflow;
  final Color accentColor;
  const _ZoneCard({required this.workflow, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1428) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: workflow.isActive
              ? accentColor.withOpacity(0.28)
              : cs.onSurface.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: workflow.isActive
                ? accentColor.withOpacity(0.10)
                : Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coloured top strip
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: workflow.isActive
                    ? [accentColor, accentColor.withOpacity(0.45)]
                    : [cs.onSurface.withOpacity(0.12), cs.onSurface.withOpacity(0.04)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(workflow.isActive ? 0.14 : 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_tree_outlined,
                        color: workflow.isActive ? accentColor : cs.onSurface.withOpacity(0.38),
                        size: 16,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: workflow.isActive
                                ? const Color(0xFF22C55E)
                                : cs.onSurface.withOpacity(0.22),
                            boxShadow: workflow.isActive
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF22C55E).withOpacity(0.60),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          workflow.isActive ? context.l10n.activeStatus : context.l10n.idleStatus,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: workflow.isActive
                                ? const Color(0xFF22C55E)
                                : cs.onSurface.withOpacity(0.38),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  workflow.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.runsTotalLabel(workflow.runCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.42),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: _MiniSparkline(accentColor: accentColor, active: workflow.isActive),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  final Color accentColor;
  final bool active;
  const _MiniSparkline({required this.accentColor, required this.active});

  static const _sparkData = [0.3, 0.5, 0.4, 0.65, 0.55, 0.78, 0.88, 0.70, 0.95, 0.82];

  @override
  Widget build(BuildContext context) {
    final color = active ? accentColor : accentColor.withOpacity(0.28);
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: _sparkData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            color: color,
            barWidth: 1.8,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.12),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}

// ── Task Status Chart ─────────────────────────────────────────────────────────

class _TaskStatusChart extends StatelessWidget {
  final List<TaskRun> runs;
  const _TaskStatusChart({required this.runs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Map<TaskRunStatus, int> counts = {
      for (final s in TaskRunStatus.values) s: runs.where((r) => r.status == s).length,
    };
    final total = runs.length;

    return AppCard(
      title: context.l10n.taskStatusChart,
      child: total == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.l10n.noTasksEmpty),
              ),
            )
          : SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 42,
                        sections: TaskRunStatus.values.map((s) {
                          final val = counts[s] ?? 0;
                          return PieChartSectionData(
                            value: val.toDouble(),
                            color: s.color,
                            radius: 50,
                            title: val > 0 ? '$val' : '',
                            titleStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: TaskRunStatus.values.map((s) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: s.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(s.label, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

// ── System Activity Feed ──────────────────────────────────────────────────────

class _SystemActivityFeed extends StatelessWidget {
  final List<String> logs;
  const _SystemActivityFeed({required this.logs});

  String _relativeTime(String logEntry) {
    try {
      final match = RegExp(r'\[(\d{4}-\d{2}-\d{2}T[\d:.]+)\]').firstMatch(logEntry);
      if (match != null) {
        final dt = DateTime.parse(match.group(1)!);
        final diff = DateTime.now().difference(dt);
        if (diff.inSeconds < 60) return '${diff.inSeconds}s';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m';
        if (diff.inHours < 24) return '${diff.inHours}h';
        return '${diff.inDays}d';
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final recent = logs.take(5).toList();

    return AppCard(
      title: context.l10n.recentActivityTitle,
      child: recent.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(context.l10n.noActivityYet),
              ),
            )
          : Column(
              children: recent.asMap().entries.map((e) {
                final isLast = e.key == recent.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline spine
                      Column(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withOpacity(0.50),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 1,
                                color: cs.primary.withOpacity(isDark ? 0.18 : 0.14),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _relativeTime(e.value),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurface.withOpacity(0.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    ).animate().fadeIn(delay: 350.ms);
  }
}
