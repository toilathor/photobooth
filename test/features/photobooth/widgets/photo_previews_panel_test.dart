import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/features/photobooth/widgets/photo_item_card.dart';
import 'package:th_photobooth/features/photobooth/widgets/photo_previews_panel.dart';

import '../../../support/test_app.dart';

void main() {
  setUp(() {
    AppConfig.cameras = [];
  });

  testWidgets('PhotoPreviewsPanel renders a placeholder per standard photo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        child: ChangeNotifierProvider(
          create: (_) => PhotoboothProvider(),
          child: const Scaffold(body: PhotoPreviewsPanel()),
        ),
      ),
    );

    expect(
      find.byIcon(Icons.image_outlined),
      findsNWidgets(AppConfig.defaultPhotoCount),
    );
    expect(find.byType(PhotoPreviewsPanel), findsOneWidget);
  });

  for (final size in const [Size(280, 700), Size(300, 480), Size(220, 900)]) {
    testWidgets(
      'keeps 2 cards grouped and 4:3 in a ${size.width}x${size.height} '
      'column',
      (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final provider = PhotoboothProvider()..setPhotoCount(2);
        await tester.pumpWidget(
          testApp(
            child: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: PhotoPreviewsPanel()),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        final cards = find.byType(PhotoItemCard);
        expect(cards, findsNWidgets(2));

        final first = tester.getRect(cards.at(0));
        final second = tester.getRect(cards.at(1));
        expect(first.width / first.height, closeTo(4 / 3, 0.05));
        // Cards sit next to each other (the 12px gap is the card margin) instead
        // of at opposite ends of the column.
        expect(second.top - first.bottom, lessThanOrEqualTo(1));
      },
    );
  }
}
