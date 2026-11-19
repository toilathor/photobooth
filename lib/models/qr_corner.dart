import 'package:material_ui/material_ui.dart';

/// The corner of the printed photo where the gallery QR code sits.
///
/// Shared by the on-screen preview ([PhotoStrip]) and the merged file
/// ([PhotoMergerService]) so both place the QR in the same spot.
enum QrCorner {
  topLeft(Icons.north_west_rounded),
  topRight(Icons.north_east_rounded),
  bottomLeft(Icons.south_west_rounded),
  bottomRight(Icons.south_east_rounded);

  const QrCorner(this.icon);

  final IconData icon;

  static const QrCorner fallback = QrCorner.bottomRight;

  bool get isLeft => this == topLeft || this == bottomLeft;
  bool get isTop => this == topLeft || this == topRight;

  /// Top-left point of a [qrSize] square placed in this corner of [canvas],
  /// [inset] away from both edges.
  Offset origin(Size canvas, double qrSize, double inset) => Offset(
    isLeft ? inset : canvas.width - qrSize - inset,
    isTop ? inset : canvas.height - qrSize - inset,
  );
}
