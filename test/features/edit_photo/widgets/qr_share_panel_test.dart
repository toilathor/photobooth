import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:th_photobooth/components/branded_qr_code.dart';
import 'package:th_photobooth/features/edit_photo/widgets/qr_share_panel.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('keeps the uploaded QR panel branded', (tester) async {
    const url =
        'https://toilathor.github.io/photobooth/#/gallery/section_123456';
    var downloads = 0;
    String? copiedText;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copiedText =
            (call.arguments as Map<Object?, Object?>)['text'] as String?;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: SizedBox(
            width: 600,
            height: 600,
            child: QrSharePanel(url: url, onDownload: () => downloads++),
          ),
        ),
      ),
    );

    final qr = tester.widget<BrandedQrCode>(find.byType(BrandedQrCode));
    expect(qr.showLogo, isTrue);
    expect(qr.size, greaterThan(300));
    expect(
      tester.widget<QrImageView>(find.byType(QrImageView)).errorCorrectionLevel,
      QrErrorCorrectLevel.H,
    );
    expect(
      find.descendant(
        of: find.byType(BrandedQrCode),
        matching: find.byType(ClipRRect),
      ),
      findsOneWidget,
    );
    expect(find.text(t.editor.saveToDevice), findsOneWidget);
    expect(find.text(url), findsOneWidget);
    expect(find.byTooltip(t.editor.copyLink), findsOneWidget);

    await tester.tap(find.text(t.editor.saveToDevice));
    expect(downloads, 1);

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();
    expect(copiedText, url);
  });
}
