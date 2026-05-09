import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/features/photobooth/widgets/photo_previews_panel.dart';
import 'package:my_photobooth/core/configs/app_config.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('PhotoPreviewsPanel renders 4 placeholders and status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider(
            create: (_) => PhotoboothProvider(),
            child: const SingleChildScrollView(child: PhotoPreviewsPanel()),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.image_outlined), findsNWidgets(4));
    expect(find.text('0/4'), findsOneWidget);
  });
}
