import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/core/routes/gallery_route.dart';

void main() {
  test('parses a valid Gallery section from the hash route', () {
    final uri = Uri.parse(
      'https://toilathor.github.io/photobooth/#/gallery/abc_DEF-123456',
    );

    expect(GalleryRoute.matches(uri), isTrue);
    expect(GalleryRoute.sectionIdFrom(uri), 'abc_DEF-123456');
  });

  test('rejects an invalid gallery section', () {
    final uri = Uri.parse(
      'https://toilathor.github.io/photobooth/#/gallery/not%20valid',
    );

    expect(GalleryRoute.matches(uri), isTrue);
    expect(GalleryRoute.sectionIdFrom(uri), isNull);
  });
}
