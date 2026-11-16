import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/gallery/providers/gallery.provider.dart';
import 'package:th_photobooth/features/gallery/screens/gallery.screen.dart';
import 'package:th_photobooth/features/gallery/widgets/gallery_lightbox.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/gallery_file.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('opens with the lightbox and image list visible', (tester) async {
    await tester.pumpWidget(
      testApp(
        child: GalleryScreen(
          sectionId: 'section_123456',
          provider: _GalleryProvider(
            files: const [
              GalleryFile(
                id: 'image-id',
                name: 'photo.jpg',
                mimeType: 'image/jpeg',
              ),
              GalleryFile(
                id: 'image-two',
                name: 'photo-two.jpg',
                mimeType: 'image/jpeg',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('photo.jpg'), findsOneWidget);
    expect(find.byType(GalleryLightbox), findsOneWidget);
    expect(find.byKey(const ValueKey('gallery-lightbox')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('gallery-thumbnail-list')),
      findsOneWidget,
    );
    expect(find.text('1/2'), findsOneWidget);

    await tester.tap(
      find.bySemanticsLabel(t.gallery.openFile(name: 'photo-two.jpg')),
    );
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsOneWidget);
  });

  testWidgets('shows an empty state', (tester) async {
    await tester.pumpWidget(
      testApp(
        child: GalleryScreen(
          sectionId: 'section_123456',
          provider: _GalleryProvider(files: const []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.gallery.emptyTitle), findsOneWidget);
  });

  testWidgets('fits the gallery lightbox on a 375 px viewport', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: GalleryScreen(
          sectionId: 'section_123456',
          provider: _GalleryProvider(
            files: const [
              GalleryFile(id: 'one', name: 'one.jpg', mimeType: 'image/jpeg'),
              GalleryFile(id: 'two', name: 'two.mp4', mimeType: 'video/mp4'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('one.jpg'), findsOneWidget);
    expect(
      find.bySemanticsLabel(t.gallery.openFile(name: 'two.mp4')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

class _GalleryProvider extends GalleryProvider {
  _GalleryProvider({required List<GalleryFile> files}) {
    this.files = files;
    isLoading = false;
  }

  @override
  Future<void> load(String sectionId) async {}
}
