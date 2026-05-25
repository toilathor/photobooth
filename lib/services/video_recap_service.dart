import 'dart:typed_data';

export 'video_recap_service_stub.dart'
    if (dart.library.js) 'video_recap_service_web.dart';

class FramedVideoResult {
  final Uint8List bytes;
  final String mimeType;

  FramedVideoResult({required this.bytes, required this.mimeType});
}
