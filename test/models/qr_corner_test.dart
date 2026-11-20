import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/models/qr_corner.dart';

void main() {
  test(
    'places the QR in the chosen corner, dx from the sides, dy from top/bottom',
    () {
      const canvas = Size(880, 2650);
      expect(
        QrCorner.topLeft.origin(canvas, 100, const Offset(10, 20)),
        const Offset(10, 20),
      );
      expect(
        QrCorner.topRight.origin(canvas, 100, const Offset(10, 20)),
        const Offset(770, 20),
      );
      expect(
        QrCorner.bottomLeft.origin(canvas, 100, const Offset(10, 20)),
        const Offset(10, 2530),
      );
      expect(
        QrCorner.bottomRight.origin(canvas, 100, const Offset(10, 20)),
        const Offset(770, 2530),
      );
    },
  );

  test('defaults to bottom right, where the QR used to be fixed', () {
    expect(QrCorner.fallback, QrCorner.bottomRight);
  });
}
