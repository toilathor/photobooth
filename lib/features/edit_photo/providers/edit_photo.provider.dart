import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:my_photobooth/core/configs/app_config.dart';
import 'package:my_photobooth/core/configs/frame_config.dart';
import 'package:my_photobooth/core/configs/storage_config.dart';
import 'package:my_photobooth/i18n/strings.g.dart';
import 'package:my_photobooth/models/frame_data.dart';
import 'package:my_photobooth/services/storage_factory.dart';
import 'package:my_photobooth/services/video_recap_service.dart';

class EditPhotoProvider with ChangeNotifier {
  bool isProcessing = false;
  String selectedFilter = 'normal';
  double filterIntensity = 1.0;
  final List<String> filters = AppConfig.filters;

  final List<FrameData> allFrames = FrameConfig.allFrames;

  List<FrameData> filteredFrames = [];
  late FrameData selectedFrame;
  bool printTwoCopies = false;
  bool showPaperPreview = false;

  // Photobooth Session Data
  List<XFile> capturedPhotos = [];
  XFile? videoRecapFile;
  List<Duration> photoTimestamps = [];
  String? sessionId;
  bool isMirrored = false;

  // Upload State
  bool isUploading = false;
  double uploadProgress = 0.0;
  String uploadStatusMessage = '';
  bool isPreparingUpload = false;

  EditPhotoProvider() {
    filteredFrames = allFrames;
    selectedFrame = allFrames.isNotEmpty
        ? allFrames.first
        : const FrameData(path: '', photoSlots: 0);
  }

  void initForPhotoCount(int count) {
    filteredFrames = allFrames.where((f) => f.photoSlots == count).toList();
    if (filteredFrames.isNotEmpty) {
      selectedFrame = filteredFrames.first;
    }
    notifyListeners();
  }

  void initWithPhotoboothData({
    required List<XFile> photos,
    required int photoCount,
    required bool isMirrored,
    XFile? videoFile,
    List<Duration>? timestamps,
    String? session,
  }) {
    capturedPhotos = photos;
    videoRecapFile = videoFile;
    photoTimestamps = timestamps ?? [];
    sessionId = session;
    this.isMirrored = isMirrored;

    initForPhotoCount(photoCount);
  }

  void setSelectedFrame(FrameData frame) {
    selectedFrame = frame;
    notifyListeners();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    filterIntensity = 1.0; // Reset intensity when filter changes
    notifyListeners();
  }

  void setFilterIntensity(double intensity) {
    filterIntensity = intensity;
    notifyListeners();
  }

  void togglePrintTwoCopies(bool value) {
    printTwoCopies = value;
    notifyListeners();
  }

  void togglePaperPreview(bool value) {
    showPaperPreview = value;
    notifyListeners();
  }

  void setProcessing(bool value) {
    isProcessing = value;
    notifyListeners();
  }

  void setUploadState({
    required bool isUploading,
    double progress = 0.0,
    String message = '',
    bool isPreparing = false,
  }) {
    this.isUploading = isUploading;
    uploadProgress = progress;
    uploadStatusMessage = message;
    isPreparingUpload = isPreparing;
    notifyListeners();
  }

  /// Xử lý yêu cầu lấy mã QR và upload
  Future<void> handleQRRequest({
    required VoidCallback onShowLoading,
    required VoidCallback onHideLoading,
    required void Function(String url) onShowQR,
    required VoidCallback onShowLogin,
    required VoidCallback onStartUpload,
    required void Function(String error) onShowError,
    required Future<Uint8List?> Function() capturePaper,
    required Future<Uint8List?> Function() captureStrip,
  }) async {
    if (StorageConfig.activeStorage == StorageType.none) return;

    if (sessionId == null && capturedPhotos.isEmpty) return;

    try {
      // 1. Kiểm tra xem bộ ảnh này đã được upload chưa
      onShowLoading();
      final existingUrl = await StorageFactory.instance.getFolderLink(
        sessionId ?? '',
      );
      onHideLoading();

      if (existingUrl != null) {
        onShowQR(existingUrl);
        return;
      }

      // 2. Kiểm tra đăng nhập (đối với Web)
      if (kIsWeb && StorageFactory.instance.currentUser == null) {
        onShowLogin();
        return;
      }

      // 3. Thực hiện upload
      onStartUpload();
      final url = await uploadCollection(
        capturePaper: capturePaper,
        captureStrip: captureStrip,
      );

      if (url != null) {
        onHideLoading();
        onShowQR(url);
      } else {
        onHideLoading();
        onShowError('Upload failed');
      }
    } catch (e) {
      onHideLoading();
      onShowError(e.toString());
    }
  }

  /// Thực hiện quy trình upload bộ sưu tập
  /// Cần truyền vào function capture để lấy dữ liệu từ UI (vì UI quản lý RepaintBoundary)
  Future<String?> uploadCollection({
    required Future<Uint8List?> Function() capturePaper,
    required Future<Uint8List?> Function() captureStrip,
  }) async {
    if (sessionId == null && capturedPhotos.isNotEmpty) {
      sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    }

    if (sessionId == null) return null;

    setUploadState(
      isUploading: true,
      isPreparing: true,
      message: t.google_drive.preparing_data,
    );

    try {
      final Map<String, Uint8List> filesToUpload = {};

      // Đợi một chút để UI ổn định
      await Future<void>.delayed(const Duration(milliseconds: 600));

      // 1. Chụp Ảnh bản in dạng final trên giấy in
      final bool originalPaperMode = showPaperPreview;
      if (!originalPaperMode) {
        togglePaperPreview(true);
      }
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final Uint8List? printCapture = await capturePaper();
      if (printCapture != null) {
        filesToUpload['anh_ban_in_final.png'] = printCapture;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 2. Chụp Ảnh đã ghép vào frame
      final bool originalPrintTwoCopies = printTwoCopies;
      togglePaperPreview(false);
      if (originalPrintTwoCopies) {
        togglePrintTwoCopies(false);
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final Uint8List? framedCapture = await captureStrip();
      if (framedCapture != null) {
        filesToUpload['anh_da_ghep_khung.png'] = framedCapture;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Khôi phục trạng thái cũ
      if (originalPaperMode) togglePaperPreview(true);
      if (originalPrintTwoCopies) togglePrintTwoCopies(true);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // 3. Xử lý video recap
      if (videoRecapFile != null) {
        setUploadState(
          isUploading: true,
          isPreparing: true,
          message: t.google_drive.creating_recap,
        );

        final originalExt = _getVideoExtension(videoRecapFile!);
        Uint8List finalOriginalBytes;
        
        // 3.1. Xử lý video gốc (flip nếu cần)
        try {
          final flippedResult = await VideoRecapService.flipVideo(
            videoUrl: videoRecapFile!.path,
            isMirrored: isMirrored == kIsWeb ? false : true,
            preferredMimeType: _getVideoMimeType(videoRecapFile!),
          );
          
          if (flippedResult != null) {
            finalOriginalBytes = flippedResult.bytes;
          } else {
            finalOriginalBytes = await videoRecapFile!.readAsBytes();
          }
        } catch (e) {
          debugPrint('Error flipping original video: $e');
          finalOriginalBytes = await videoRecapFile!.readAsBytes();
        }
        
        filesToUpload['video_recap_goc$originalExt'] = finalOriginalBytes;

        try {
          final result = await VideoRecapService.exportFramedVideo(
            videoUrl: videoRecapFile!.path,
            frame: selectedFrame,
            timestamps: photoTimestamps,
            recapDurationSeconds:
                AppConfig.recapClipDuration.inMilliseconds / 1000.0,
            preferredMimeType: _getVideoMimeType(videoRecapFile!),
            isMirrored: isMirrored == kIsWeb ? false : true,
          );
 
          if (result != null) {
            final extension = result.mimeType.contains('webm')
                ? '.webm'
                : '.mp4';
            filesToUpload['video_recap_gan_khung$extension'] = result.bytes;
          } else {
            filesToUpload['video_recap_gan_khung$originalExt'] = finalOriginalBytes;
          }
        } catch (e) {
          debugPrint('Error generating framed video: $e');
          filesToUpload['video_recap_gan_khung$originalExt'] = finalOriginalBytes;
        }
      }

      // 4. Thực hiện upload
      final String? url = await StorageFactory.instance.uploadCollection(
        files: filesToUpload,
        folderName: sessionId!,
        onProgress: (int current, int total) {
          setUploadState(
            isUploading: true,
            progress: current / total,
            message: t.google_drive.uploading_files(
              current: current,
              total: total,
            ),
          );
        },
      );

      return url;
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    } finally {
      setUploadState(isUploading: false);
    }
  }

  String _getVideoExtension(XFile file) {
    if (file.path.toLowerCase().endsWith('.webm')) return '.webm';
    if (file.path.toLowerCase().endsWith('.mp4')) return '.mp4';
    final mimeType = file.mimeType;
    if (mimeType != null) {
      if (mimeType.contains('webm')) return '.webm';
      if (mimeType.contains('mp4')) return '.mp4';
    }
    return '.mp4';
  }

  String? _getVideoMimeType(XFile file) {
    if (file.mimeType != null) return file.mimeType;
    if (file.path.toLowerCase().endsWith('.webm')) return 'video/webm';
    if (file.path.toLowerCase().endsWith('.mp4')) return 'video/mp4';
    return null;
  }
}
