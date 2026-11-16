import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/gallery/providers/gallery.provider.dart';
import 'package:th_photobooth/models/gallery_file.dart';
import 'package:th_photobooth/services/gallery_service.dart';

void main() {
  test('loads media files and manages the selected index', () async {
    final service = _GalleryService(const [
      GalleryFile(id: 'one', name: 'one.jpg', mimeType: 'image/jpeg'),
      GalleryFile(id: 'skip', name: 'notes.txt', mimeType: 'text/plain'),
      GalleryFile(id: 'two', name: 'two.mp4', mimeType: 'video/mp4'),
    ]);
    final provider = GalleryProvider(service: service);

    await provider.load('section_123456');

    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
    expect(provider.files.map((file) => file.name), ['one.jpg', 'two.mp4']);
    expect(provider.selectedIndex, 0);

    provider.select(1);
    expect(provider.selectedIndex, 1);

    provider.dispose();
    service.close();
  });
}

class _GalleryService extends GalleryService {
  final List<GalleryFile> files;

  _GalleryService(this.files);

  @override
  Future<List<GalleryFile>> listFiles(String sectionId) async => files;
}
