import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:my_photobooth/models/frame_data.dart';

class ImageMergerService {
  /// Merges a list of photos into the specified frame.
  /// Returns the merged image as a Uint8List (PNG format).
  static Future<Uint8List?> mergePhotosWithFrame({
    required List<XFile> photos,
    required FrameData frame,
  }) async {
    try {
      // 1. Load the frame image from assets
      final ByteData frameData = await rootBundle.load(frame.path);
      final Uint8List frameBytes = frameData.buffer.asUint8List();
      final img.Image? frameImage = img.decodePng(frameBytes);

      if (frameImage == null) return null;

      // 2. Create a base image
      final img.Image resultImage = img.Image(
        width: frameImage.width,
        height: frameImage.height,
        numChannels: 4,
      );
      img.fill(resultImage, color: img.ColorRgba8(255, 255, 255, 255));

      // 3. Process each photo slot
      for (int i = 0; i < frame.slots.length; i++) {
        if (i >= photos.length) break;

        final slot = frame.slots[i];
        final photoBytes = await photos[i].readAsBytes();
        img.Image? photoImage = img.decodeImage(photoBytes);

        if (photoImage == null) continue;

        // Fix orientation from EXIF
        photoImage = img.bakeOrientation(photoImage);

        // Add a small "bleed" (overdraw) to ensure no white gaps
        const int bleed = 10;
        final int targetW = slot.width.toInt() + (bleed * 2);
        final int targetH = slot.height.toInt() + (bleed * 2);

        final img.Image fittedPhoto = _resizeAndCropToFit(
          photoImage,
          targetW,
          targetH,
        );

        // Draw the fitted photo centered on the slot
        img.compositeImage(
          resultImage,
          fittedPhoto,
          dstX: slot.left.toInt() - bleed,
          dstY: slot.top.toInt() - bleed,
        );
      }

      // 4. Draw the frame overlay on top
      img.compositeImage(resultImage, frameImage);

      // 5. Encode result to PNG
      return Uint8List.fromList(img.encodePng(resultImage));
    } catch (e) {
      debugPrint('Error merging photos: $e');
      return null;
    }
  }

  /// Helper to resize and crop an image to fit target dimensions (BoxFit.cover equivalent)
  static img.Image _resizeAndCropToFit(img.Image src, int targetWidth, int targetHeight) {
    final double srcAspect = src.width / src.height;
    final double targetAspect = targetWidth / targetHeight;

    int resizeWidth, resizeHeight;
    if (srcAspect > targetAspect) {
      // Source is wider than target: fit to height
      resizeHeight = targetHeight;
      resizeWidth = (targetHeight * srcAspect).toInt();
    } else {
      // Source is taller than target: fit to width
      resizeWidth = targetWidth;
      resizeHeight = (targetWidth / srcAspect).toInt();
    }

    final img.Image resized = img.copyResize(
      src,
      width: resizeWidth,
      height: resizeHeight,
      interpolation: img.Interpolation.average, // Higher quality for downscaling
    );

    // Crop center
    final int xOffset = (resized.width - targetWidth) ~/ 2;
    final int yOffset = (resized.height - targetHeight) ~/ 2;

    return img.copyCrop(
      resized,
      x: xOffset,
      y: yOffset,
      width: targetWidth,
      height: targetHeight,
    );
  }

  /// Merges two images side-by-side.
  static Uint8List mergeSideBySide(Uint8List image1, Uint8List image2) {
    final img.Image? img1 = img.decodeImage(image1);
    final img.Image? img2 = img.decodeImage(image2);

    if (img1 == null || img2 == null) return image1;

    // Create a new image with combined width
    final result = img.Image(
      width: img1.width + img2.width + 20, // Add a small gap
      height: img1.height,
      numChannels: 4,
    );
    img.fill(result, color: img.ColorRgba8(255, 255, 255, 255));

    img.compositeImage(result, img1, dstX: 0, dstY: 0);
    img.compositeImage(result, img2, dstX: img1.width + 20, dstY: 0);

    return Uint8List.fromList(img.encodePng(result));
  }
}
