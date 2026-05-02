enum CmsMediaType { image, video, document, audio, other }

class CmsMedia {
  final String id;
  String name;
  String url;
  CmsMediaType type;
  int sizeBytes;
  int? width;
  int? height;
  String mimeType;
  DateTime uploadedAt;
  String uploadedBy;

  CmsMedia({
    required this.id,
    required this.name,
    required this.url,
    this.type = CmsMediaType.image,
    this.sizeBytes = 0,
    this.width,
    this.height,
    this.mimeType = 'image/jpeg',
    required this.uploadedAt,
    this.uploadedBy = 'Admin',
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '${sizeBytes}B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
