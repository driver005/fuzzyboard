import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Wraps any child in a continuously sweeping gradient border ring,
/// inspired by the animated-border style popularised by Skiper UI.
///
/// The gradient completes one full rotation in [speed] (default: 3 s).
/// Set [animate] to `false` to render a static gradient ring instead.
///
/// ```dart
/// AnimatedGradientBorder(
///   child: MyCard(),
/// )
/// ```
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;

  /// Colours used for the sweeping gradient ring.
  /// Provide at least two colours; they loop back to the first automatically.
  final List<Color> gradientColors;

  /// Thickness of the gradient border in logical pixels.
  final double borderWidth;

  /// Corner radius of the outer container (inner content gets
  /// `borderRadius − borderWidth` automatically).
  final double borderRadius;

  /// Whether to animate the gradient rotation.
  final bool animate;

  /// Duration for one full rotation.
  final Duration speed;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.gradientColors = const [
      AppColors.brandPrimary,
      AppColors.brandSecondary,
      AppColors.brandAccent,
      AppColors.brandPrimary, // loop back
    ],
    this.borderWidth = 1.5,
    this.borderRadius = AppRadius.card,
    this.animate = true,
    this.speed = const Duration(seconds: 3),
  }) : assert(gradientColors.length >= 2,
            'AnimatedGradientBorder requires at least 2 gradient colors'),
       assert(borderWidth >= 0, 'borderWidth must be non-negative'),
       assert(borderRadius >= 0, 'borderRadius must be non-negative');

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.speed);
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(AnimatedGradientBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _controller.duration = widget.speed;
    }
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    } else if (widget.animate && oldWidget.speed != widget.speed) {
      // Restart the repeat loop with the new duration.
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final innerRadius =
        (widget.borderRadius - widget.borderWidth).clamp(0.0, double.infinity);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: SweepGradient(
            startAngle: 0,
            endAngle: 2 * math.pi,
            transform: GradientRotation(
              widget.animate ? _controller.value * 2 * math.pi : 0,
            ),
            colors: widget.gradientColors,
          ),
        ),
        padding: EdgeInsets.all(widget.borderWidth),
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: widget.child,
      ),
    );
  }
}
