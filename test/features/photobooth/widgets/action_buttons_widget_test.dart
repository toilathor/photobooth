import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/photobooth/widgets/action_buttons_widget.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import '../../../test_app.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('ActionButtonsWidget renders all buttons and recap switch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(child: const Scaffold(body: ActionButtonsWidget())),
    );

    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.touch_app_rounded), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });
}
