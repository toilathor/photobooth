import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/models/qr_corner.dart';
import 'package:th_photobooth/services/frame_service.dart';

void main() {
  test('blocked_qr_corners hides those corners and moves the QR', () {
    final frame = FrameService.frameFromJson({
      'filename': 'group/group_5.png',
      'layout_type': 'group',
      'blocked_qr_corners': ['bottomRight', 'nope'],
    })!;

    expect(frame.qrCorners, [
      QrCorner.topLeft,
      QrCorner.topRight,
      QrCorner.bottomLeft,
    ]);
    expect(frame.fitQrCorner(QrCorner.bottomRight), QrCorner.bottomLeft);
    expect(frame.fitQrCorner(QrCorner.topRight), QrCorner.topRight);
  });

  test('default_qr_corner wins over the last choice', () {
    final frame = FrameService.frameFromJson({
      'layout_type': 'group',
      'default_qr_corner': 'topRight',
    })!;
    expect(frame.fitQrCorner(QrCorner.bottomLeft), QrCorner.topRight);
  });

  test('frames without blocked_qr_corners allow all corners', () {
    final frame = FrameService.frameFromJson({'layout_type': 'group'})!;
    expect(frame.qrCorners, QrCorner.values);
    expect(frame.fitQrCorner(QrCorner.bottomLeft), QrCorner.bottomLeft);
  });
}
