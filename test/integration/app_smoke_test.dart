import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/features/photobooth/screens/photobooth.screen.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/main.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('Photobooth screen renders without a camera', (
    WidgetTester tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.vi);
    await tester.pumpWidget(
      TranslationProvider(
        child: ChangeNotifierProvider(
          create: (_) => PhotoboothProvider(),
          child: const PhotoboothApp(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(PhotoboothScreen), findsOneWidget);
  });
}
