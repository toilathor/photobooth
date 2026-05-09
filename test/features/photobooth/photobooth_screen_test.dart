import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_photobooth/features/photobooth/photobooth.screen.dart';
import 'package:my_photobooth/core/configs/app_config.dart';

void main() {
  setUp(() {
    AppConfig.cameras = []; // Mock empty cameras
  });

  testWidgets(
    'PhotoboothScreen renders correctly and shows settings on gear click',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PhotoboothScreen()));

      // Verify Header
      expect(find.text('PhotoXinhh'), findsOneWidget);
      expect(find.text('Capture Memories'), findsOneWidget);

      // Verify Fullscreen button
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);

      // Settings elements should NOT be visible initially
      expect(find.text('Layout Ảnh'), findsNothing);
      expect(find.text('Đếm Ngược'), findsNothing);

      // Verify Action Buttons are visible
      expect(find.text('Chụp tay'), findsOneWidget);
      expect(find.text('AUTO'), findsOneWidget);
      expect(find.text('Chụp Lại'), findsOneWidget);

      // Find and click the gear icon (settings)
      final gearIcon = find.byIcon(Icons.settings);
      expect(gearIcon, findsOneWidget);
      await tester.tap(gearIcon);
      await tester.pumpAndSettle(); // Wait for bottom sheet animation

      // Now settings elements should be visible in the bottom sheet
      expect(find.text('Layout Ảnh'), findsOneWidget);
      expect(find.text('Đếm Ngược'), findsOneWidget);
      expect(find.text('Bộ lọc màu'), findsOneWidget);
    },
  );
}
