import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/features/photobooth/screens/photobooth.screen.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('Photobooth screen renders without a camera', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ChangeNotifierProvider(
          create: (_) => PhotoboothProvider(),
          child: MaterialApp(
            home: ResponsiveBreakpoints.builder(
              child: const PhotoboothScreen(),
              breakpoints: const [
                Breakpoint(start: 0, end: 450, name: MOBILE),
                Breakpoint(start: 451, end: 850, name: TABLET),
                Breakpoint(start: 851, end: 1920, name: DESKTOP),
                Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(PhotoboothScreen), findsOneWidget);
  });
}
