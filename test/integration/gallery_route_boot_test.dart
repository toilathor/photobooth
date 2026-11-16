import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/gallery/screens/gallery.screen.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/main.dart';

void main() {
  testWidgets('boots a Gallery route without mounting the photobooth home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TranslationProvider(
        child: const PhotoboothApp(
          gallerySectionId: 'section_123456',
          galleryLocation: '/gallery/section_123456',
        ),
      ),
    );

    expect(find.byType(GalleryScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
