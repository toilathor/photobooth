import 'dart:async';
import 'package:th_photobooth/models/frame_data.dart';
import 'video_recap_service.dart';

class VideoRecapService {
  /// Xuất video recap đã được gắn vào khung (frame).
  /// Trả về null trên nền tảng di động để kích hoạt fallback sử dụng video gốc.
  static Future<FramedVideoResult?> exportFramedVideo({
    required String videoUrl,
    required FrameData frame,
    required List<Duration> timestamps,
    required double recapDurationSeconds,
    String? preferredMimeType,
    bool isMirrored = false,
  }) async {
    return null;
  }

  /// Lật video (flip) theo chiều ngang.
  /// Trả về null trên nền tảng di động để kích hoạt fallback sử dụng video gốc.
  static Future<FramedVideoResult?> flipVideo({
    required String videoUrl,
    required bool isMirrored,
    String? preferredMimeType,
  }) async {
    return null;
  }
}
