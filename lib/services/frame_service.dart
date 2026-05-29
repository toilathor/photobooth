import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:th_photobooth/core/configs/frame_config.dart';
import 'package:th_photobooth/models/frame_data.dart';

class FrameService {
  static Future<List<FrameData>> loadFrames() async {
    final List<FrameData> frames = [];

    // Keep only Frame 1 from static configs
    for (var frame in FrameConfig.allFrames) {
      if (frame.path.contains('frame1')) {
        frames.add(frame);
      }
    }

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

        // Map "square" and "standard" to the old Frame 4 layout
        if (frameType == 'square' && layoutType == 'standard') {
          frames.add(
            FrameData(
              path: 'assets/frames/collected/$filename',
              photoSlots: 4,
              size: const Size(880, 2650),
              slots: const [
                Rect.fromLTWH(40, 40, 800, 600),
                Rect.fromLTWH(40, 660, 800, 600),
                Rect.fromLTWH(40, 1280, 800, 600),
                Rect.fromLTWH(40, 1900, 800, 600),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading frames from data.json: $e');
    }

    return frames;
  }
}
