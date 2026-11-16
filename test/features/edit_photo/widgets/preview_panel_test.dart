import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:th_photobooth/components/branded_qr_code.dart';
import 'package:th_photobooth/features/edit_photo/widgets/photo_strip.dart';
import 'package:th_photobooth/features/edit_photo/widgets/preview_panel.dart';
import 'package:th_photobooth/models/frame_data.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('renders two compact QR codes in the single print preview', (
    tester,
  ) async {
    final frame = FrameData.standard();
    await tester.pumpWidget(
      testApp(
        child: SizedBox(
          width: 600,
          height: 800,
          child: PreviewPanel(
            photos: const [],
            selectedFrame: frame,
            availableFrames: [frame],
            selectedFilter: 'normal',
            filterIntensity: 0.5,
            photoIsMirrored: false,
            videoIsMirrored: false,
            galleryUrl:
                'https://toilathor.github.io/photobooth/#/gallery/section_123456',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(BrandedQrCode), findsNWidgets(2));
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.local_printshop_outlined), findsNothing);
    expect(
      tester
          .widgetList<BrandedQrCode>(find.byType(BrandedQrCode))
          .every((qr) => !qr.showLogo),
      isTrue,
    );
    expect(
      tester
          .widgetList<QrImageView>(find.byType(QrImageView))
          .every(
            (qr) =>
                qr.errorCorrectionLevel == QrErrorCorrectLevel.M &&
                qr.eyeStyle.eyeShape == QrEyeShape.circle &&
                qr.dataModuleStyle.dataModuleShape == QrDataModuleShape.circle,
          ),
      isTrue,
    );
  });

  testWidgets('reserves two QR slots before the gallery is ready', (
    tester,
  ) async {
    final frame = FrameData.standard();
    await tester.pumpWidget(
      testApp(
        child: SizedBox(
          width: 600,
          height: 800,
          child: PreviewPanel(
            photos: const [],
            selectedFrame: frame,
            availableFrames: [frame],
            selectedFilter: 'normal',
            filterIntensity: 0.5,
            photoIsMirrored: false,
            videoIsMirrored: false,
            showQrPlaceholder: true,
          ),
        ),
      ),
    );

    expect(find.byType(BrandedQrCode), findsNothing);
    expect(find.byIcon(Icons.qr_code_2_rounded), findsNWidgets(2));

    await tester.pumpWidget(
      testApp(
        child: SizedBox(
          width: frame.size.width,
          height: frame.size.height,
          child: PhotoStrip(
            photos: const [],
            frame: frame,
            selectedFilter: 'normal',
            filterIntensity: 0.5,
            isMirrored: false,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.qr_code_2_rounded), findsNothing);
  });

  testWidgets('mobile preview has no edit or print mode control', (
    tester,
  ) async {
    final frame = FrameData.standard();
    await tester.pumpWidget(
      testApp(
        child: PreviewPanel(
          photos: const [],
          selectedFrame: frame,
          availableFrames: [frame],
          selectedFilter: 'normal',
          filterIntensity: 0.5,
          photoIsMirrored: false,
          videoIsMirrored: false,
          isMobile: true,
        ),
      ),
    );

    expect(find.byIcon(Icons.edit_rounded), findsNothing);
    expect(find.byIcon(Icons.local_printshop_rounded), findsNothing);
  });
}
