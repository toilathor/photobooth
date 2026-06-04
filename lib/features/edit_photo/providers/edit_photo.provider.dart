import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/core/configs/filter_config.dart';
import 'package:th_photobooth/core/configs/frame_config.dart';
import 'package:th_photobooth/core/configs/storage_config.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/frame_data.dart';
import 'package:th_photobooth/services/frame_service.dart';
import 'package:th_photobooth/services/photo_merger_service.dart';
import 'package:th_photobooth/services/storage_factory.dart';
import 'package:th_photobooth/services/video_recap_service.dart';

class EditPhotoProvider with ChangeNotifier {
  bool isProcessing = false;
  String selectedFilter = 'normal';
  double filterIntensity = 0.5;
  final List<String> filters = AppConfig.filters;
  bool _isHandlingQR = false;

  List<FrameData> allFrames = FrameConfig.allFrames;

  List<FrameData> filteredFrames = [];
  late FrameData selectedFrame;
  bool printTwoCopies = true;
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
        : const FrameData(photoSlots: 0);
  }

  void initForPhotoCount(int count) {
    filteredFrames = allFrames.where((f) => f.photoSlots == count).toList();
    if (filteredFrames.isNotEmpty) {
      selectedFrame = filteredFrames.first;
    }
    notifyListeners();
  }

  Future<void> initWithPhotoboothData({
    required List<XFile> photos,
    required int photoCount,
    required bool isMirrored,
    XFile? videoFile,
    List<Duration>? timestamps,
  }) async {
    capturedPhotos = photos;
    videoRecapFile = videoFile;
    photoTimestamps = timestamps ?? [];
    sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    this.isMirrored = isMirrored;

    allFrames = await FrameService.loadFrames();

    initForPhotoCount(photoCount);
  }

  void setSelectedFrame(FrameData frame) {
    selectedFrame = frame;
    notifyListeners();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    filterIntensity = 0.5; // Reset intensity to 50% when filter changes
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
    required Future<Uint8List?> Function() capturePrintContent,
  }) async {
    if (StorageConfig.activeStorage == StorageType.none) return;

    if (sessionId == null && capturedPhotos.isEmpty) return;

    if (_isHandlingQR) return;
    _isHandlingQR = true;

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

      // 2. Kiểm tra đăng nhập và phân quyền (đối với Web)
      if (kIsWeb) {
        final hasLoggedIn = StorageFactory.instance.currentUser != null;
        final hasScopes = await StorageFactory.instance.hasRequiredScopes();
        if (!hasLoggedIn || !hasScopes) {
          onShowLogin();
          return;
        }
      }

      // 3. Thực hiện upload
      onStartUpload();
      final url = await uploadCollection(
        capturePaper: capturePaper,
        captureStrip: captureStrip,
        capturePrintContent: capturePrintContent,
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
    } finally {
      _isHandlingQR = false;
    }
  }

  /// Thực hiện quy trình upload bộ sưu tập
  /// Cần truyền vào function capture để lấy dữ liệu từ UI (vì UI quản lý RepaintBoundary)
  Future<String?> uploadCollection({
    required Future<Uint8List?> Function() capturePaper,
    required Future<Uint8List?> Function() captureStrip,
    required Future<Uint8List?> Function() capturePrintContent,
  }) async {
    try {
      final filesToUpload = await generateAllFiles(
        capturePaper: capturePaper,
        captureStrip: captureStrip,
        capturePrintContent: capturePrintContent,
      );

      if (filesToUpload == null || filesToUpload.isEmpty) return null;

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

  /// Thực hiện quy trình upload bộ sưu tập
  /// Cần truyền vào function capture để lấy dữ liệu từ UI (vì UI quản lý RepaintBoundary)
  Future<Map<String, Uint8List>?> generateAllFiles({
    required Future<Uint8List?> Function() capturePaper,
    required Future<Uint8List?> Function() captureStrip,
    required Future<Uint8List?> Function() capturePrintContent,
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
        final jpgBytes = _convertToJpg(printCapture);
        if (jpgBytes != null) {
          filesToUpload['${sessionId}_anh_gia_lap_ban_in.jpg'] = jpgBytes;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 1.2. Chụp ảnh đem đi in (không có viền/perforation/indicator)
      final Uint8List? printContentCapture = await capturePrintContent();
      if (printContentCapture != null) {
        final jpgBytes = _convertToJpg(printContentCapture);
        if (jpgBytes != null) {
          filesToUpload['${sessionId}_anh_dem_di_in.jpg'] = jpgBytes;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 2. Chụp Ảnh đã ghép vào frame
      final bool originalPrintTwoCopies = printTwoCopies;
      togglePaperPreview(false);
      if (originalPrintTwoCopies) {
        togglePrintTwoCopies(false);
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      try {
        final Uint8List framedCapture = await PhotoMergerService.mergePhotos(
          photos: capturedPhotos,
          frameData: selectedFrame,
          colorFilterMatrix: FilterConfig.getFilterMatrix(
            selectedFilter,
            filterIntensity,
          ),
          isMirrored: isMirrored == kIsWeb ? false : true,
        );
        final jpgBytes = _convertToJpg(framedCapture);
        if (jpgBytes != null) {
          filesToUpload['${sessionId}_anh_da_ghep_khung.jpg'] = jpgBytes;
        }
      } catch (e) {
        debugPrint('Error merging photos with PhotoMergerService: $e');
        // Fallback to UI capture if something goes wrong
        final Uint8List? fallbackCapture = await captureStrip();
        if (fallbackCapture != null) {
          final jpgBytes = _convertToJpg(fallbackCapture);
          if (jpgBytes != null) {
            filesToUpload['${sessionId}_anh_da_ghep_khung.jpg'] = jpgBytes;
          }
        }
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

        var originalExt = _getVideoExtension(videoRecapFile!);
        Uint8List finalOriginalBytes;

        // 3.1. Xử lý video gốc (flip nếu cần)
        try {
          final flippedResult = await VideoRecapService.flipVideo(
            videoUrl: videoRecapFile?.path ?? '',
            isMirrored: isMirrored == kIsWeb ? false : true,
            preferredMimeType: _getVideoMimeType(videoRecapFile!),
          );

          if (flippedResult != null) {
            finalOriginalBytes = flippedResult.bytes;
            originalExt = _getExtensionFromMimeType(flippedResult.mimeType);
          } else {
            finalOriginalBytes =
                await videoRecapFile?.readAsBytes() ?? Uint8List.fromList([]);
          }
        } catch (e) {
          debugPrint('Error flipping original video: $e');
          finalOriginalBytes =
              await videoRecapFile?.readAsBytes() ?? Uint8List.fromList([]);
        }

        filesToUpload['${sessionId}_video_recap_goc$originalExt'] =
            finalOriginalBytes;

        try {
          final result = await VideoRecapService.exportFramedVideo(
            videoUrl: videoRecapFile?.path ?? '',
            frame: selectedFrame,
            timestamps: photoTimestamps,
            recapDurationSeconds:
                AppConfig.recapClipDuration.inMilliseconds / 1000.0,
            preferredMimeType: _getVideoMimeType(videoRecapFile),
            isMirrored: isMirrored == kIsWeb ? false : true,
          );

          if (result != null) {
            final extension = _getExtensionFromMimeType(result.mimeType);
            filesToUpload['${sessionId}_video_recap_gan_khung$extension'] =
                result.bytes;
          } else {
            filesToUpload['${sessionId}_video_recap_gan_khung$originalExt'] =
                finalOriginalBytes;
          }
        } catch (e) {
          debugPrint('Error generating framed video: $e');
          filesToUpload['${sessionId}_video_recap_gan_khung$originalExt'] =
              finalOriginalBytes;
        }
      }

      return filesToUpload;
    } catch (e) {
      debugPrint('Generation error: $e');
      rethrow;
    } finally {
      setUploadState(isUploading: false);
    }
  }

  String _getVideoExtension(XFile file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.webm')) return '.webm';
    if (path.endsWith('.mp4')) return '.mp4';
    if (path.endsWith('.mov')) return '.mov';
    if (path.endsWith('.avi')) return '.avi';
    if (path.endsWith('.3gp')) return '.3gp';

    final mimeType = file.mimeType;
    if (mimeType != null) {
      return _getExtensionFromMimeType(mimeType);
    }
    return '.mp4';
  }

  String _getExtensionFromMimeType(String mimeType) {
    final cleanMime = mimeType.toLowerCase();
    if (cleanMime.contains('webm')) return '.webm';
    if (cleanMime.contains('mp4')) return '.mp4';
    if (cleanMime.contains('quicktime') || cleanMime.contains('mov')) {
      return '.mov';
    }
    if (cleanMime.contains('3gpp')) return '.3gp';
    if (cleanMime.contains('ogg')) return '.ogv';
    if (cleanMime.contains('avi')) return '.avi';
    final parts = cleanMime.split('/');
    if (parts.length == 2) {
      final subtype = parts[1].split(';')[0].trim();
      return '.$subtype';
    }
    return '.mp4';
  }

  String? _getVideoMimeType(XFile? file) {
    if (file == null) return null;
    if (file.mimeType != null) return file.mimeType;
    final path = file.path.toLowerCase();
    if (path.endsWith('.webm')) return 'video/webm';
    if (path.endsWith('.mp4')) return 'video/mp4';
    if (path.endsWith('.mov')) return 'video/quicktime';
    return null;
  }

  Uint8List? _convertToJpg(Uint8List pngBytes) {
    try {
      final image = img.decodeImage(pngBytes);
      if (image == null) return null;
      return img.encodeJpg(image, quality: 90);
    } catch (e) {
      debugPrint('Error converting image to JPG: $e');
      return null;
    }
  }
}
