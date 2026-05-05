import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import 'bounce_widget.dart';

/// App-wide button widget. Swap the implementation here to re-skin all
/// buttons across the entire app.
///
/// [AppButtonVariant.gradient] renders a sweeping animated gradient fill
/// behind the label, inspired by the animated-button style in Skiper UI.
enum AppButtonVariant { primary, secondary, outline, ghost, danger, gradient }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null || loading;

    if (variant == AppButtonVariant.gradient) {
      return _GradientButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        size: size,
        loading: loading,
        fullWidth: fullWidth,
        isDisabled: isDisabled,
      );
    }

    final (bgColor, fgColor, borderSide) = switch (variant) {
      AppButtonVariant.primary => (cs.primary, cs.onPrimary, BorderSide.none),
      AppButtonVariant.secondary =>
        (cs.secondary, cs.onSecondary, BorderSide.none),
      AppButtonVariant.outline => (
          Colors.transparent,
          cs.primary,
          BorderSide(color: cs.primary, width: 2)
        ),
      AppButtonVariant.ghost =>
        (Colors.transparent, cs.onSurface, BorderSide.none),
      AppButtonVariant.danger => (
          AppColors.brandAccent,
          Colors.white,
          BorderSide.none
        ),
      // gradient is handled by the early return above; this branch is never reached.
      AppButtonVariant.gradient => (cs.primary, cs.onPrimary, BorderSide.none),
    };

    final (hPad, vPad, fontSize, radius) = switch (size) {
      AppButtonSize.sm => (14.0, 9.0,  13.0, AppRadius.pill),
      AppButtonSize.md => (22.0, 13.0, 14.0, AppRadius.pill),
      AppButtonSize.lg => (30.0, 17.0, 16.0, AppRadius.pill),
    };

    // Glow shadow only for primary / danger variants.
    final bool applyGlow = !isDisabled &&
        variant != AppButtonVariant.ghost &&
        (variant == AppButtonVariant.primary || variant == AppButtonVariant.danger);

    final content = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: fgColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                IconTheme(
                    data: IconThemeData(color: fgColor, size: fontSize + 2),
                    child: icon!),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      color: fgColor,
                      letterSpacing: 0.3)),
            ],
          );

    final glowColor = variant == AppButtonVariant.danger
        ? AppColors.brandAccent
        : cs.primary;

    Widget btn = AnimatedOpacity(
      opacity: isDisabled ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: applyGlow ? AppGlow.button(glowColor) : null,
        ),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          shape: borderSide == BorderSide.none
              ? null
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: borderSide,
                ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: content,
          ),
        ),
      ),
    );

    btn = BounceOnTap(
      onTap: isDisabled ? null : onPressed,
      scale: 0.91,
      child: btn,
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: Center(child: btn))
        : btn;
  }
}

// ── Gradient button ──────────────────────────────────────────────────────────

/// Internal implementation of [AppButtonVariant.gradient].
/// Renders a continuously sweeping gradient fill behind the label,
/// inspired by the animated-button style in Skiper UI.
class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonSize size;
  final bool loading;
  final bool fullWidth;
  final bool isDisabled;

  const _GradientButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.size,
    required this.loading,
    required this.fullWidth,
    required this.isDisabled,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (hPad, vPad, fontSize, radius) = switch (widget.size) {
      AppButtonSize.sm => (14.0, 9.0, 13.0, AppRadius.pill),
      AppButtonSize.md => (22.0, 13.0, 14.0, AppRadius.pill),
      AppButtonSize.lg => (30.0, 17.0, 16.0, AppRadius.pill),
    };

    const fgColor = Colors.white;
    final content = widget.loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: fgColor, size: fontSize + 2),
                  child: widget.icon!,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: fgColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          );

    Widget btn = AnimatedOpacity(
      opacity: widget.isDisabled ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: SweepGradient(
              startAngle: 0,
              endAngle: 2 * math.pi,
              transform: GradientRotation(_ctrl.value * 2 * math.pi),
              colors: const [
                AppColors.brandPrimary,
                AppColors.brandSecondary,
                AppColors.brandAccent,
                AppColors.brandPrimary,
              ],
            ),
            boxShadow: AppGlow.button(AppColors.brandPrimary),
          ),
          child: child,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: content,
        ),
      ),
    )
        .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.03, duration: 900.ms, curve: Curves.easeInOut);

    btn = BounceOnTap(
      onTap: widget.isDisabled ? null : widget.onPressed,
      scale: 0.91,
      child: btn,
    );

    return widget.fullWidth
        ? SizedBox(width: double.infinity, child: Center(child: btn))
        : btn;
  }
}
