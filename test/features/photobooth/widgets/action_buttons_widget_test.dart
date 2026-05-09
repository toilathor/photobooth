import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/features/photobooth/widgets/action_buttons_widget.dart';
import 'package:my_photobooth/core/configs/app_config.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('ActionButtonsWidget renders all buttons and recap switch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider(
            create: (_) => PhotoboothProvider(),
            child: const ActionButtonsWidget(),
          ),
        ),
      ),
    );

    expect(find.text('Chụp tay'), findsOneWidget);
    expect(find.text('AUTO'), findsOneWidget);
    expect(find.text('Chụp Lại'), findsOneWidget);
    expect(find.text('Video Recap'), findsOneWidget);
    expect(find.text('Tải ảnh lên'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}
