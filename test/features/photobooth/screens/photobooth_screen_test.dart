import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/features/photobooth/screens/photobooth.screen.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

import '../../../support/test_app.dart';

void main() {
  setUp(() {
    AppConfig.cameras = []; // Mock empty cameras
  });

  testWidgets('renders the localized header without a camera', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        child: ChangeNotifierProvider(
          create: (_) => PhotoboothProvider(),
          child: const PhotoboothScreen(),
        ),
      ),
    );

    expect(find.text(t.header.titlePersonal), findsOneWidget);

    expect(find.byType(PhotoboothScreen), findsOneWidget);
  });
}
