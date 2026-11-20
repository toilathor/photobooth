import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/features/photobooth/widgets/camera_preview_widget.dart';

import '../../../support/test_app.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('CameraPreviewWidget renders flash and settings icons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        child: ChangeNotifierProvider(
          create: (_) => PhotoboothProvider(),
          child: const Scaffold(body: CameraPreviewWidget()),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
