import 'package:flutter/material.dart';
import 'package:fuzzyboard/extensions/extension_manifest.dart';

// ── Demo Extension ─────────────────────────────────────────────────────────────
//
// This file shows how an extension package declares everything it contributes
// to FuzzyBoard in a single [ExtensionManifest].
//
// Register it at startup (or when the plugin is installed) via:
//
//   extensionRegistry.register(demoExtension);
//
// Unregister it when the plugin is uninstalled via:
//
//   extensionRegistry.unregister(demoExtension.pluginId);
//
// ─────────────────────────────────────────────────────────────────────────────

/// The complete manifest for the "Acme Analytics" demo extension.
final demoExtension = ExtensionManifest(
  pluginId: 'acme_analytics',

  // ── 1. Adds a new top-level route to the shell ─────────────────────────────
  routes: [
    ExtensionRoute(
      path: '/analytics',
      tab: ExtensionTab.data,
      builder: (_, __) => const _AnalyticsPage(),
    ),
  ],

  // ── 2. Adds a nav item to the Data sidebar ─────────────────────────────────
  navItems: [
    const ExtensionNavItem(
      label: 'Analytics',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      route: '/analytics',
      tab: ExtensionTab.data,
    ),
  ],

  // ── 3. Injects widgets into named zones on built-in pages ──────────────────
  zones: [
    // Adds an info banner at the very top of the Dashboard (below SpaceXpBar)
    ExtensionZoneEntry(
      zoneId: 'dashboard.header_end',
      builder: (ctx) => const _DemoHeaderBanner(),
    ),
    // Adds an extra stat card row below the four built-in stat cards
    ExtensionZoneEntry(
      zoneId: 'dashboard.stats_section',
      builder: (ctx) => const _DemoStatsCard(),
    ),
    // Adds an analytics section at the bottom of Settings
    ExtensionZoneEntry(
      zoneId: 'settings.bottom',
      builder: (ctx) => const _DemoSettingsSection(),
    ),
  ],

  // ── 4. Adds a custom widget type to the Page Builder palette ───────────────
  paletteItems: [
    ExtensionPaletteItem(
      type: 'AcmeChart',
      icon: Icons.bar_chart,
      label: 'Acme Chart',
      canvasBuilder: (ctx) => const _AcmeChartPreview(),
    ),
  ],
);

// ── Demo page ─────────────────────────────────────────────────────────────────

class _AnalyticsPage extends StatelessWidget {
  const _AnalyticsPage();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Acme Analytics')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 64, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Acme Analytics',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'This page was registered by the demo extension.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Zone widgets ──────────────────────────────────────────────────────────────

class _DemoHeaderBanner extends StatelessWidget {
  const _DemoHeaderBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.bar_chart, color: Color(0xFF8B5CF6), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Acme Analytics: 12 events recorded today.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.8),
                ),
          ),
        ),
      ]),
    );
  }
}

class _DemoStatsCard extends StatelessWidget {
  const _DemoStatsCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.bar_chart, color: Color(0xFF8B5CF6), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Acme Events (Today)',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: cs.onSurface.withOpacity(0.6))),
            Text('12',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ]),
        ),
      ]),
    );
  }
}

class _DemoSettingsSection extends StatelessWidget {
  const _DemoSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.bar_chart, color: Color(0xFF8B5CF6), size: 18),
          const SizedBox(width: 8),
          Text('Acme Analytics Settings',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Text(
          'Configure your Acme Analytics integration here.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
      ]),
    );
  }
}

// ── Page builder canvas preview ───────────────────────────────────────────────

class _AcmeChartPreview extends StatelessWidget {
  const _AcmeChartPreview();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.bar_chart, color: Color(0xFF8B5CF6), size: 16),
        const SizedBox(width: 8),
        Text('Acme Chart widget',
            style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
