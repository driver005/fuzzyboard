import 'package:flutter/material.dart';

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

    final (bgColor, fgColor, side) = switch (variant) {
      AppButtonVariant.primary => (cs.primary, cs.onPrimary, BorderSide.none),
      AppButtonVariant.secondary =>
        (cs.secondary, cs.onSecondary, BorderSide.none),
      AppButtonVariant.outline => (
          Colors.transparent,
          cs.primary,
          BorderSide(color: cs.primary)
        ),
      AppButtonVariant.ghost =>
        (Colors.transparent, cs.onSurface, BorderSide.none),
      AppButtonVariant.danger => (
          const Color(0xFFEF4444),
          Colors.white,
          BorderSide.none
        ),
    };

    final (hPad, vPad, fontSize) = switch (size) {
      AppButtonSize.sm => (12.0, 8.0, 13.0),
      AppButtonSize.md => (20.0, 12.0, 14.0),
      AppButtonSize.lg => (28.0, 16.0, 16.0),
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
                      fontWeight: FontWeight.w600,
                      color: fgColor)),
            ],
          );

    final btn = AnimatedOpacity(
      opacity: isDisabled ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: bgColor,
        borderRadius: side == BorderSide.none ? BorderRadius.circular(10) : null,
        shape: side == BorderSide.none
            ? null
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: side,
              ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: content,
          ),
        ),
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: Center(child: btn))
        : btn;
  }
}
