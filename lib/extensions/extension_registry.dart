import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'extension_manifest.dart';

/// Tracks every [ExtensionManifest] that has been registered and exposes the
/// aggregated contributions (routes, nav items, zone builders, palette items)
/// to the rest of the app.
///
/// Add this as a [ChangeNotifierProvider] **before** [createRouter] is called
/// so that extra routes from plugins are wired into GoRouter at startup.
class ExtensionRegistry extends ChangeNotifier {
  // pluginId → manifest
  final Map<String, ExtensionManifest> _manifests = {};

  // zoneId → [(pluginId, builder)]  (ordered by registration time)
  final Map<String, List<_ZoneContribution>> _zones = {};

  // ── Public read-only views ────────────────────────────────────────────────

  /// All [GoRoute]s contributed by registered extensions.
  List<GoRoute> get extraRoutes => _manifests.values
      .expand((m) => m.routes)
      .map((r) => r.to_go_route())
      .toList();

  /// All nav items contributed by registered extensions.
  List<ExtensionNavItem> get navItems =>
      _manifests.values.expand((m) => m.navItems).toList();

  /// All palette items contributed by registered extensions.
  List<ExtensionPaletteItem> get paletteItems =>
      _manifests.values.expand((m) => m.paletteItems).toList();

  /// Every registered manifest, keyed by pluginId.
  Map<String, ExtensionManifest> get manifests =>
      Map.unmodifiable(_manifests);

  /// Zone contributions with metadata (used by the Dev Mode inspector).
  Map<String, List<_ZoneContribution>> get zoneContributions =>
      Map.unmodifiable(_zones);

  // ── Mutation ──────────────────────────────────────────────────────────────

  /// Register an extension manifest. Safe to call multiple times with the
  /// same [pluginId] — later calls replace the previous registration.
  void register(ExtensionManifest manifest) {
    // If already registered, clean up old zone entries first.
    if (_manifests.containsKey(manifest.pluginId)) {
      _remove_zones(manifest.pluginId);
    }
    _manifests[manifest.pluginId] = manifest;
    for (final entry in manifest.zones) {
      _zones
          .putIfAbsent(entry.zoneId, () => [])
          .add(_ZoneContribution(
            pluginId: manifest.pluginId,
            builder: entry.builder,
          ));
    }
    notifyListeners();
  }

  /// Unregister an extension manifest by [pluginId].
  void unregister(String pluginId) {
    _manifests.remove(pluginId);
    _remove_zones(pluginId);
    notifyListeners();
  }

  /// Returns the ordered list of [WidgetBuilder]s for the given [zoneId].
  /// Returns an empty list when no extension contributes to that zone.
  List<WidgetBuilder> builders_for(String zoneId) =>
      (_zones[zoneId] ?? []).map((c) => c.builder).toList();

  // ── Per-zone enable/disable (dev-mode inspector) ──────────────────────────

  /// Zone+plugin pairs that have been explicitly disabled via the inspector.
  final Set<String> _disabled = {};

  String _disable_key(String zoneId, String pluginId) => '$zoneId::$pluginId';

  bool is_disabled(String zoneId, String pluginId) =>
      _disabled.contains(_disable_key(zoneId, pluginId));

  void toggle_zone_contribution(String zoneId, String pluginId) {
    final key = _disable_key(zoneId, pluginId);
    if (_disabled.contains(key)) {
      _disabled.remove(key);
    } else {
      _disabled.add(key);
    }
    notifyListeners();
  }

  /// Returns builders for [zoneId], filtered by the disabled set.
  List<WidgetBuilder> active_builders_for(String zoneId) {
    return (_zones[zoneId] ?? [])
        .where((c) => !is_disabled(zoneId, c.pluginId))
        .map((c) => c.builder)
        .toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _remove_zones(String pluginId) {
    for (final list in _zones.values) {
      list.removeWhere((c) => c.pluginId == pluginId);
    }
    _zones.removeWhere((_, list) => list.isEmpty);
    _disabled.removeWhere((key) => key.contains('::$pluginId'));
  }
}

/// Internal record that stores a zone builder together with its origin plugin.
class _ZoneContribution {
  final String pluginId;
  final WidgetBuilder builder;
  const _ZoneContribution({required this.pluginId, required this.builder});
}
