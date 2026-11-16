import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/edit_photo/widgets/preview_panel.dart';
import 'package:th_photobooth/models/frame_data.dart';

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
}
