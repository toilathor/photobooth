import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/models/frame_data.dart';

class FrameService {
  static Future<List<FrameData>> loadFrames() async {
    final List<FrameData> frames = [];

    try {
      final String jsonString = await rootBundle.loadString(
        '${AppConfig.framesAssetRoot}data.json',
      );

      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final List<dynamic> images = data['images'] as List<dynamic>? ?? [];

      for (var img in images) {
        final frame = frameFromJson(img as Map<String, dynamic>);
        if (frame != null) frames.add(frame);
      }
    } catch (e) {
      debugPrint('Error loading frames from data.json: $e');
    }

    return frames;
  }

  /// Builds the frame described by one `images` entry of data.json, or null
  /// when its layout is unknown.
  @visibleForTesting
  static FrameData? frameFromJson(Map<String, dynamic> imgData) {
    final String filename = imgData['filename']?.toString() ?? '';
    final String frameType = imgData['frame']?.toString() ?? '';
    final String layoutType = imgData['layout_type']?.toString() ?? '';
    final String categoryId = imgData['category_id']?.toString() ?? '';
    final categoryMap = imgData['category'] as Map<String, dynamic>?;
    final String categoryName = categoryMap?['name']?.toString() ?? '';

    if (layoutType == 'standard' || frameType == 'square') {
      // Optional [[x, y, width, height], ...], one per photo, for standard
      // frames whose photo areas differ from the default.
      final List<dynamic>? slotsData = imgData['slots'] as List<dynamic>?;
      return FrameData.standard(
        filename: filename,
        categoryId: categoryId,
        categoryName: categoryName,
        slots: slotsData?.map(_rectFromJson).whereType<Rect>().toList(),
      );
    }
    if (layoutType == 'group' || frameType == 'group') {
      // Optional [x, y, width, height] photo area, for group frames whose
      // layout differs from the default.
      return FrameData.group(
        filename: filename,
        categoryId: categoryId,
        categoryName: categoryName,
        slot: _rectFromJson(imgData['slot']),
      );
    }
    return null;
  }

  /// `[x, y, width, height]` from data.json, or null when absent or malformed.
  static Rect? _rectFromJson(Object? value) {
    if (value is! List || value.length != 4) return null;
    final v = value.map((e) => (e as num).toDouble()).toList();
    return Rect.fromLTWH(v[0], v[1], v[2], v[3]);
  }

  /// Loads the byte data of a bundled frame image from its asset [path].
  static Future<ByteData> loadFrameBytes(String path) => rootBundle.load(path);
}
