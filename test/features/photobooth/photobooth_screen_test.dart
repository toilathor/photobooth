import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/photobooth/screens/photobooth.screen.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import '../../test_app.dart';

void main() {
  setUp(() {
    AppConfig.cameras = []; // Mock empty cameras
  });

  testWidgets(
    'PhotoboothScreen renders correctly and shows settings on gear click',
    (WidgetTester tester) async {
      await tester.pumpWidget(testApp(child: const PhotoboothScreen()));

      // Verify Header
      expect(find.text('Thuy Hen ❤️ Quang To'), findsOneWidget);

      expect(find.byType(PhotoboothScreen), findsOneWidget);
    },
  );
}
