import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'bounce_widget.dart';

/// App-wide card widget with optional header, footer, and actions.
/// Tappable cards automatically get a bouncy spring press animation.
class AppCard extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.footer,
    this.padding,
    this.color,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final effectiveColor = color ?? theme.cardTheme.color ?? cs.surface;

    Widget card = SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
            width: AppBorderWidth.thin,
          ),
          boxShadow: AppGlow.card(cs.primary),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Material(
            color: Colors.transparent,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null ||
                      subtitle != null ||
                      leading != null ||
                      actions != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          if (leading != null) ...[
                            leading!,
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (title != null)
                                  Text(title!,
                                      style: theme.textTheme.titleMedium),
                                if (subtitle != null)
                                  Text(subtitle!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                          color: cs.onSurface.withOpacity(0.6))),
                              ],
                            ),
                          ),
                          if (actions != null) ...actions!,
                        ],
                      ),
                    ),
                  if (child != null)
                    Padding(
                      padding: padding ?? const EdgeInsets.all(16),
                      child: child,
                    ),
                  if (footer != null) ...[
                    Divider(
                      height: 1,
                      color: AppColors.borderSubtle(isDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: footer!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
    );

    if (onTap != null) {
      card = BounceOnTap(onTap: onTap, scale: 0.96, child: card);
    }
    return card;
  }
}

/// Small stat card used on dashboard
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final bool changePositive;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.change,
    this.changePositive = true,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppGlow.button(iconColor),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurface.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.headlineSmall),
                if (change != null)
                  Text(
                    change!,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: changePositive
                            ? const Color(0xFF06D6A0)
                            : const Color(0xFFFF3D71)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
