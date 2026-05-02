enum CmsPageStatus { draft, published, scheduled }

class CmsPage {
  final String id;
  String title;
  String slug;
  String template;
  CmsPageStatus status;
  String seoTitle;
  String seoDescription;
  DateTime createdAt;
  DateTime updatedAt;
  String author;

  CmsPage({
    required this.id,
    required this.title,
    required this.slug,
    this.template = 'default',
    this.status = CmsPageStatus.draft,
    this.seoTitle = '',
    this.seoDescription = '',
    required this.createdAt,
    required this.updatedAt,
    this.author = 'Admin',
  });
}
