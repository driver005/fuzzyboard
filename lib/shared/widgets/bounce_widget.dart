import 'package:flutter/material.dart';

/// Wraps any widget with a springy press-and-release scale animation.
/// On press-down the child squishes to [scale]; on release it springs back
/// past 1.0 and oscillates to rest — giving the "bouncy / sticky" game feel.
class BounceOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// Scale factor when pressed (0 < scale < 1). Defaults to 0.92.
  final double scale;

  const BounceOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.92,
  });

  @override
  State<BounceOnTap> createState() => BounceOnTapState();
}

class BounceOnTapState extends State<BounceOnTap> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedScale(
        scale: pressed ? widget.scale : 1.0,
        // Press: fast squish; Release: elastic spring back (overshoots ~7 %)
        duration: pressed
            ? const Duration(milliseconds: 80)
            : const Duration(milliseconds: 550),
        curve: pressed ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}
