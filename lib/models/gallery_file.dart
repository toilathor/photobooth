class GalleryFile {
  final String id;
  final String name;
  final String mimeType;
  final String? thumbnailLink;
  final String? webViewLink;
  final DateTime? createdTime;

  const GalleryFile({
    required this.id,
    required this.name,
    required this.mimeType,
    this.thumbnailLink,
    this.webViewLink,
    this.createdTime,
  });

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');
  bool get isMedia => isImage || isVideo;

  factory GalleryFile.fromJson(Map<String, Object?> json) {
    final createdTime = json['createdTime'] as String?;
    final id = json['id'] as String;
    return GalleryFile(
      id: id,
      name: json['name'] as String? ?? id,
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      thumbnailLink: json['thumbnailLink'] as String?,
      webViewLink: json['webViewLink'] as String?,
      createdTime: createdTime == null ? null : DateTime.tryParse(createdTime),
    );
  }

  String contentUrl(String apiKey) => Uri.https(
    'www.googleapis.com',
    '/drive/v3/files/$id',
    {'alt': 'media', 'key': apiKey},
  ).toString();

  /// Direct download link for a publicly shared Drive file.
  String get downloadUrl => Uri.https('drive.google.com', '/uc', {
    'export': 'download',
    'id': id,
  }).toString();
}
