import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Tab affinity ──────────────────────────────────────────────────────────────

/// Which top-level header tab an extension nav-item or route belongs to.
enum ExtensionTab {
  /// The "Data" tab (tasks, workflows, plugins, …).
  data,

  /// The "Pages" tab (CMS, page builder, …).
  pages,
}

// ── Route contribution ────────────────────────────────────────────────────────

/// A GoRoute contributed by an extension.
class ExtensionRoute {
  final String path;
  final GoRouterWidgetBuilder builder;

  /// Which header tab this route's path prefix belongs to.
  final ExtensionTab tab;

  const ExtensionRoute({
    required this.path,
    required this.builder,
    this.tab = ExtensionTab.data,
  });

  GoRoute to_go_route() => GoRoute(path: path, builder: builder);
}

// ── Navigation item contribution ──────────────────────────────────────────────

/// A sidebar / bottom-nav item contributed by an extension.
class ExtensionNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final ExtensionTab tab;

  /// If true, rendered as a sub-item (indented) inside a section header.
  final bool isSubItem;

  const ExtensionNavItem({
    required this.label,
    required this.icon,
    required this.route,
    IconData? activeIcon,
    this.tab = ExtensionTab.data,
    this.isSubItem = false,
  }) : activeIcon = activeIcon ?? icon;
}

// ── Zone contribution ─────────────────────────────────────────────────────────

/// A widget injected into a named zone slot by an extension.
class ExtensionZoneEntry {
  /// The zone ID to inject into, e.g. `'dashboard.stats_section'`.
  final String zoneId;
  final WidgetBuilder builder;

  const ExtensionZoneEntry({required this.zoneId, required this.builder});
}

// ── Palette item contribution ─────────────────────────────────────────────────

/// A widget type added to the Page Builder palette by an extension.
class ExtensionPaletteItem {
  final String type;
  final IconData icon;
  final String label;

  /// Optional builder for the preview shown in the canvas.
  /// Falls back to a generic placeholder if null.
  final WidgetBuilder? canvasBuilder;

  const ExtensionPaletteItem({
    required this.type,
    required this.icon,
    required this.label,
    this.canvasBuilder,
  });
}

// ── Manifest ──────────────────────────────────────────────────────────────────

/// Everything an extension plugin can contribute to FuzzyBoard.
///
/// Create an instance and register it via [ExtensionRegistry.register] at
/// app startup (or when the plugin is installed at runtime).
///
/// Example:
/// ```dart
/// final myPlugin = ExtensionManifest(
///   pluginId: 'acme_analytics',
///   navItems: [
///     ExtensionNavItem(
///       label: 'Analytics',
///       icon: Icons.bar_chart,
///       route: '/analytics',
///       tab: ExtensionTab.data,
///     ),
///   ],
///   zones: [
///     ExtensionZoneEntry(
///       zoneId: 'dashboard.stats_section',
///       builder: (ctx) => AcmeStatsCard(),
///     ),
///   ],
///   routes: [
///     ExtensionRoute(path: '/analytics', builder: (_, __) => AnalyticsPage()),
///   ],
/// );
/// ```
class ExtensionManifest {
  final String pluginId;
  final List<ExtensionRoute> routes;
  final List<ExtensionNavItem> navItems;
  final List<ExtensionZoneEntry> zones;
  final List<ExtensionPaletteItem> paletteItems;

  const ExtensionManifest({
    required this.pluginId,
    this.routes = const [],
    this.navItems = const [],
    this.zones = const [],
    this.paletteItems = const [],
  });
}
