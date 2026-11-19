import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:th_photobooth/components/branded_qr_code.dart';
import 'package:th_photobooth/models/frame_data.dart';

void main() {
  test('keeps a 7 mm QR size for standard and group prints', () {
    expect(BrandedQrCode.printSize(FrameData.standard()), closeTo(121.26, 0.1));
    expect(BrandedQrCode.printSize(FrameData.group()), closeTo(192.91, 0.1));
  });

  testWidgets('renders the compact QR as print-ready PNG bytes', (
    tester,
  ) async {
    final bytes = await tester.runAsync(
      () => BrandedQrCode.renderPng(
        data: 'https://toilathor.github.io/photobooth/#/gallery/section_123456',
        size: BrandedQrCode.printSize(FrameData.standard()),
      ),
    );
    final qr = img.decodePng(bytes!);

    expect(qr, isNotNull);
    expect(qr!.width, 121);
    expect(qr.height, 121);
  });
}
