enum CmsEntryStatus { draft, published, archived }

class CmsEntry {
  final String id;
  final String contentTypeId;
  String title;
  Map<String, dynamic> fields;
  CmsEntryStatus status;
  DateTime createdAt;
  DateTime updatedAt;
  String author;

  CmsEntry({
    required this.id,
    required this.contentTypeId,
    required this.title,
    this.fields = const {},
    this.status = CmsEntryStatus.draft,
    required this.createdAt,
    required this.updatedAt,
    this.author = 'Admin',
  });
}
