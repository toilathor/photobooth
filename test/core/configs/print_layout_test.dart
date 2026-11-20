import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/components/branded_qr_code.dart';
import 'package:th_photobooth/core/configs/print_layout.dart';
import 'package:th_photobooth/features/edit_photo/widgets/photo_strip.dart';
import 'package:th_photobooth/features/edit_photo/widgets/preview_panel.dart';
import 'package:th_photobooth/models/frame_data.dart';
import 'package:th_photobooth/models/qr_corner.dart';

final _layouts = {'standard': FrameData.standard(), 'group': FrameData.group()};

/// Rect of [frameRect] (frame px) of copy [copy] on the print page.
Rect _onPage(FrameData frame, int copy, Rect frameRect) {
  final s = PrintLayout.scale(frame);
  final content = PrintLayout.contentSize(frame) * s;
  final origin = Offset(
    (PrintLayout.page.width - content.width) / 2,
    (PrintLayout.page.height - content.height) / 2,
  );
  final step =
      (PrintLayout.stacksCopies(frame)
          ? Offset(0, frame.size.height + PrintLayout.copyGap)
          : Offset(frame.size.width + PrintLayout.copyGap, 0)) *
      copy.toDouble();
  final r = frameRect.shift(step);
  return Rect.fromLTRB(
    origin.dx + r.left * s,
    origin.dy + r.top * s,
    origin.dx + r.right * s,
    origin.dy + r.bottom * s,
  );
}

void main() {
  for (final MapEntry(key: name, value: frame) in _layouts.entries) {
    testWidgets('$name: page layout matches PhotoPrintPreview', (tester) async {
      tester.view.physicalSize = PrintLayout.page;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox.fromSize(
              size: PrintLayout.page,
              child: PhotoPrintPreview(
                photos: const [],
                selectedFrame: frame,
                selectedFilter: 'normal',
                filterIntensity: 0.5,
                photoIsMirrored: false,
              ),
            ),
          ),
        ),
      );
      final strips = find.byType(PhotoStrip).evaluate().toList();
      expect(strips, hasLength(2));
      for (var copy = 0; copy < 2; copy++) {
        final box = strips[copy].renderObject! as RenderBox;
        final actual = Rect.fromPoints(
          box.localToGlobal(Offset.zero),
          box.localToGlobal(box.size.bottomRight(Offset.zero)),
        );
        final expected = _onPage(frame, copy, Offset.zero & frame.size);
        expect(actual.left, closeTo(expected.left, 0.5));
        expect(actual.top, closeTo(expected.top, 0.5));
        expect(actual.right, closeTo(expected.right, 0.5));
        expect(actual.bottom, closeTo(expected.bottom, 0.5));
      }
    });

    test('$name: QR stays 1 mm inside the trimmed paper in every corner', () {
      final mm = PrintLayout.pxPerMm;
      final paper = Rect.fromLTRB(
        PrintLayout.printerTrimSidesMm * mm,
        PrintLayout.printerTrimTopBottomMm * mm,
        PrintLayout.page.width - PrintLayout.printerTrimSidesMm * mm,
        PrintLayout.page.height - PrintLayout.printerTrimTopBottomMm * mm,
      ).deflate(PrintLayout.safetyMarginMm * mm - 0.5);
      final size = BrandedQrCode.printSize(frame);
      for (final corner in QrCorner.values) {
        final qr =
            corner.origin(frame.size, size, BrandedQrCode.printInset(frame)) &
            Size.square(size);
        for (var copy = 0; copy < 2; copy++) {
          final onPage = _onPage(frame, copy, qr);
          expect(
            paper.contains(onPage.topLeft) &&
                paper.contains(onPage.bottomRight),
            isTrue,
            reason: '$corner on copy $copy: $onPage outside $paper',
          );
        }
      }
    });
  }

  test('group prints lose about 2.5 mm per side to the page crop', () {
    final group = FrameData.group();
    final inset = PrintLayout.safeInset(group);
    // Old fixed inset was 55 px; the crop + trim + margin needs ~124 px.
    expect(inset.dx, closeTo(123.8, 1));
    expect(inset.dy, closeTo(76, 2));
  });
}
