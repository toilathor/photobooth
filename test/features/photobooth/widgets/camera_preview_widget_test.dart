import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/features/photobooth/widgets/camera_preview_widget.dart';
import 'package:my_photobooth/core/configs/app_config.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('CameraPreviewWidget renders flash and settings icons', (
    WidgetTester tester,
  ) async {
    final provider = PhotoboothProvider();
    // Lưu ý: Trong test thực tế, bạn có thể cần mock CameraController
    // nếu provider.cameraController là null. Ở đây chúng ta giả định
    // hoặc chấp nhận null nếu logic widget cho phép (hoặc pass dummy).

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider.value(
            value: provider,
            child: CameraPreviewWidget(provider.cameraController!),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.flash_on), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.text('Đã Chụp 0/4'), findsOneWidget);
  });
}
