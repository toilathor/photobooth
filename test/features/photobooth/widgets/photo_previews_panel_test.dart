import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/photobooth/widgets/photo_previews_panel.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import '../../../test_app.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('PhotoPreviewsPanel renders 4 placeholders and status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(child: const Scaffold(body: PhotoPreviewsPanel())),
    );

    expect(find.byIcon(Icons.image_outlined), findsNWidgets(4));
    expect(find.byType(PhotoPreviewsPanel), findsOneWidget);
  });
}
