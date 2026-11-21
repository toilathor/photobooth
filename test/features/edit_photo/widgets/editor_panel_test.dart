import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/edit_photo/widgets/editor_panel.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/frame_data.dart';
import 'package:th_photobooth/models/qr_corner.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('shows only the complete action when completing also saves', (
    tester,
  ) async {
    var completeRequests = 0;
    final frame = FrameData.standard();

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: SizedBox(
            width: 800,
            height: 700,
            child: EditorPanel(
              availableFrames: [frame],
              selectedFrame: frame.path,
              onFrameSelected: (_) {},
              photos: const [],
              isProcessing: false,
              filters: const ['normal'],
              selectedFilter: 'normal',
              filterIntensity: 0.5,
              onFilterSelected: (_) {},
              onFilterIntensityChanged: (_) {},
              onCompleteRequested: () => completeRequests++,
              completeLabel: t.editor.completeEditing,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.qr_code_2_rounded), findsNothing);
    expect(find.byIcon(Icons.local_printshop_rounded), findsNothing);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.text(t.editor.completeEditing), findsOneWidget);
    expect(find.byTooltip(t.editor.saveToDevice), findsNothing);

    await tester.tap(find.text(t.editor.completeEditing));

    expect(completeRequests, 1);
  });

  testWidgets('lets the guest move the QR to another corner', (tester) async {
    final frame = FrameData.standard();
    QrCorner? picked;

    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: SizedBox(
            width: 800,
            height: 700,
            child: EditorPanel(
              availableFrames: [frame],
              selectedFrame: frame.path,
              onFrameSelected: (_) {},
              photos: const [],
              isProcessing: false,
              filters: const ['normal'],
              selectedFilter: 'normal',
              filterIntensity: 0.5,
              onFilterSelected: (_) {},
              onFilterIntensityChanged: (_) {},
              onCompleteRequested: () {},
              completeLabel: t.editor.completeEditing,
              onQrCornerChanged: (corner) => picked = corner,
            ),
          ),
        ),
      ),
    );

    expect(find.text(t.editor.qrPosition), findsOneWidget);
    for (final corner in QrCorner.values) {
      expect(find.byKey(ValueKey('qr-corner-${corner.name}')), findsOneWidget);
    }

    await tester.tap(find.byKey(const ValueKey('qr-corner-topLeft')));
    expect(picked, QrCorner.topLeft);
  });
}
