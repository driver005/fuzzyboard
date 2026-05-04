import 'package:flutter/material.dart';
import 'bounce_widget.dart';

/// App-wide button widget. Swap the implementation here to re-skin all
/// buttons across the entire app.
enum AppButtonVariant { primary, secondary, outline, ghost, danger }
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
          const Color(0xFFFF3D71),
          Colors.white,
          BorderSide.none
        ),
    };

    final (hPad, vPad, fontSize, radius) = switch (size) {
      AppButtonSize.sm => (14.0, 9.0,  13.0, 20.0),
      AppButtonSize.md => (22.0, 13.0, 14.0, 24.0),
      AppButtonSize.lg => (30.0, 17.0, 16.0, 28.0),
    };

    // Glow shadow for primary / danger variants
    final glowColor = switch (variant) {
      AppButtonVariant.primary => cs.primary.withOpacity(0.45),
      AppButtonVariant.danger  => const Color(0xFFFF3D71).withOpacity(0.45),
      _ => Colors.transparent,
    };

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

    Widget btn = AnimatedOpacity(
      opacity: isDisabled ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: isDisabled || variant == AppButtonVariant.ghost
              ? null
              : [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
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
