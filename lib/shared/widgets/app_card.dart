import 'package:flutter/material.dart';

/// App-wide card widget with optional header, footer, and actions.
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
    final effectiveColor =
        color ?? theme.cardTheme.color ?? cs.surface;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null || subtitle != null || leading != null || actions != null)
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
                Divider(height: 1, color: cs.outline.withOpacity(0.2)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: footer!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.change,
    this.changePositive = true,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
