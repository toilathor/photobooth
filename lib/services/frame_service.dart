import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:th_photobooth/models/frame_data.dart';

class FrameService {
  static Future<List<FrameData>> loadFrames() async {
    final List<FrameData> frames = [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://raw.githubusercontent.com/toilathor/photobooth/master/assets/frames/data.json',
        ),
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP status: ${response.statusCode}');
      }
      final String jsonString = utf8.decode(response.bodyBytes);

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

  /// Loads the byte data of a frame from a network URL.
  static Future<ByteData> loadFrameBytes(String path) async {
    final response = await http.get(Uri.parse(path));
    if (response.statusCode == 200) {
      return ByteData.sublistView(response.bodyBytes);
    } else {
      throw Exception(
        'Failed to load frame from network: $path (Status: ${response.statusCode})',
      );
    }
  }
}
