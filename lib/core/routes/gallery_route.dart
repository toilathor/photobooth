class GalleryRoute {
  static const String prefix = '/gallery/';
  static final RegExp _sectionIdPattern = RegExp(r'^[A-Za-z0-9_-]{10,200}$');

  static bool matches(Uri uri) => uri.fragment.startsWith(prefix);

  static String? sectionIdFrom(Uri uri) {
    if (!matches(uri)) return null;
    final value = Uri.decodeComponent(uri.fragment.substring(prefix.length));
    return _sectionIdPattern.hasMatch(value) ? value : null;
  }

  static String location(String sectionId) => '$prefix$sectionId';
}
