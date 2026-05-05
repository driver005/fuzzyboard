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
///
/// When the zone is embedded inside a [Row] (or any context with unbounded
/// width) pass [crossAxisAlignment: CrossAxisAlignment.start] to avoid layout
/// assertions.  The default is [CrossAxisAlignment.start] which is safe in
/// all contexts; callers that want children to fill the available width should
/// explicitly pass [CrossAxisAlignment.stretch].
class ExtensionZone extends StatelessWidget {
  /// Zone identifier, following the convention `<page_slug>.<location>`.
  final String id;

  /// Controls how zone children are aligned on the cross axis (horizontal
  /// when the Column is laid out vertically).  Defaults to
  /// [CrossAxisAlignment.start] which is safe in both unbounded and bounded
  /// contexts.
  final CrossAxisAlignment crossAxisAlignment;

  const ExtensionZone({
    super.key,
    required this.id,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final registry = context.watch<ExtensionRegistry>();
    final builders = registry.active_builders_for(id);
    if (builders.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: builders.map((b) => b(context)).toList(),
    );
  }
}
