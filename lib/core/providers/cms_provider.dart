import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/cms_content_type.dart';
import '../../models/cms_entry.dart';
import '../../models/cms_media.dart';
import '../../models/cms_page.dart';
import '../../models/cms_category.dart';

class CmsProvider extends ChangeNotifier {
  final uuid = const Uuid();

  // ── Content Types ─────────────────────────────────────────────────────────
  final List<CmsContentType> contentTypes = [
    CmsContentType(
      id: 'ct-1',
      name: 'Blog Post',
      apiId: 'blog-post',
      description: 'Standard blog article with rich text content.',
      icon: Icons.article,
      color: const Color(0xFF6C63FF),
      entryCount: 12,
      createdAt: DateTime(2024, 1, 1),
      fields: [
        CmsField(id: 'f-1', name: 'Title', apiId: 'title', type: CmsFieldType.text, required: true),
        CmsField(id: 'f-2', name: 'Body', apiId: 'body', type: CmsFieldType.richText, required: true),
        CmsField(id: 'f-3', name: 'Cover Image', apiId: 'cover_image', type: CmsFieldType.image),
        CmsField(id: 'f-4', name: 'Published At', apiId: 'published_at', type: CmsFieldType.date),
        CmsField(id: 'f-5', name: 'Status', apiId: 'status', type: CmsFieldType.select, selectOptions: ['draft', 'published', 'archived']),
      ],
    ),
    CmsContentType(
      id: 'ct-2',
      name: 'Product',
      apiId: 'product',
      description: 'E-commerce product with pricing and images.',
      icon: Icons.inventory_2,
      color: const Color(0xFF10B981),
      entryCount: 47,
      createdAt: DateTime(2024, 1, 15),
      fields: [
        CmsField(id: 'f-6', name: 'Name', apiId: 'name', type: CmsFieldType.text, required: true),
        CmsField(id: 'f-7', name: 'Price', apiId: 'price', type: CmsFieldType.number, required: true),
        CmsField(id: 'f-8', name: 'Description', apiId: 'description', type: CmsFieldType.richText),
        CmsField(id: 'f-9', name: 'In Stock', apiId: 'in_stock', type: CmsFieldType.boolean),
        CmsField(id: 'f-10', name: 'Image', apiId: 'image', type: CmsFieldType.image),
      ],
    ),
    CmsContentType(
      id: 'ct-3',
      name: 'FAQ',
      apiId: 'faq',
      description: 'Frequently asked questions.',
      icon: Icons.quiz,
      color: const Color(0xFFF59E0B),
      entryCount: 8,
      createdAt: DateTime(2024, 2, 1),
      fields: [
        CmsField(id: 'f-11', name: 'Question', apiId: 'question', type: CmsFieldType.text, required: true),
        CmsField(id: 'f-12', name: 'Answer', apiId: 'answer', type: CmsFieldType.richText, required: true),
        CmsField(id: 'f-13', name: 'Category', apiId: 'category', type: CmsFieldType.reference),
      ],
    ),
  ];

  void addContentType(CmsContentType ct) {
    contentTypes.add(ct);
    notifyListeners();
  }

  void updateContentType(CmsContentType ct) {
    final idx = contentTypes.indexWhere((t) => t.id == ct.id);
    if (idx != -1) { contentTypes[idx] = ct; notifyListeners(); }
  }

  void deleteContentType(String id) {
    contentTypes.removeWhere((t) => t.id == id);
    entries.removeWhere((e) => e.contentTypeId == id);
    notifyListeners();
  }

  // ── Entries ───────────────────────────────────────────────────────────────
  final List<CmsEntry> entries = [
    CmsEntry(
      id: 'en-1', contentTypeId: 'ct-1',
      title: 'Getting Started with FuzzyBoard',
      status: CmsEntryStatus.published,
      author: 'Admin',
      fields: {'body': 'Welcome to FuzzyBoard! This guide walks you through the basics.', 'published_at': '2024-03-01'},
      createdAt: DateTime(2024, 3, 1), updatedAt: DateTime(2024, 3, 1),
    ),
    CmsEntry(
      id: 'en-2', contentTypeId: 'ct-1',
      title: 'Building Workflows with the Visual Editor',
      status: CmsEntryStatus.published,
      author: 'Admin',
      fields: {'body': 'Learn how to build powerful automations using drag-and-drop.'},
      createdAt: DateTime(2024, 3, 5), updatedAt: DateTime(2024, 3, 6),
    ),
    CmsEntry(
      id: 'en-3', contentTypeId: 'ct-1',
      title: 'Advanced Lua Scripting',
      status: CmsEntryStatus.draft,
      author: 'Editor',
      fields: {'body': 'Draft content for advanced scripting guide.'},
      createdAt: DateTime(2024, 3, 10), updatedAt: DateTime(2024, 3, 10),
    ),
    CmsEntry(
      id: 'en-4', contentTypeId: 'ct-2',
      title: 'FuzzyBoard Pro License',
      status: CmsEntryStatus.published,
      author: 'Admin',
      fields: {'price': 99.0, 'in_stock': true, 'description': 'Annual license for FuzzyBoard Pro.'},
      createdAt: DateTime(2024, 2, 1), updatedAt: DateTime(2024, 2, 1),
    ),
    CmsEntry(
      id: 'en-5', contentTypeId: 'ct-2',
      title: 'Plugin Bundle Pack',
      status: CmsEntryStatus.draft,
      author: 'Editor',
      fields: {'price': 29.0, 'in_stock': true},
      createdAt: DateTime(2024, 2, 15), updatedAt: DateTime(2024, 2, 16),
    ),
  ];

  List<CmsEntry> entriesForType(String contentTypeId) =>
      entries.where((e) => e.contentTypeId == contentTypeId).toList();

  void addEntry(CmsEntry entry) {
    entries.add(entry);
    final idx = contentTypes.indexWhere((t) => t.id == entry.contentTypeId);
    if (idx != -1) contentTypes[idx].entryCount++;
    notifyListeners();
  }

  void updateEntry(CmsEntry entry) {
    final idx = entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) { entries[idx] = entry; notifyListeners(); }
  }

  void deleteEntry(String id) {
    final idx = entries.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final entry = entries[idx];
    final typeIdx = contentTypes.indexWhere((t) => t.id == entry.contentTypeId);
    if (typeIdx != -1 && contentTypes[typeIdx].entryCount > 0) contentTypes[typeIdx].entryCount--;
    entries.removeAt(idx);
    notifyListeners();
  }

  void publishEntry(String id) {
    final idx = entries.indexWhere((e) => e.id == id);
    if (idx != -1) { entries[idx].status = CmsEntryStatus.published; notifyListeners(); }
  }

  void archiveEntry(String id) {
    final idx = entries.indexWhere((e) => e.id == id);
    if (idx != -1) { entries[idx].status = CmsEntryStatus.archived; notifyListeners(); }
  }

  // ── Media ─────────────────────────────────────────────────────────────────
  final List<CmsMedia> mediaItems = [
    CmsMedia(id: 'm-1', name: 'hero-banner.jpg', url: 'https://picsum.photos/seed/fuzzy1/800/400', type: CmsMediaType.image, sizeBytes: 245000, width: 800, height: 400, uploadedAt: DateTime(2024, 1, 10)),
    CmsMedia(id: 'm-2', name: 'product-shot.png', url: 'https://picsum.photos/seed/fuzzy2/400/400', type: CmsMediaType.image, sizeBytes: 128000, width: 400, height: 400, uploadedAt: DateTime(2024, 1, 12)),
    CmsMedia(id: 'm-3', name: 'team-photo.jpg', url: 'https://picsum.photos/seed/fuzzy3/600/400', type: CmsMediaType.image, sizeBytes: 312000, width: 600, height: 400, uploadedAt: DateTime(2024, 2, 5)),
    CmsMedia(id: 'm-4', name: 'logo-dark.png', url: 'https://picsum.photos/seed/fuzzy4/200/200', type: CmsMediaType.image, sizeBytes: 32000, width: 200, height: 200, uploadedAt: DateTime(2024, 2, 8)),
    CmsMedia(id: 'm-5', name: 'screenshot-v1.png', url: 'https://picsum.photos/seed/fuzzy5/1200/800', type: CmsMediaType.image, sizeBytes: 890000, width: 1200, height: 800, uploadedAt: DateTime(2024, 3, 1)),
    CmsMedia(id: 'm-6', name: 'avatar.jpg', url: 'https://picsum.photos/seed/fuzzy6/150/150', type: CmsMediaType.image, sizeBytes: 18000, width: 150, height: 150, uploadedAt: DateTime(2024, 3, 5)),
    CmsMedia(id: 'm-7', name: 'background.jpg', url: 'https://picsum.photos/seed/fuzzy7/1920/1080', type: CmsMediaType.image, sizeBytes: 1240000, width: 1920, height: 1080, uploadedAt: DateTime(2024, 3, 10)),
    CmsMedia(id: 'm-8', name: 'icon-set.png', url: 'https://picsum.photos/seed/fuzzy8/512/512', type: CmsMediaType.image, sizeBytes: 76000, width: 512, height: 512, uploadedAt: DateTime(2024, 3, 12)),
    CmsMedia(id: 'm-9', name: 'user-guide.pdf', url: '', type: CmsMediaType.document, sizeBytes: 2100000, mimeType: 'application/pdf', uploadedAt: DateTime(2024, 3, 15)),
  ];

  void addMedia(CmsMedia media) {
    mediaItems.add(media);
    notifyListeners();
  }

  void deleteMedia(String id) {
    mediaItems.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // ── Pages ─────────────────────────────────────────────────────────────────
  final List<CmsPage> pages = [
    CmsPage(id: 'pg-1', title: 'Home', slug: '/', template: 'hero', status: CmsPageStatus.published, seoTitle: 'FuzzyBoard — Workflow Engine', seoDescription: 'The best workflow automation platform.', createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 3, 20)),
    CmsPage(id: 'pg-2', title: 'About', slug: '/about', template: 'default', status: CmsPageStatus.published, seoTitle: 'About FuzzyBoard', seoDescription: 'Learn about the team and mission.', createdAt: DateTime(2024, 1, 2), updatedAt: DateTime(2024, 2, 10)),
    CmsPage(id: 'pg-3', title: 'Pricing', slug: '/pricing', template: 'pricing', status: CmsPageStatus.published, seoTitle: 'FuzzyBoard Pricing', seoDescription: 'Plans for every team size.', createdAt: DateTime(2024, 1, 5), updatedAt: DateTime(2024, 3, 1)),
    CmsPage(id: 'pg-4', title: 'Blog', slug: '/blog', template: 'list', status: CmsPageStatus.published, seoTitle: 'FuzzyBoard Blog', seoDescription: 'Tips, tutorials and updates.', createdAt: DateTime(2024, 2, 1), updatedAt: DateTime(2024, 3, 10)),
    CmsPage(id: 'pg-5', title: 'Contact', slug: '/contact', template: 'form', status: CmsPageStatus.draft, seoTitle: 'Contact Us', seoDescription: 'Get in touch with our team.', createdAt: DateTime(2024, 2, 5), updatedAt: DateTime(2024, 2, 5)),
    CmsPage(id: 'pg-6', title: 'Launch Promo', slug: '/launch', template: 'landing', status: CmsPageStatus.scheduled, seoTitle: 'FuzzyBoard v2 Launch', seoDescription: 'Coming soon — our biggest release ever.', createdAt: DateTime(2024, 3, 20), updatedAt: DateTime(2024, 3, 20)),
  ];

  void addPage(CmsPage page) {
    pages.add(page);
    notifyListeners();
  }

  void updatePage(CmsPage page) {
    final idx = pages.indexWhere((p) => p.id == page.id);
    if (idx != -1) { pages[idx] = page; notifyListeners(); }
  }

  void deletePage(String id) {
    pages.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ── Categories ────────────────────────────────────────────────────────────
  final List<CmsCategory> categories = [
    CmsCategory(id: 'cat-1', name: 'Tutorials', slug: 'tutorials', description: 'Step-by-step guides and how-tos.', color: const Color(0xFF6C63FF), entryCount: 8, createdAt: DateTime(2024, 1, 1)),
    CmsCategory(id: 'cat-2', name: 'Announcements', slug: 'announcements', description: 'Product updates and news.', color: const Color(0xFF10B981), entryCount: 5, createdAt: DateTime(2024, 1, 10)),
    CmsCategory(id: 'cat-3', name: 'Case Studies', slug: 'case-studies', description: 'Real-world use cases and success stories.', color: const Color(0xFF3B82F6), entryCount: 3, createdAt: DateTime(2024, 2, 1)),
    CmsCategory(id: 'cat-4', name: 'Engineering', slug: 'engineering', description: 'Technical deep dives from the team.', color: const Color(0xFFF59E0B), entryCount: 6, createdAt: DateTime(2024, 2, 15)),
    CmsCategory(id: 'cat-5', name: 'Community', slug: 'community', description: 'Community spotlights and events.', color: const Color(0xFFEC4899), entryCount: 2, createdAt: DateTime(2024, 3, 1)),
  ];

  void addCategory(CmsCategory cat) {
    categories.add(cat);
    notifyListeners();
  }

  void updateCategory(CmsCategory cat) {
    final idx = categories.indexWhere((c) => c.id == cat.id);
    if (idx != -1) { categories[idx] = cat; notifyListeners(); }
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ── Stats helpers ─────────────────────────────────────────────────────────
  int get totalEntries => entries.length;
  int get publishedEntries => entries.where((e) => e.status == CmsEntryStatus.published).length;
  int get draftEntries => entries.where((e) => e.status == CmsEntryStatus.draft).length;
  int get totalMedia => mediaItems.length;
  int get totalPages => pages.length;
  int get publishedPages => pages.where((p) => p.status == CmsPageStatus.published).length;
}
