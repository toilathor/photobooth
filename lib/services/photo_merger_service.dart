import 'dart:async';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:th_photobooth/models/frame_data.dart';

class PhotoMergerService {
  /// Merges captured photos and a frame into a single high-quality image.
  ///
  /// The algorithm uses dart:ui Canvas to ensure the highest possible output quality:
  /// 1. Creates a canvas of [frameData.size].
  /// 2. For each photo, perfectly center-crops it to fit the corresponding [frameData.slots] Rect,
  ///    applying any requested [colorFilterMatrix] or [isMirrored] transforms.
  /// 3. Draws the transparent frame PNG on top of the photos.
  /// 4. Exports the final picture as a PNG Uint8List.
  static Future<Uint8List> mergePhotos({
    required List<XFile> photos,
    required FrameData frameData,
    List<double>? colorFilterMatrix,
    bool isMirrored = false,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    final double canvasWidth = frameData.size.width;
    final double canvasHeight = frameData.size.height;
    final ui.Rect canvasRect = ui.Rect.fromLTWH(
      0,
      0,
      canvasWidth,
      canvasHeight,
    );

    // Draw background (optional, but good for safety, we draw white)
    final ui.Paint bgPaint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
    canvas.drawRect(canvasRect, bgPaint);

    // Prepare paint for photos
    final ui.Paint photoPaint = ui.Paint()..isAntiAlias = true;
    if (colorFilterMatrix != null) {
      photoPaint.colorFilter = ui.ColorFilter.matrix(colorFilterMatrix);
    }

    // 1. Draw each photo into its corresponding slot with Center Crop
    for (int i = 0; i < frameData.slots.length && i < photos.length; i++) {
      final ui.Rect slotRect = frameData.slots[i];
      final XFile photo = photos[i];

      final Uint8List photoBytes = await photo.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(photoBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Calculate Center Crop rect (source)
      final double slotAspect = slotRect.width / slotRect.height;
      final double imageAspect = image.width / image.height;

      double srcX = 0,
          srcY = 0,
          srcW = image.width.toDouble(),
          srcH = image.height.toDouble();

      if (imageAspect > slotAspect) {
        // Image is wider than slot: Crop horizontally
        srcW = image.height * slotAspect;
        srcX = (image.width - srcW) / 2.0;
      } else {
        // Image is taller than slot: Crop vertically
        srcH = image.width / slotAspect;
        srcY = (image.height - srcH) / 2.0;
      }

      final ui.Rect srcRect = ui.Rect.fromLTWH(srcX, srcY, srcW, srcH);

      canvas.save();

      // Apply mirroring if needed
      if (isMirrored) {
        // Translate to the center of the slot, flip X, then translate back
        canvas.translate(
          slotRect.left + slotRect.width / 2,
          slotRect.top + slotRect.height / 2,
        );
        canvas.scale(-1.0, 1.0);
        canvas.translate(
          -(slotRect.left + slotRect.width / 2),
          -(slotRect.top + slotRect.height / 2),
        );
      }

      // Draw the center-cropped photo into the target slot rectangle
      canvas.drawImageRect(image, srcRect, slotRect, photoPaint);

      canvas.restore();
      image.dispose();
    }

    // 2. Draw the transparent Frame PNG on top
    late final Uint8List frameBytes;
    if (frameData.path.startsWith('http')) {
      // If frame is from network
      final ByteData data = await NetworkAssetBundle(
        Uri.parse(frameData.path),
      ).load('');
      frameBytes = data.buffer.asUint8List();
    } else {
      // If frame is a local asset
      final ByteData data = await rootBundle.load(frameData.path);
      frameBytes = data.buffer.asUint8List();
    }

    final ui.Codec frameCodec = await ui.instantiateImageCodec(frameBytes);
    final ui.FrameInfo frameFrameInfo = await frameCodec.getNextFrame();
    final ui.Image frameImage = frameFrameInfo.image;

    final ui.Paint framePaint = ui.Paint()..isAntiAlias = true;
    final ui.Rect frameSrcRect = ui.Rect.fromLTWH(
      0,
      0,
      frameImage.width.toDouble(),
      frameImage.height.toDouble(),
    );

    // Draw the frame covering the entire canvas
    canvas.drawImageRect(frameImage, frameSrcRect, canvasRect, framePaint);
    frameImage.dispose();

    // 3. Export to PNG
    final ui.Picture picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );

    final ByteData? byteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    finalImage.dispose();

    if (byteData == null) {
      throw Exception('Failed to encode merged image');
    }

    return byteData.buffer.asUint8List();
  }
}
