import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/cms_provider.dart';
import '../../models/cms_media.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';

class MediaLibraryPage extends StatefulWidget {
  const MediaLibraryPage({super.key});
  @override
  State<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends State<MediaLibraryPage> {
  final uuid = const Uuid();
  bool gridView = true;
  CmsMediaType? filterType;
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    final cms = context.watch<CmsProvider>();
    final filtered = filterType == null ? cms.mediaItems : cms.mediaItems.where((m) => m.type == filterType).toList();
    final selected = selectedId != null
        ? filtered.where((m) => m.id == selectedId).isEmpty
            ? null
            : filtered.firstWhere((m) => m.id == selectedId)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
        actions: [
          AppButton(
            label: 'Upload',
            icon: const Icon(Icons.upload),
            size: AppButtonSize.sm,
            onPressed: () => _simulateUpload(context),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(gridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => gridView = !gridView),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(children: [
        Expanded(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(label: Text('All (${cms.mediaItems.length})'), selected: filterType == null, onSelected: (_) => setState(() => filterType = null)),
                    ),
                    ...CmsMediaType.values.map((t) {
                      final count = cms.mediaItems.where((m) => m.type == t).length;
                      if (count == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(label: Text('${t.name} ($count)'), selected: filterType == t, onSelected: (_) => setState(() => filterType = t)),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No media files yet'))
                  : gridView
                      ? _MediaGrid(items: filtered, selectedId: selectedId, onSelect: (id) => setState(() => selectedId = selectedId == id ? null : id))
                      : _MediaList(items: filtered, selectedId: selectedId, onSelect: (id) => setState(() => selectedId = selectedId == id ? null : id)),
            ),
          ]),
        ),
        if (selected != null) ...[
          const VerticalDivider(width: 1),
          _MediaDetails(
            media: selected,
            onClose: () => setState(() => selectedId = null),
            onDelete: () {
              context.read<CmsProvider>().deleteMedia(selected.id);
              setState(() => selectedId = null);
            },
          ),
        ],
      ]),
    );
  }

  void _simulateUpload(BuildContext context) {
    final names = ['new-image.jpg', 'screenshot.png', 'photo.jpg', 'graphic.png'];
    final name = names[DateTime.now().second % names.length];
    final id = uuid.v4();
    context.read<CmsProvider>().addMedia(CmsMedia(
      id: id, name: name,
      url: 'https://picsum.photos/seed/$id/400/300',
      sizeBytes: 100000 + DateTime.now().millisecond * 1000,
      width: 400, height: 300,
      uploadedAt: DateTime.now(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded: $name')));
  }
}

class _MediaGrid extends StatelessWidget {
  final List<CmsMedia> items;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  const _MediaGrid({required this.items, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 160, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        final isSelected = m.id == selectedId;
        return GestureDetector(
          onTap: () => onSelect(m.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? cs.primary : cs.outline.withOpacity(0.2), width: isSelected ? 2 : 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              if (m.type == CmsMediaType.image && m.url.isNotEmpty)
                Positioned.fill(child: Image.network(m.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: cs.surface, child: const Icon(Icons.broken_image_outlined))))
              else
                Container(color: cs.surface, child: Center(child: Icon(_iconForType(m.type), size: 36, color: cs.onSurface.withOpacity(0.3)))),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.6)])),
                  child: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
              if (isSelected)
                Positioned(top: 6, right: 6, child: Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.check_circle, color: cs.primary, size: 20))),
            ]),
          ).animate(delay: Duration(milliseconds: i * 30)).fadeIn().scale(begin: const Offset(0.95, 0.95)),
        );
      },
    );
  }

  IconData _iconForType(CmsMediaType t) => switch (t) {
    CmsMediaType.image => Icons.image_outlined,
    CmsMediaType.video => Icons.videocam_outlined,
    CmsMediaType.document => Icons.description_outlined,
    CmsMediaType.audio => Icons.audio_file_outlined,
    CmsMediaType.other => Icons.attach_file,
  };
}

class _MediaList extends StatelessWidget {
  final List<CmsMedia> items;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  const _MediaList({required this.items, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        return AppCard(
          leading: SizedBox(
            width: 48, height: 48,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: m.type == CmsMediaType.image && m.url.isNotEmpty
                  ? Image.network(m.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined))
                  : Container(color: Theme.of(context).colorScheme.surface, child: const Icon(Icons.attach_file)),
            ),
          ),
          title: m.name,
          subtitle: '${m.formattedSize}${m.width != null ? ' • ${m.width}×${m.height}' : ''}',
          onTap: () => onSelect(m.id),
        );
      },
    );
  }
}

class _MediaDetails extends StatelessWidget {
  final CmsMedia media;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  const _MediaDetails({required this.media, required this.onClose, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Details', style: Theme.of(context).textTheme.titleSmall),
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose),
        ]),
        const SizedBox(height: 12),
        if (media.type == CmsMediaType.image && media.url.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(media.url, height: 140, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 140, color: Theme.of(context).colorScheme.surface, child: const Center(child: Icon(Icons.broken_image_outlined)))),
          ),
        const SizedBox(height: 12),
        _detail(context, 'Name', media.name),
        _detail(context, 'Size', media.formattedSize),
        _detail(context, 'Type', media.mimeType),
        if (media.width != null) _detail(context, 'Dimensions', '${media.width}×${media.height}'),
        _detail(context, 'Uploaded', '${media.uploadedAt.year}-${media.uploadedAt.month.toString().padLeft(2, '0')}-${media.uploadedAt.day.toString().padLeft(2, '0')}'),
        _detail(context, 'By', media.uploadedBy),
        const Spacer(),
        AppButton(label: 'Delete', icon: const Icon(Icons.delete_outline), variant: AppButtonVariant.danger, size: AppButtonSize.sm, fullWidth: true, onPressed: onDelete),
      ]),
    );
  }

  Widget _detail(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        Text(value, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
