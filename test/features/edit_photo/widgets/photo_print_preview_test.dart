import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/edit_photo/widgets/preview_panel.dart';
import 'package:th_photobooth/features/edit_photo/widgets/photo_strip.dart';
import 'package:th_photobooth/models/frame_data.dart';
import 'package:th_photobooth/models/qr_corner.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('shows only the central cut guide', (tester) async {
    final frame = FrameData.standard();
    await tester.pumpWidget(
      testApp(
        child: SizedBox(
          width: 400,
          height: 600,
          child: PhotoPrintPreview(
            photos: const [],
            selectedFrame: frame,
            selectedFilter: 'normal',
            filterIntensity: 0.5,
            photoIsMirrored: false,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('print-cut-guide-vertical')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.content_cut_rounded), findsNothing);

    final groupFrame = FrameData.group();
    await tester.pumpWidget(
      testApp(
        child: SizedBox(
          width: 400,
          height: 600,
          child: PhotoPrintPreview(
            photos: const [],
            selectedFrame: groupFrame,
            selectedFilter: 'normal',
            filterIntensity: 0.5,
            photoIsMirrored: false,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('print-cut-guide-horizontal')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.content_cut_rounded), findsNothing);
  });

  testWidgets('draws the QR placeholder in the chosen corner', (tester) async {
    final frame = FrameData.standard();
    Future<Rect> qrRect(QrCorner corner) async {
      await tester.pumpWidget(
        testApp(
          child: Center(
            child: SizedBox(
              width: 176,
              height: 530,
              child: PhotoStrip(
                photos: const [],
                frame: frame,
                selectedFilter: 'normal',
                filterIntensity: 0.5,
                isMirrored: false,
                showQrPlaceholder: true,
                qrCorner: corner,
              ),
            ),
          ),
        ),
      );
      return tester.getRect(
        find.ancestor(
          of: find.byIcon(Icons.qr_code_2_rounded),
          matching: find.byType(Positioned),
        ),
      );
    }

    final topLeft = await qrRect(QrCorner.topLeft);
    final strip = tester.getRect(find.byType(PhotoStrip));
    final bottomRight = await qrRect(QrCorner.bottomRight);

    expect(topLeft.top - strip.top, lessThan(20));
    expect(topLeft.left - strip.left, lessThan(20));
    expect(strip.bottom - bottomRight.bottom, lessThan(20));
    expect(strip.right - bottomRight.right, lessThan(20));
  });
}
