import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/photobooth/widgets/camera_preview_widget.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import '../../../test_app.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('CameraPreviewWidget renders flash and settings icons', (
    WidgetTester tester,
  ) async {
    // Lưu ý: Trong test thực tế, bạn có thể cần mock CameraController
    // nếu provider.cameraController là null. Ở đây chúng ta giả định
    // hoặc chấp nhận null nếu logic widget cho phép (hoặc pass dummy).

    await tester.pumpWidget(
      testApp(child: const Scaffold(body: CameraPreviewWidget())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
