class PageWidget {
  final String id;
  final String type;
  String label;
  Map<String, dynamic> config;

  PageWidget({
    required this.id,
    required this.type,
    required this.label,
    Map<String, dynamic>? config,
  }) : config = config ?? {};
}
