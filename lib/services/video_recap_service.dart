import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_photobooth/core/js/video_exporter_js.dart' as js_bridge;
import 'package:my_photobooth/models/frame_data.dart';
import 'package:web/web.dart' as web;

class FramedVideoResult {
  final Uint8List bytes;
  final String mimeType;

  FramedVideoResult({required this.bytes, required this.mimeType});
}

class VideoRecapService {
  /// Xuất video recap đã được gắn vào khung (frame).
  /// Trả về bytes của video kết quả hoặc null nếu có lỗi.
  static Future<FramedVideoResult?> exportFramedVideo({
    required String videoUrl,
    required FrameData frame,
    required List<Duration> timestamps,
    required double recapDurationSeconds,
    String? preferredMimeType,
    bool isMirrored = false,
  }) async {
    String? frameBlobUrl;
    try {
      // 1. Chuyển đổi Frame Asset thành Blob URL để JS có thể truy cập dễ dàng
      final ByteData frameByteData = await rootBundle.load(frame.path);
      final Uint8List frameBytes = frameByteData.buffer.asUint8List();
      final web.Blob frameBlob = web.Blob(
        [frameBytes.toJS].toJS,
        web.BlobPropertyBag(type: 'image/png'),
      );
      frameBlobUrl = web.URL.createObjectURL(frameBlob);

      // 2. Chuẩn bị dữ liệu layout
      final layoutData = {
        'canvasWidth': frame.size.width.toInt(),
        'canvasHeight': frame.size.height.toInt(),
        'timestamps': timestamps.map((d) => d.inMilliseconds / 1000.0).toList(),
        'recapDuration': recapDurationSeconds,
        'slots': frame.slots
            .map(
              (s) => {
                'x': s.left.toInt(),
                'y': s.top.toInt(),
                'w': s.width.toInt(),
                'h': s.height.toInt(),
              },
            )
            .toList(),
      };

      // 3. Gọi engine JS để xử lý việc render và record
      final JSPromise promise = js_bridge.exportRecapVideo(
        videoUrl.toJS,
        frameBlobUrl.toJS,
        jsonEncode(layoutData).toJS,
        preferredMimeType?.toJS,
        isMirrored.toJS,
      );

      final JSAny? result = await promise.toDart;
      if (result == null) return null;

      final web.Blob videoBlob = result as web.Blob;

      // 4. Chuyển đổi Blob kết quả thành Uint8List
      final JSArrayBuffer arrayBuffer = await videoBlob.arrayBuffer().toDart;
      return FramedVideoResult(
        bytes: arrayBuffer.toDart.asUint8List(),
        mimeType: videoBlob.type,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting framed video recap: $e');
      }
      return null;
    } finally {
      // Dọn dẹp Blob URL để tránh rò rỉ bộ nhớ
      if (frameBlobUrl != null) {
        web.URL.revokeObjectURL(frameBlobUrl);
      }
    }
  }

  /// Lật video (flip) theo chiều ngang.
  static Future<FramedVideoResult?> flipVideo({
    required String videoUrl,
    required bool isMirrored,
    String? preferredMimeType,
  }) async {
    try {
      final JSPromise promise = js_bridge.flipVideo(
        videoUrl.toJS,
        isMirrored.toJS,
        preferredMimeType?.toJS,
      );

      final JSAny? result = await promise.toDart;
      if (result == null) return null;

      final web.Blob videoBlob = result as web.Blob;
      final JSArrayBuffer arrayBuffer = await videoBlob.arrayBuffer().toDart;

      return FramedVideoResult(
        bytes: arrayBuffer.toDart.asUint8List(),
        mimeType: videoBlob.type,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error flipping raw video: $e');
      }
      return null;
    }
  }
}
