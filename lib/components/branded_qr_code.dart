import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:th_photobooth/gen/assets.gen.dart';
import 'package:th_photobooth/models/frame_data.dart';

class BrandedQrCode extends StatelessWidget {
  static const _color = Color(0xFF121212);
  static const _eyeStyle = QrEyeStyle(
    eyeShape: QrEyeShape.circle,
    color: _color,
  );
  static const _dataModuleStyle = QrDataModuleStyle(
    dataModuleShape: QrDataModuleShape.circle,
    color: _color,
  );
  static const _errorCorrectionLevel = QrErrorCorrectLevel.M;
  static const double _physicalSizeMm = 7;
  static const double _physicalInsetMm = 2;

  final String data;
  final double size;
  final bool showLogo;
  final int errorCorrectionLevel;

  const BrandedQrCode({
    super.key,
    required this.data,
    required this.size,
    this.showLogo = true,
    this.errorCorrectionLevel = _errorCorrectionLevel,
  });

  static double printSize(FrameData frame) =>
      frame.size.width * _physicalSizeMm / _printedFrameWidthMm(frame);

  static double printInset(FrameData frame) =>
      frame.size.width * _physicalInsetMm / _printedFrameWidthMm(frame);

  static double _printedFrameWidthMm(FrameData frame) =>
      frame.isGroup ? 101.6 : 50.8;

  @override
  Widget build(BuildContext context) {
    final padding = size * 0.08;
    final logoSize = size * 0.17;
    return Semantics(
      image: true,
      label: 'QR code mở thư viện ảnh',
      child: SizedBox.square(
        dimension: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.12),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              alignment: Alignment.center,
              children: [
                QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  errorCorrectionLevel: errorCorrectionLevel,
                  size: size,
                  padding: EdgeInsets.all(padding),
                  backgroundColor: Colors.white,
                  gapless: true,
                  eyeStyle: _eyeStyle,
                  dataModuleStyle: _dataModuleStyle,
                ),
                if (showLogo)
                  Container(
                    width: logoSize,
                    height: logoSize,
                    padding: EdgeInsets.all(size * 0.012),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(Assets.images.icLauncher.path),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<Uint8List> renderPng({
    required String data,
    required double size,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final bounds = Rect.fromLTWH(0, 0, size, size);
    final padding = size * 0.08;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, Radius.circular(size * 0.12)),
      Paint()..color = Colors.white,
    );

    canvas.save();
    canvas.translate(padding, padding);
    final qrSize = size - padding * 2;
    QrPainter(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: _errorCorrectionLevel,
      gapless: true,
      eyeStyle: _eyeStyle,
      dataModuleStyle: _dataModuleStyle,
    ).paint(canvas, Size.square(qrSize));
    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.round(), size.round());
    picture.dispose();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) throw StateError('Unable to render QR code');
    return bytes.buffer.asUint8List();
  }
}
