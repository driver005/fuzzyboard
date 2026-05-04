import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'extension_registry.dart';

/// Renders all widgets contributed by extensions to the named zone [id].
///
/// Drop this widget anywhere inside a page to make that location pluggable:
///
/// ```dart
/// ExtensionZone(id: 'dashboard.stats_section')
/// ```
///
/// When no extension contributes to the zone this widget renders nothing
/// (a zero-size [SizedBox]).  Contributions are rendered in registration
/// order, wrapped in a [Column] with [MainAxisSize.min].
class ExtensionZone extends StatelessWidget {
  /// Zone identifier, following the convention `<page_slug>.<location>`.
  final String id;

  const ExtensionZone({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final registry = context.watch<ExtensionRegistry>();
    final builders = registry.active_builders_for(id);
    if (builders.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: builders.map((b) => b(context)).toList(),
    );
  }
}
