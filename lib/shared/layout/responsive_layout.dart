import 'package:flutter/material.dart';

/// Breakpoints for responsive layout
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Returns true if the current screen is considered mobile.
bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < Breakpoints.mobile;

bool isTablet(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return w >= Breakpoints.mobile && w < Breakpoints.tablet;
}

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= Breakpoints.tablet;

/// Responsive builder that exposes mobile/tablet/desktop layouts.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= Breakpoints.tablet) return desktop ?? tablet ?? mobile;
    if (w >= Breakpoints.mobile) return tablet ?? mobile;
    return mobile;
  }
}

/// A grid that adapts column count to screen width.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double minChildWidth;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
    this.minChildWidth = 240,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final columns = w >= Breakpoints.tablet
        ? desktopColumns
        : w >= Breakpoints.mobile
            ? tabletColumns
            : mobileColumns;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += columns) {
          final rowChildren = <Widget>[];
          for (var j = 0; j < columns && i + j < children.length; j++) {
            if (j > 0) rowChildren.add(SizedBox(width: spacing));
            rowChildren.add(SizedBox(width: itemWidth, child: children[i + j]));
          }
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ));
          if (i + columns < children.length) {
            rows.add(SizedBox(height: runSpacing));
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }
}
