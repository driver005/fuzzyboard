import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';

/// A shimmer-effect skeleton placeholder used while content is loading —
/// inspired by the skeleton / shimmer loading states in Skiper UI components.
///
/// Use [ShimmerBox] for individual fields and [ShimmerStatCard] for a
/// pre-built dashboard-stat skeleton.
///
/// ```dart
/// ShimmerBox(width: 200, height: 20)
/// ShimmerBox(width: double.infinity, height: 14)
/// ```
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    final base =
        isDark ? const Color(0xFF1A1F35) : const Color(0xFFE8E8E8);
    final highlight =
        isDark ? const Color(0xFF2A3050) : const Color(0xFFF5F5F5);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (ctrl) => ctrl.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: highlight,
          angle: 0.3,
        );
  }
}

/// A pre-built skeleton card that mirrors the shape of [StatCard].
///
/// Drop this in wherever you would normally render a [StatCard] while data
/// is still loading.
class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: const Row(
        children: [
          ShimmerBox(
              width: 52, height: 52, borderRadius: AppRadius.md),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 80, height: 11),
                SizedBox(height: 8),
                ShimmerBox(width: 120, height: 22),
                SizedBox(height: 6),
                ShimmerBox(width: 60, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width skeleton card with an optional title line and several body lines.
class ShimmerCard extends StatelessWidget {
  /// Number of body skeleton lines to render.
  final int lines;

  const ShimmerCard({super.key, this.lines = 3});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 140, height: 16),
          const SizedBox(height: 14),
          for (int i = 0; i < lines; i++) ...[
            const ShimmerBox(
              width: double.infinity,
              height: 13,
              borderRadius: 6,
            ),
            if (i < lines - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
