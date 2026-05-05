import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'bounce_widget.dart';

/// A frosted-glass card with a [BackdropFilter] blur, translucent surface,
/// and a subtle border — inspired by the glassmorphism style used throughout
/// Skiper UI components.
///
/// Works best when placed over a colourful gradient or image background where
/// the blur effect is visible.
///
/// ```dart
/// GlassCard(
///   child: Text('Hello glass!'),
/// )
/// ```
class GlassCard extends StatelessWidget {
  final Widget child;

  /// Internal padding. Defaults to `EdgeInsets.all(16)`.
  final EdgeInsetsGeometry? padding;

  /// Corner radius. Defaults to [AppRadius.card].
  final double? borderRadius;

  /// Strength of the blur applied to the content behind the card.
  final double blurSigma;

  /// Background fill colour of the glass surface.
  /// Defaults to a semi-transparent white / dark tone matching the theme.
  final Color? backgroundColor;

  /// Border colour. Defaults to a soft white/dark tint.
  final Color? borderColor;

  final double? width;
  final double? height;

  /// Optional tap callback; adds a spring-press animation when set.
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = 14,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.card;
    final effectiveBg = backgroundColor ??
        (isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.white.withOpacity(0.65));
    final effectiveBorder = borderColor ??
        (isDark
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.5));

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: effectiveBorder,
              width: AppBorderWidth.thin,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = BounceOnTap(onTap: onTap, scale: 0.96, child: card);
    }

    return card;
  }
}
