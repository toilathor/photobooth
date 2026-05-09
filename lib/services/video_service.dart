import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Service quản lý logic quay video recap và lưu trữ timestamp của các ảnh đã chụp.
class VideoService {
  XFile? _videoRecapFile;
  final List<Duration> _photoTimestamps = [];
  DateTime? _videoStartTime;

  XFile? get videoRecapFile => _videoRecapFile;
  List<Duration> get photoTimestamps => List.unmodifiable(_photoTimestamps);
  DateTime? get videoStartTime => _videoStartTime;

  /// Bắt đầu quay video recap.
  Future<void> startRecording(CameraController controller) async {
    if (!controller.value.isInitialized) return;

    try {
      await controller.startVideoRecording();
      _videoStartTime = DateTime.now();
      _photoTimestamps.clear();
      _videoRecapFile = null;
    } catch (e) {
      debugPrint('Error starting video recording in VideoService: $e');
      rethrow;
    }
  }

  /// Dừng quay video recap và lưu lại file kết quả.
  Future<XFile?> stopRecording(CameraController controller) async {
    if (!controller.value.isRecordingVideo) return null;

    try {
      _videoRecapFile = await controller.stopVideoRecording();
      return _videoRecapFile;
    } catch (e) {
      debugPrint('Error stopping video recording in VideoService: $e');
      rethrow;
    }
  }

  /// Ghi lại mốc thời gian hiện tại so với thời điểm bắt đầu quay video.
  void recordTimestamp() {
    if (_videoStartTime != null) {
      _photoTimestamps.add(DateTime.now().difference(_videoStartTime!));
    }
  }

  /// Reset toàn bộ dữ liệu video.
  void reset() {
    _videoRecapFile = null;
    _photoTimestamps.clear();
    _videoStartTime = null;
  }
}
