import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:th_photobooth/models/frame_data.dart';

class FrameService {
  static Future<List<FrameData>> loadFrames() async {
    final List<FrameData> frames = [];

    try {
      final jsonString = await rootBundle.loadString('assets/frames/data.json');
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final List<dynamic> images = data['images'] as List<dynamic>? ?? [];

      for (var img in images) {
        final Map<String, dynamic> imgData = img as Map<String, dynamic>;
        final String filename = imgData['filename']?.toString() ?? '';
        final String frameType = imgData['frame']?.toString() ?? '';
        final String layoutType = imgData['layout_type']?.toString() ?? '';

        if (layoutType == 'standard' || frameType == 'square') {
          frames.add(FrameData.standard(filename: filename));
        } else if (layoutType == 'group' || frameType == 'group') {
          frames.add(FrameData.group(filename: filename));
        }
      }
    } catch (e) {
      debugPrint('Error loading frames from data.json: $e');
    }

    return frames;
  }
}
