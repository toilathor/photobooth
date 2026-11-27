import 'package:material_ui/material_ui.dart';
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
    var nextGuest = 0;
    var printed = 0;

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: SizedBox(
            width: 600,
            height: 600,
            child: QrSharePanel(
              url: url,
              onNextGuest: () => nextGuest++,
              onPrint: () => printed++,
            ),
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
    expect(find.text(t.editor.saveToDevice), findsNothing);

    await tester.tap(find.text(t.editor.nextGuest));
    expect(nextGuest, 1);
    // The link field is hidden for now.
    expect(find.text(url), findsNothing);
    expect(find.byTooltip(t.editor.copyLink), findsNothing);

    await tester.tap(find.text(t.editor.printNow));
    expect(printed, 1);
  });

  testWidgets('says how the background upload is going', (tester) async {
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: SizedBox(
            width: 600,
            height: 600,
            child: QrSharePanel(
              url: 'https://toilathor.github.io/photobooth/#/gallery/section_123456',
              uploadStatus: t.google_drive.upload_retrying,
              onNextGuest: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text(t.google_drive.upload_retrying), findsOneWidget);
  });
}
